class Category {
  final int? id;
  final String? title;
  final int? userId;

  Category({
    this.id,
    this.title,
    this.userId,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      title: json['title'],
      userId: json['user_id'],
    );
  }
}
