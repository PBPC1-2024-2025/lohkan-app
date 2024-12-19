// To parse this JSON data, do
//
//     final askRecipeEntry = askRecipeEntryFromJson(jsonString);

import 'dart:convert';

List<AskRecipeEntry> askRecipeEntryFromJson(String str) => List<AskRecipeEntry>.from(json.decode(str).map((x) => AskRecipeEntry.fromJson(x)));

String askRecipeEntryToJson(List<AskRecipeEntry> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class AskRecipeEntry {
    String model;
    String pk;
    Fields fields;

    AskRecipeEntry({
        required this.model,
        required this.pk,
        required this.fields,
    });

    factory AskRecipeEntry.fromJson(Map<String, dynamic> json) => AskRecipeEntry(
        model: json["model"],
        pk: json["pk"],
        fields: Fields.fromJson(json["fields"]),
    );

    Map<String, dynamic> toJson() => {
        "model": model,
        "pk": pk,
        "fields": fields.toJson(),
    };
}

class Fields {
    String title;
    String image; // Path relatif gambar
    String imageUrl; // URL absolut gambar
    String ingredients;
    String instructions;
    int cookingTime;
    int servings;
    int addedBy;
    String group;
    DateTime createdAt;

    Fields({
        required this.title,
        required this.image,
        required this.imageUrl,
        required this.ingredients,
        required this.instructions,
        required this.cookingTime,
        required this.servings,
        required this.addedBy,
        required this.group,
        required this.createdAt,
    });

    factory Fields.fromJson(Map<String, dynamic> json) => Fields(
        title: json["title"],
        image: json["image"], // Path relatif gambar
        imageUrl: json["image_url"] ?? '', // URL absolut gambar (opsional)
        ingredients: json["ingredients"],
        instructions: json["instructions"],
        cookingTime: json["cooking_time"],
        servings: json["servings"],
        addedBy: json["added_by"],
        group: json["group"],
        createdAt: DateTime.parse(json["created_at"]),
    );

    Map<String, dynamic> toJson() => {
        "title": title,
        "image": image,
        "image_url": imageUrl,
        "ingredients": ingredients,
        "instructions": instructions,
        "cooking_time": cookingTime,
        "servings": servings,
        "added_by": addedBy,
        "group": group,
        "created_at": createdAt.toIso8601String(),
    };
}