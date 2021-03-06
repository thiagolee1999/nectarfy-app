import './post.dart';

class Category {
  final String id;
  final String title;
  final String description;

  Category({
    required this.id,
    required this.title,
    required this.description,
  });

  String getId() => id;
  String getTitle() => title;
  String getDescription() => description;
}
