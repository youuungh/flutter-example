import 'package:freezed_annotation/freezed_annotation.dart';

part 'category.freezed.dart';

part 'category.g.dart';

@freezed
sealed class Category with _$Category {
  factory Category({String? docId, String? title}) = _Category;

  factory Category.fromJson(Map<String, dynamic> json) =>
      _$CategoryFromJson(json);
}