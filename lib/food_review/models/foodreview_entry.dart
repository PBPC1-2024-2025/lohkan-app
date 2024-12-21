// To parse this JSON data, do
//
//     final reviewEntry = reviewEntryFromJson(jsonString);

import 'dart:convert';

List<ReviewEntry> reviewEntryFromJson(String str) => List<ReviewEntry>.from(json.decode(str).map((x) => ReviewEntry.fromJson(x)));

String reviewEntryToJson(List<ReviewEntry> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ReviewEntry {
    String model;
    String pk;
    Fields fields;

    ReviewEntry({
        required this.model,
        required this.pk,
        required this.fields,
    });

    factory ReviewEntry.fromJson(Map<String, dynamic> json) => ReviewEntry(
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
    int user;
    String name;
    String foodType;
    int rating;
    String comments;

    Fields({
        required this.user,
        required this.name,
        required this.foodType,
        required this.rating,
        required this.comments,
    });

    factory Fields.fromJson(Map<String, dynamic> json) => Fields(
        user: json["user"],
        name: json["name"],
        foodType: json["food_type"],
        rating: json["rating"],
        comments: json["comments"],
    );

    Map<String, dynamic> toJson() => {
        "user": user,
        "name": name,
        "food_type": foodType,
        "rating": rating,
        "comments": comments,
    };
}
