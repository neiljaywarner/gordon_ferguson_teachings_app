import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import 'DbProvider.dart';
import 'Post.dart';
import 'article_detail.dart';

Future<List<Post>> fetchPost() async {
  final response = await http.get('http://gordonferguson.org/wp-json/wp/v2/posts?per_page=100');

  if (response.statusCode == 200) {
    // If the call to the server was successful, parse the JSON
    return PostResponse.getPosts(json.decode(response.body));
  } else {
    // If that call was not successful, throw an error.
    //todo: fimber and crashlytics
    throw Exception('Failed to load posts:' + response.statusCode.toString());
  }
}

void main() => runApp(MyApp(posts: fetchPost()));

class MyApp extends StatefulWidget {
  final Future<List<Post>> posts;

  MyApp({Key key, this.posts}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _selectedIndex = 0;
  ArticleFutureBuilder home;

  @override
  void initState() {
    super.initState();
    home = ArticleFutureBuilder(posts: widget.posts);
  }

  Widget _buildFavoritesWidget(int selectedIndex) {
    if (selectedIndex==1) {
      return ArticleFutureBuilder(posts: DBProvider.db.getAllFavorites());
    } else if (selectedIndex == 2) {
      return AboutPage();
    } else {
      return home;
    }
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gordon Ferguson',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: Scaffold(
        appBar: AppBar(title: Text('Gordon Ferguson')),
        body: Center(
          child: _buildFavoritesWidget(_selectedIndex),
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(icon: Icon(Icons.home), title: Text('Home')),
            BottomNavigationBarItem(icon: Icon(Icons.star), title: Text('Favorites')),
            BottomNavigationBarItem(icon: Icon(Icons.info), title: Text('About')),
          ],
          currentIndex: _selectedIndex,
          fixedColor: Theme.of(context).accentColor,
          onTap: _onItemTapped,
        ),
      ),
    );

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}

class ArticleFutureBuilder extends StatelessWidget {
  const ArticleFutureBuilder({
    Key key,
    @required this.posts,
  }) : super(key: key);

  final Future<List<Post>> posts;

  @override
  Widget build(BuildContext context) => FutureBuilder<List<Post>>(
      future: posts,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          debugPrint("Connection state not done");
          return CircularProgressIndicator();
        }
        debugPrint("Connection state done");

        if (snapshot.hasData && snapshot.data.isNotEmpty) {
          debugPrint("has data-data not null: numPosts=" + snapshot.data.length.toString());
          return ListView.builder(
              itemCount: snapshot.data.length,
              padding: const EdgeInsets.all(8.0),
              itemBuilder: (BuildContext _context, int i) => PostCard(post: snapshot.data[i])
          );
        } else if (snapshot.hasError) {
          debugPrint("Has Error ${snapshot.error}");
          return Center(child:Text('No articles or error loading articles.'));
        } else {
          debugPrint("No favorites");
          return Center(child:Text('Star an article an it will show up here!'));
        }
      },
    );
}

class PostCard extends StatelessWidget {

  final Post post;

  PostCard({Key key, this.post}) : super(key: key);

  @override
  Widget build(BuildContext context) => InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => DetailScreen(post: post))),
      child: Card(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top:8),
              child: ListTile(
                title: Text(post.title),
                subtitle: Html(data: post.excerpt,),
              ),
            ),
          ],
        ),
      ),
    );
}

class AboutPage extends StatelessWidget {

  final resourcesHtml = '''
  <img src="http://gordonferguson.org/wp-content/uploads/2016/11/Final-Main-Header.jpg"/>
  <ul>
    <li><a href='http://gordonferguson.org'>gordonferguson.org</a></li>
    <li><a href="https://ipibooks.ecwid.com/#!/Gordon-Ferguson/c/18671194/offset=0&sort=nameAsc">Books, videos (ipi)</a></li>
    <li><a href="mailto:gordonferguson33@gmail.com">Contact</a></li>
    </a></li>
    </ul>
    ''';

  @override
  Widget build(BuildContext context) => Container(
      padding: EdgeInsets.all(12),
      child: Html(data: resourcesHtml, onLinkTap: (String url) => launch(url, forceSafariVC: false),),
    );
}
