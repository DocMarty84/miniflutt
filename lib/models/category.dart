class Category {
  final int? id;
  final String? title;
  final int? userId;
  final bool? hideGlobally;

  Category({
    this.id,
    this.title,
    this.userId,
    this.hideGlobally,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      title: json['title'],
      userId: json['user_id'],
      hideGlobally:
          (json.containsKey('hide_globally') ? json['hide_globally'] : false),
    );
  }
}
