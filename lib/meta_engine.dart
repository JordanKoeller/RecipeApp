import 'package:json_annotation/json_annotation.dart';
import 'package:tutorial/backend.dart';
import 'dart:convert';
import 'dart:developer';
part 'meta_engine.g.dart';

enum MetaTag {
  Default,
  Toiletries,
  Beauty,
  Frozen,
  Meats,
  Produce,
  Italian,
  Mexican,
  Asian,
  Alcohol,
  Snacks,
  Soda,
  Pharmacy,
  Bakery,
  Seafood,
  Spices,
  Baking,
  Soups,
  Canned,
  Category
}

@JsonSerializable()
class LookupMeta {
  String ingName;
  int metaTag;

  LookupMeta(this.ingName, this.metaTag);

  factory LookupMeta.fromJson(Map<String, dynamic> json) =>
      _$LookupMetaFromJson(json);

  Map<String, dynamic> toJson() => _$LookupMetaToJson(this);
}

class StringAggregator {
  String id;
  double metric;

  StringAggregator(this.id, this.metric);
}

class MetaResponse {
  MetaTag tag;
  bool isMatch;

  MetaResponse(this.tag, this.isMatch);
}

class MetaDataEngine {
  static Map<String, MetaTag> lookup = {};

  static addNewTag(String name, MetaTag tag) async {
    log("Adding " + name + " with tag " + tag.toString());
    Map<String, dynamic> reqItem = {
      "ingName": name.toLowerCase().trim(),
      "metaTag": tag.index
    };
    await Backend.pushToEndpoint(RestMethod.POST, "/metadata-post", reqItem);
    // log(ret.statusCode.toString());
    // log(ret.body);
  }

  static Future<MetaTag> getTag(String name) async {
    if (lookup.containsKey(name)) return lookup[name];
    Map<String, dynamic> reqItem = {"ingName": name.toLowerCase().trim()};
    final ret =
        await Backend.pushToEndpoint(RestMethod.POST, "/metadata-get", reqItem);
    if (ret.statusCode == 200) {
      final tag = jsonDecode(ret.body)["Item"]["metaTag"] as String;
      if (tag != "" && tag != null) {
        final match = int.parse(tag);
        // log("Got " + MetaTag.values[match].toString());
        return MetaTag.values[match];
      } else {
        // log("Got a response of empty string for $name");
        return MetaTag.Category;
      }
    } else {
      // log("Error in reaching the gateway");
      // log(ret.body);
      return MetaTag.Category;
      // log("An unknown error code occurred");

    }
  }

  static findTags(List<Ingredient> allIngs) async {
    var cnt = 0;
    List<String> ingNames = allIngs.map((Ingredient ing) => ing.itemName).toSet().toList();
    while (cnt < ingNames.length) {
      final keys = ingNames.sublist(
          cnt, cnt + 80 < ingNames.length ? cnt + 80 : allIngs.length);
      cnt = cnt + 80 < ingNames.length ? cnt + 80 : allIngs.length;
      final ret = await Backend.pushToEndpoint(
          RestMethod.POST, "/metadata-get-batch", {'Keys': keys});
      if (ret.statusCode == 200) {
        final tags =
            jsonDecode(ret.body)["Responses"]["recipe-app-beta-metadata-table"];
        tags.forEach((dynamic elem) {
          final ingName = elem["ingName"]["S"];
          if (elem["metaTag"]["N"] != "" && elem["metaTag"]["N"] != null) {
            final metaTag = int.parse(elem["metaTag"]["N"]);
            lookup.putIfAbsent(ingName, () => MetaTag.values[metaTag]);
          }
        });
      }
    }
    var counter = 0;
    allIngs.forEach((Ingredient ing) {
      if (lookup.containsKey(ing.itemName)) {
        counter++;
        ing.metadata = lookup[ing.itemName];
      }
    });
    log("Set $counter metatags.");
  }
}
