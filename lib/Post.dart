import 'package:html_unescape/html_unescape.dart';

class PostResponse {
  final List<Post> posts;

  PostResponse(this.posts);

  factory PostResponse.fromJson(List<dynamic> parsedJson) => PostResponse(parsedJson.map((i)=>Post.fromJson(i)).toList());
  static List<Post> getPosts(List<dynamic> parsedJson) => PostResponse.fromJson(parsedJson).posts;
}

class Post {
  final int id;
  final String excerpt;
  final String title;
  final String link;
  final String imageUrl;
  final String content;

  Post({this.id, this.excerpt, this.title, this.link, this.imageUrl, this.content});

  // TODO: Consider when to embed if ever?
  // eg is jetpack_featured_media_url good enough
  // or we could use smaller images for thumbnails...
  factory Post.fromJson(Map<String, dynamic> json) {
    String content = json['content']['rendered'];
    content = content.replaceAll("<em>", "'");
    content = content.replaceAll("</em>", "'");
    content = content.replaceAll("<sup>", "");
    content = content.replaceAll("</sup>", "");


    int id = json['id'];
    String excerpt = json['excerpt']['rendered'] ?? "";
    String title = json['title']['rendered'];
    title = HtmlUnescape().convert(title);
    excerpt = HtmlUnescape().convert(excerpt);
    content = HtmlUnescape().convert(content);
    return Post(
      id: id,
      title: title,
      excerpt: excerpt,
      link: json['link'],
      imageUrl: json['jetpack_featured_media_url'],
      content: content
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'excerpt': excerpt,
        'link': link,
        'imageUrl': imageUrl,
        'content': content
      };

  factory Post.fromMap(Map<String, dynamic> map) => Post(
      id: map['id'],
      title: map['title'],
      excerpt: map['excerpt'],
      link: map['link'],
      imageUrl: map['imageUrl'],
      content: map['content']
    );
}
