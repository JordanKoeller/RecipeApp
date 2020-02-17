import 'package:amazon_cognito_identity_dart/cognito.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:tutorial/meta_engine.dart';
import 'package:tutorial/sign_in_2.dart';
import 'secret.dart' as secret;
import 'dart:developer';
import 'dart:convert';
part 'backend.g.dart';

enum RestMethod { POST, GET }

@JsonSerializable(explicitToJson: true)
class Ingredient {
  String amount;
  String itemName;
  MetaTag metadata;

  Ingredient(this.amount, this.itemName, {MetaTag meta = MetaTag.Default}) {
    metadata = meta;
  }
  void setMetadata() {
    if (metadata == MetaTag.Default || metadata == MetaTag.Category || metadata == null) {
      MetaDataEngine.getTag(this.itemName).then((MetaTag res) {
        this.metadata = res;
      });
    }
  }

  factory Ingredient.fromJson(Map<String, dynamic> json) =>
      _$IngredientFromJson(json);

  Map<String, dynamic> toJson() => _$IngredientToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Recipe {
  List<Ingredient> ingredients = List<Ingredient>();
  String recipeName;
  String recipeLink;
  bool isSelected = true;

  Recipe(this.recipeName, this.recipeLink, this.ingredients);

  factory Recipe.fromJson(Map<String, dynamic> json) {
    final ret = _$RecipeFromJson(json);
    return ret;
  }

  void add(Ingredient newIngredient) {
    ingredients.add(newIngredient);
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> ret = _$RecipeToJson(this);
    final mapList = json.encode(ingredients);
    ret['ingredients'] = mapList;
    return ret;
  }
}

class Backend {
  static List<Recipe> _recipes = [];
  static final biggerFont = const TextStyle(fontSize: 18.0);
  static UserService _userService;
  static Set<Ingredient> _ingredientsInCart = new Set<Ingredient>();

  static List<Recipe> recipes() {
    return List.from(_recipes);
  }

  static List<Ingredient> ingredientsNotInCart() {
    final recips = recipes();
    recips.removeWhere((Recipe r) => !r.isSelected);
    final ings = recips.expand((Recipe r) => r.ingredients).toList();
    ings.removeWhere(
        (Ingredient ingredient) => _ingredientsInCart.contains(ingredient));
    return ings;
  }

  static Future<void> setUserService(UserService service) async {
    _userService = service;
    await synchronizeRecipes();
  }

  static Future<CognitoCredentials> _credentials() async {
    if (_userService != null) {
      if (await _userService.checkAuthenticated()) {
        return await _userService.getCredentials();
      }
    }
    return null;
  }

  static Future<void> clearSelected() async {
    _recipes.forEach((Recipe r) {
      r.isSelected = false;
    });
  }

  static void purchase(Ingredient ing) {
    _ingredientsInCart.add(ing);
  }

  static Future<void> synchronizeRecipes() async {
    final response = await pushToEndpoint(RestMethod.GET, "/recipes", {});
    if (response != null) {
      List elems =
          jsonDecode(response.body)['Items']; // NEED TO MAP OUT TO Recipes;
      // log(elems.toString());
      _recipes = elems
          .map((e) =>
              e == null ? null : Recipe.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      log("Response of null");
    }
    final ings = _recipes.where((Recipe r) => r.isSelected).expand((Recipe r) => r.ingredients).toList();
    MetaDataEngine.findTags(ings);
  }

  static void pushRecipesToCloud() async {
    final credentials = await _credentials();
    if (credentials != null) {
      _recipes.forEach((Recipe r) async {
      await pushToEndpoint(RestMethod.POST, "/recipes", r.toJson(), jsonEncode: false);
      });
    }
  }

  static addRecipe(Recipe r) {
    _recipes.add(r);
  }

  // static Future<http.Response> pushToEndpointSig(
  //     RestMethod method, String endpoint, Map<String, dynamic> body) async {
  //   final realEnd = secret.apiEndpointUrl;
  //   await _userService.init();
  //   final _isAuthenticated = await _userService.checkAuthenticated();
  //   if (_isAuthenticated) {
  //     // get user attributes from cognito
  //     final _user = await _userService.getCurrentUser();
  //     // get session credentials
  //     final credentials = await _userService.getCredentials();
  //     final awsSigV4Client = new AwsSigV4Client(
  //         credentials.accessKeyId, credentials.secretAccessKey, realEnd,
  //         region: secret.region, sessionToken: credentials.sessionToken);

  //     if (credentials != null) {
  //       switch (method) {
  //         case RestMethod.POST:
  //           {
  //             final signedRequest = new SigV4Request(awsSigV4Client,
  //                 method: 'POST', path: endpoint, body: body.toString());
  //             log(signedRequest.headers.toString());
  //             log(signedRequest.headers.keys.toList().toString());
  //             return await http.post(
  //                 signedRequest.url, //.apiEndpointUrl + endpoint,
  //                 headers: signedRequest.headers,
  //                 body: signedRequest.body);
  //           }
  //         case RestMethod.GET:
  //           {
  //             return await http.get(
  //               secret.apiEndpointUrl + endpoint,
  //               headers: {
  //                 'Authorization': _userService.getAccessToken(),
  //                 'content-type': 'application/json'
  //               },
  //             );
  //           }
  //         default:
  //           {
  //             log("Invalid method");
  //             return null;
  //           }
  //       }
  //     } else {
  //       return null;
  //     }
  //   } else {
  //     return null;
  //   }
  // }

  static Future<http.Response> pushToEndpoint(
      RestMethod method, String endpoint, Map<String, dynamic> body, {bool jsonEncode = true}) async {
    final credentials = await _credentials();
    if (credentials != null) {
      switch (method) {
        case RestMethod.POST:
          {
            return await http.post(secret.apiEndpointUrl + endpoint,
                headers: {
                  'Authorization': _userService.getAccessToken(),
                  'content-type': 'application/json'
                },
                body: jsonEncode ? json.encode(body) : body.toString());
          }
        case RestMethod.GET:
          {
            return await http.get(
              secret.apiEndpointUrl + endpoint,
              headers: {
                'Authorization': _userService.getAccessToken(),
                'content-type': 'application/json'
              },
            );
          }
        default:
          {
            log("Invalid method");
            return null;
          }
      }
    } else {
      return null;
    }
  }
}
