// To parse this JSON data, do
//
//     final bucketListEntry = bucketListEntryFromJson(jsonString);

import 'dart:convert';

List<BucketListEntry> bucketListEntryFromJson(String str) => List<BucketListEntry>.from(json.decode(str).map((x) => BucketListEntry.fromJson(x)));

String bucketListEntryToJson(List<BucketListEntry> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class BucketListEntry {
    String model;
    String pk;
    Fields fields;

    BucketListEntry({
        required this.model,
        required this.pk,
        required this.fields,
    });

    factory BucketListEntry.fromJson(Map<String, dynamic> json) => BucketListEntry(
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
    List<String> foods;

    Fields({
        required this.user,
        required this.name,
        required this.foods,
    });

    factory Fields.fromJson(Map<String, dynamic> json) => Fields(
        user: json["user"],
        name: json["name"],
        foods: List<String>.from(json["foods"].map((x) => x)),
    );

    Map<String, dynamic> toJson() => {
        "user": user,
        "name": name,
        "foods": List<dynamic>.from(foods.map((x) => x)),
    };
}
