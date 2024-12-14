// To parse this JSON data, do
//
//     final food = foodFromJson(jsonString);

import 'dart:convert';

List<Food> foodFromJson(String str) =>
    List<Food>.from(json.decode(str).map((x) => Food.fromJson(x)));

String foodToJson(List<Food> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Food {
  Model model;
  String pk;
  Fields fields;

  Food({
    required this.model,
    required this.pk,
    required this.fields,
  });

  factory Food.fromJson(Map<String, dynamic> json) => Food(
        model: modelValues.map[json["model"]]!,
        pk: json["pk"],
        fields: Fields.fromJson(json["fields"]),
      );

  Map<String, dynamic> toJson() => {
        "model": modelValues.reverse[model],
        "pk": pk,
        "fields": fields.toJson(),
      };
}

class Fields {
  DateTime date;
  String name;
  String description;
  int minPrice;
  int maxPrice;
  String imageLink;
  Type type;

  Fields({
    required this.date,
    required this.name,
    required this.description,
    required this.minPrice,
    required this.maxPrice,
    required this.imageLink,
    required this.type,
  });

  factory Fields.fromJson(Map<String, dynamic> json) => Fields(
        date: DateTime.parse(json["date"]),
        name: json["name"],
        description: json["description"],
        minPrice: json["min_price"],
        maxPrice: json["max_price"],
        imageLink: json["image_link"],
        type: typeValues.map[json["type"]]!,
      );

  Map<String, dynamic> toJson() => {
        "date":
            "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}",
        "name": name,
        "description": description,
        "min_price": minPrice,
        "max_price": maxPrice,
        "image_link": imageLink,
        "type": typeValues.reverse[type],
      };
}

enum Type { DR, DS, MC, SN }

final typeValues =
    EnumValues({"DR": Type.DR, "DS": Type.DS, "MC": Type.MC, "SN": Type.SN});

enum Model { EXPLORE_FOOD }

final modelValues = EnumValues({"explore.food": Model.EXPLORE_FOOD});

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
