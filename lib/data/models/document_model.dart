import 'dart:convert';

class DocumentModel {
  final int? id;
  final String? name;
  final String? path;
  final String? category;
  final String? createdAt;

  DocumentModel({
    this.id,
    this.name,
    this.path,
    this.category,
    this.createdAt,
  });

  factory DocumentModel.fromMap(Map<String, dynamic> map) {
    return DocumentModel(
      id: map['id'],
      name: map['name'],
      path: map['path'],
      category: map['category'],
      createdAt: map['createdAt'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'path': path,
      'category': category,
      'createdAt': createdAt,
    };
  }

  String toJson() => json.encode(toMap());

  factory DocumentModel.fromJson(String source) =>
      DocumentModel.fromMap(json.decode(source));
}
