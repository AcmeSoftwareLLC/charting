import 'package:material_ui/material_ui.dart';
import 'package:json_annotation/json_annotation.dart';

/// Converts `Color` to and from JSON.
///
/// Usage:
/// ```
///   @JsonSerializable()
///   @ColorConverter()
///   class SomeDataClass {
///     ...
///     final Color color;
///     ...
///   }
/// ```
class ColorConverter implements JsonConverter<Color, int> {
  /// Initializes
  const ColorConverter();

  @override
  Color fromJson(int value) => Color(value);

  @override
  int toJson(Color color) => color.toARGB32();
}

/// Converts `List<Color>` to and from JSON.
///
/// Usage:
/// ```
///   @JsonSerializable()
///   @ColorListConverter()
///   class SomeDataClass {
///     ...
///     final List<Color> colors;
///     ...
///   }
/// ```
class ColorListConverter implements JsonConverter<List<Color>, List<dynamic>> {
  /// Initializes
  const ColorListConverter();

  // The JSON type is declared as `List<dynamic>`, not `List<int>`, because
  // that's what `jsonDecode` actually produces for a JSON array — casting
  // its result directly to `List<int>` throws at runtime even when every
  // element is an int, since `List<dynamic>` isn't a subtype of `List<int>`.
  @override
  List<Color> fromJson(List<dynamic> value) =>
      value.map((dynamic e) => Color(e as int)).toList();

  @override
  List<int> toJson(List<Color> colors) =>
      colors.map((Color color) => color.toARGB32()).toList();
}
