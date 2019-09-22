import 'package:flutter/material.dart';
import 'package:tutorial/recipe_list_input.dart';

import 'sign_in_2.dart';

void main() => runApp(new SecureCounterApp());

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Recipe App',
      theme: new ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: RecipeList(selection: false),
    );
  }
}