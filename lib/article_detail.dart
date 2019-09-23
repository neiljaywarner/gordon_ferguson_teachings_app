import 'package:flutter_html/flutter_html.dart';

import 'package:flutter/material.dart';
import 'package:share/share.dart';

import 'DbProvider.dart';
import 'Post.dart';

class DetailScreen extends StatefulWidget {
  final Post post;

  DetailScreen({Key key, @required this.post}) : super(key: key);

  @override
  _DetailScreenState createState() => _DetailScreenState();
}


class _DetailScreenState extends State<DetailScreen> {
  var _shareMessage;
  List<String> favorites = List<String>();

  int length;

  @override
  void initState() {
    _shareMessage = "Check out this article '${widget.post.title}'\n${widget.post.link}";

    super.initState();

  }

  @override
  Widget build(BuildContext context) => FutureBuilder<Post>(
      future: DBProvider.db.getNote(widget.post.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Container();
        }

        bool isFavorite = snapshot.hasData;
        return Scaffold(
          appBar: AppBar(
              title: Text("gordonferguson.org"),
              actions: <Widget>[
                IconButton(
                  icon: Icon(Icons.share),
                  onPressed: () => Share.share(_shareMessage),
                ),
                IconButton(
                  icon: isFavorite ? Icon(Icons.star) : Icon(Icons.star_border),
                  onPressed: () => toggleFavorite(widget.post, isFavorite),
                  // TODO: border star if already favorites
                ),
              ]),
          body: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Card(
                    child: Column(
                      children: <Widget>[
                        Padding(
                            padding: EdgeInsets.all(8.0),
                            child: new Text(
                              widget.post.title,
                              style: new TextStyle(
                                  fontSize: 16.0, fontWeight: FontWeight.bold),
                            )),
                        Padding(padding: EdgeInsets.all(16.0), child: Html(data: widget.post.content)),
                      ],
                    ),
                  )
                ],
              )),
        );
      }
    );

  void toggleFavorite(Post post, bool isCurrentlyFavorite) async {
    if (isCurrentlyFavorite) {
      await DBProvider.db.unFavorite(post);
    } else {
      await DBProvider.db.favorite(post);
    }
    setState(() {
      print("rebuilding after toggling favorite");
      // just rebuild, it will update the star.
    });
  }
}
// extremely slight few lines borrowwed from flutter_wordcamp, and inspiration
// but almost all code diffferent, dependencies different, second screen new,etc