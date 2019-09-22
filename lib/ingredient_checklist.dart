import 'package:flutter/material.dart';
import 'package:tutorial/meta_engine.dart';
import 'backend.dart';

class IngredientChecklist extends StatefulWidget {
  @override
  IngredientChecklistState createState() {
    return IngredientChecklistState();
  }
}

class IngredientChecklistState extends State<IngredientChecklist> {

  @override
  Widget build(BuildContext context) {
    return _allIngredients();
  }

  Widget _allIngredients() {
    final ingredients = Backend.ingredientsNotInCart();
    final tagGroups = Map<MetaTag, List<Ingredient>>();
    for (var ingredient in ingredients) {
      tagGroups
          .putIfAbsent(ingredient.metadata, () => new List())
          .add(ingredient);
    }
    final groupInds = tagGroups.keys.toList();
    groupInds.sort((MetaTag a, MetaTag b) {
      return a.toString().split('.').last.compareTo(b.toString().split('.').last);
    });
    return ListView.builder(
      itemCount: tagGroups.length,
      itemBuilder: (BuildContext context, int index) => ExpansionTile(
        title: Text(groupInds[index].toString().split('.').last),
        children: tagGroups[groupInds[index]]
            .map((Ingredient ing) => ListTile(
                  title: Text(
                      "${ing.amount} ${ing.itemName}",
                      style: Backend.biggerFont),
                  trailing: Icon(Icons.check_box_outline_blank, color: null),
                  onTap: () => setState(() {
                    Backend.purchase(ing);
                  }),
                ))
            .toList(),
      ),
    );
  }
}
