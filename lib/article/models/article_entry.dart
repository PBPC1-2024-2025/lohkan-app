// To parse this JSON data, do
//
//     final articleEntry = articleEntryFromJson(jsonString);

import 'dart:convert';

List<ArticleEntry> articleEntryFromJson(String str) => List<ArticleEntry>.from(json.decode(str).map((x) => ArticleEntry.fromJson(x)));

String articleEntryToJson(List<ArticleEntry> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ArticleEntry {
    String model;
    String pk;
    Fields fields;

    ArticleEntry({
        required this.model,
        required this.pk,
        required this.fields,
    });

    factory ArticleEntry.fromJson(Map<String, dynamic> json) => ArticleEntry(
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
    String description;
    String image;
    List<Comment> comments;

    Fields({
        required this.title,
        required this.description,
        required this.image,
        required this.comments,
    });

    factory Fields.fromJson(Map<String, dynamic> json) => Fields(
        title: json["title"],
        description: json["description"],
        image: json["image"],
        comments: List<Comment>.from(json["comments"].map((x) => Comment.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "title": title,
        "description": description,
        "image": image,
        "comments": List<dynamic>.from(comments.map((x) => x.toJson())),
    };
}

class Comment {
    int id;
    String user;
    String content;
    DateTime createdAt;

    Comment({
        required this.id,
        required this.user,
        required this.content,
        required this.createdAt,
    });

    factory Comment.fromJson(Map<String, dynamic> json) => Comment(
        id: json["id"],
        user: json["user"],
        content: json["content"],
        createdAt: DateTime.parse(json["created_at"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "user": user,
        "content": content,
        "created_at": createdAt.toIso8601String(),
    };
}
