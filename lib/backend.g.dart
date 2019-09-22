// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'backend.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Ingredient _$IngredientFromJson(Map<String, dynamic> json) {
  return Ingredient(json['amount'] as String, json['itemName'] as String)
    ..metadata = _$enumDecodeNullable(_$MetaTagEnumMap, json['metadata']);
}

Map<String, dynamic> _$IngredientToJson(Ingredient instance) =>
    <String, dynamic>{
      'amount': instance.amount,
      'itemName': instance.itemName,
      // 'metadata': _$MetaTagEnumMap[instance.metadata]
    };

T _$enumDecode<T>(Map<T, dynamic> enumValues, dynamic source) {
  if (source == null) {
    throw ArgumentError('A value must be provided. Supported values: '
        '${enumValues.values.join(', ')}');
  }
  return enumValues.entries
      .singleWhere((e) => e.value == source,
          orElse: () => throw ArgumentError(
              '`$source` is not one of the supported values: '
              '${enumValues.values.join(', ')}'))
      .key;
}

T _$enumDecodeNullable<T>(Map<T, dynamic> enumValues, dynamic source) {
  if (source == null) {
    return null;
  }
  return _$enumDecode<T>(enumValues, source);
}

const _$MetaTagEnumMap = <MetaTag, dynamic>{
  MetaTag.Default: 'Default',
  MetaTag.Toiletries: 'Toiletries',
  MetaTag.Beauty: 'Beauty',
  MetaTag.Frozen: 'Frozen',
  MetaTag.Meats: 'Meats',
  MetaTag.Produce: 'Produce',
  MetaTag.Italian: 'Italian',
  MetaTag.Mexican: 'Mexican',
  MetaTag.Asian: 'Asian',
  MetaTag.Alcohol: 'Alcohol',
  MetaTag.Snacks: 'Snacks',
  MetaTag.Soda: 'Soda',
  MetaTag.Pharmacy: 'Pharmacy',
  MetaTag.Bakery: 'Bakery',
  MetaTag.Seafood: 'Seafood',
  MetaTag.Spices: 'Spices',
  MetaTag.Baking: 'Baking',
  MetaTag.Soups: 'Soups',
  MetaTag.Canned: 'Canned'
};

Recipe _$RecipeFromJson(Map<String, dynamic> json) {
  return Recipe(
      json['recipeName'] as String,
      json['recipeLink'] as String,
      (json['ingredients'] as List)
          ?.map((e) =>
              e == null ? null : Ingredient.fromJson(e as Map<String, dynamic>))
          ?.toList())
    ..isSelected = json['isSelected'] as bool;
}

Map<String, dynamic> _$RecipeToJson(Recipe instance) => <String, dynamic>{
      'ingredients': instance.ingredients?.map((e) => e?.toJson())?.toList(),
      'recipeName': instance.recipeName,
      'recipeLink': instance.recipeLink,
      'isSelected': instance.isSelected
    };
