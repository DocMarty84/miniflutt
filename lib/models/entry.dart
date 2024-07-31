import 'feed.dart';

class Entry {
  final String? author;
  final String? commentsUrl;
  String? content;
  final Feed? feed;
  final int? feedId;
  final String? hash;
  final int? id;
  final int? readingTime;
  final String? publishedAt;
  final String? shareCode;
  bool? starred;
  String? status;
  final String? title;
  final String? url;
  final int? userId;

  Entry({
    this.author,
    this.commentsUrl,
    this.content,
    this.feed,
    this.feedId,
    this.hash,
    this.id,
    this.publishedAt,
    this.readingTime,
    this.shareCode,
    this.starred,
    this.status,
    this.title,
    this.url,
    this.userId,
  });

  factory Entry.fromJson(Map<String, dynamic> json) {
    return Entry(
      author: json['author'],
      commentsUrl: json['comments_url'],
      content: json['content'],
      feed: Feed.fromJson(json['feed']),
      feedId: json['feed_id'],
      hash: json['hash'],
      id: json['id'],
      publishedAt: json['published_at'],
      readingTime: json['reading_time'],
      shareCode: json['share_code'],
      starred: json['starred'],
      status: json['status'],
      title: json['title'],
      url: json['url'],
      userId: json['user_id'],
    );
  }
}
