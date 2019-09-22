import 'package:flutter/material.dart';
import 'package:tutorial/meta_engine.dart';
import 'backend.dart';

class RecipeForm extends StatefulWidget {
  final _state = RecipeFormState();

  @override
  RecipeFormState createState() {
    return _state;
  }

  Recipe getEnteredRecipe() {
    return this._state.getRecipe();
  }
}

class RecipeFormState extends State<RecipeForm> {
  final _ingredients = <Ingredient>[];
  String _url = "Recipe Link";
  String _name = "Recipe Name";
  int counter = 0;

  Recipe getRecipe() {
    final ret = Recipe(_name, _url, _ingredients.where((Ingredient ing) => ing.itemName != "Default").toList());
    return ret;
  }

  Widget _buildInputList() {
    final urlInput = TextField(
      decoration: InputDecoration(border: InputBorder.none, hintText: _url),
      onSubmitted: (String input) {
        setState(() {
          _url = input;
        });
        // //FocusScope.of(context).requestFocus(ingInput.focusNode);
      },
      onChanged: (String input) {
        _url = input;
      },
    );
    final nameInput = TextField(
      decoration: InputDecoration(border: InputBorder.none, hintText: _name),
      onSubmitted: (String input) {
        _name = input;
        //FocusScope.of(context).requestFocus(urlInput.focusNode);
      },
      onChanged: (String input) {
        _name = input;
      },
    );
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: 2 * (counter + 3),
      itemBuilder: (context, i) {
        int ii = i ~/ 2;
        if (i.isOdd) {
          return Divider();
        }
        if (ii == 0) {
          return ListTile(title: nameInput);
        } else if (ii == 1) {
          return ListTile(title: urlInput);
        } else {
          final ret = _makeTile(ii - 2);
          return ret;
        }
      },
    );
  }

  ListTile _makeTile(int index) {
    if (index == _ingredients.length) {
      _ingredients.add(new Ingredient("Default", "Default", meta:MetaTag.Category));
    }
    List<MetaTag> sortedTags = List.from(MetaTag.values);
    sortedTags.sort((MetaTag p, MetaTag n) => p.toString().compareTo(n.toString()));
    final tagDropdown = DropdownButton(
      items: sortedTags
          .map((MetaTag tag) => DropdownMenuItem(
              value: tag, child: Text(tag.toString().split(".").last)))
          .toList(),
      value: _ingredients[index].metadata,
      onChanged: (MetaTag tag) {
        setState(() {
          _ingredients[index].metadata = tag;
          MetaDataEngine.addNewTag(_ingredients[index].itemName, _ingredients[index].metadata);
        });
      },
      hint: Text(_ingredients[index].metadata.toString().split(".").last),
    );
    final amtFocusNode = FocusNode();
    final amtInput = TextField(
      decoration: InputDecoration(border: null, hintText: _ingredients[index].amount),
      onSubmitted: (String input) {
        setState(() {
          counter++;
          _ingredients[index].amount = input;
        });
      },
      onChanged: (String input) {
        _ingredients[index].amount = input;
      },
      focusNode: amtFocusNode,
    );
    final ingInput = TextField(
      decoration: InputDecoration(border: null, hintText: _ingredients[index].itemName),
      onSubmitted: (String input) async {
        _ingredients[index].metadata = (await MetaDataEngine.getTag(input));
        setState(() {
          _ingredients[index].itemName = input;
        // FocusScope.of(context).requestFocus(amtFocusNode);
        });
      },
      onChanged: (String input) {
        _ingredients[index].itemName = input;
      },
    );
    return ListTile(
      title: ingInput,
      subtitle: Column(
        children: <Widget>[amtInput, tagDropdown],
        // crossAxisAlignment: CrossAxisAlignment.stretch,
      ),
      trailing: IconButton(
        icon: Icon(Icons.delete_forever),
        color: Colors.grey,
        onPressed: () => setState(() {
          counter--;
          if (index < _ingredients.length) _ingredients.removeAt(index);
        }),
      ),
      // trailing: Icon(
      //   Icons.delete_forever,
      //   color: Colors.blueAccent
      // ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildInputList();
  }
}
