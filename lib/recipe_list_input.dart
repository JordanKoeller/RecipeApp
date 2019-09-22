import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:tutorial/ingredient_checklist.dart';
import 'package:url_launcher/url_launcher.dart';

import 'recipe_form.dart';
import 'backend.dart';

class RecipeList extends StatefulWidget {
  final bool selection;

  @override
  RecipeListState createState() {
    final ret = RecipeListState();
    ret.isSelecting = this.selection;
    return ret;
  }

  RecipeList({Key key, @required this.selection}) : super(key: key);
}

class RecipeListState extends State<RecipeList> {
  bool isSelecting = true;

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Widget _buildRow(Recipe recipe) {
    if (isSelecting) {
      final bool isSelected = recipe.isSelected;
      return ListTile(
          title: Text(recipe.recipeName, style: Backend.biggerFont),
          trailing: Icon(
              isSelected ? Icons.shopping_cart : Icons.add_shopping_cart,
              color: isSelected ? Colors.blue : null),
          onTap: () {
            setState(() {
              recipe.isSelected = !isSelected;
            });
          },
          subtitle: FlatButton(
            child: Text(
              recipe.recipeLink,
              style: TextStyle(color: Colors.blue, fontStyle: FontStyle.italic),
            ),
            onPressed: () => _launchURL(recipe.recipeLink),
          ));
    } else {
      return ListTile(
          title: Text(recipe.recipeName, style: Backend.biggerFont),
          subtitle: FlatButton(
            child: Text(
              recipe.recipeLink,
              style: TextStyle(color: Colors.blue, fontStyle: FontStyle.italic),
            ),
            onPressed: () => _launchURL(recipe.recipeLink),
          ));
    }
  }

  void _addRecipe() {
    final form = RecipeForm();
    final future = Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (BuildContext context) {
        return Scaffold(
            appBar: AppBar(title: Text('Add New Recipe')), body: form);
      },
    ));
    future.whenComplete(() {
      log("Finished");
      Recipe buildRecipe = form.getEnteredRecipe();
      Backend.addRecipe(buildRecipe);
      Backend.pushRecipesToCloud();
    });
  }

  Widget _buildRecipeList() {
    final selectedRecipes = this.isSelecting
        ? Backend.recipes()
        : Backend.recipes().where((Recipe r) => r.isSelected).toList();
    final shift = isSelecting ? 1 : 0;
    return ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: 2 * (selectedRecipes.length + shift),
        itemBuilder: (context, i) {
          if (isSelecting && i == 0) {
            return FlatButton(
              child: Text("Add New Recipe", style: Backend.biggerFont),
              textColor: Colors.blue,
              onPressed: _addRecipe,
            );
          } else if (i.isOdd)
            return Divider();
          else {
            final index = i ~/ 2;
            return _buildRow(selectedRecipes[index - shift]);
          }
        });
  }

  void _allIngredients() {
    Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (BuildContext context) {
      return Scaffold(
          appBar: AppBar(title: Text("Shopping List")),
          body: IngredientChecklist());
    }));
  }

  FloatingActionButton saveListButton() {
    return FloatingActionButton.extended(
        icon: Icon(Icons.account_balance),
        label: Text("New List"),
        onPressed: () {
          Backend.clearSelected();
          Navigator.of(context)
              .push(MaterialPageRoute<void>(builder: (BuildContext context) {
            return RecipeList(selection: true);
          }));
          Backend.pushRecipesToCloud();
        });
  }

  @override
  Widget build(BuildContext context) {
    if (isSelecting) {
      return Scaffold(
          appBar: AppBar(title: Text("New Recipe List")),
          body: _buildRecipeList());
    } else {
      return Scaffold(
        appBar: AppBar(title: Text("Recipes"), actions: <Widget>[
          IconButton(
              icon: Icon(Icons.shopping_basket), onPressed: _allIngredients)
        ]),
        body: _buildRecipeList(),
        floatingActionButton: saveListButton(),
      );
    }
  }
}
