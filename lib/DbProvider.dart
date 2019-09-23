
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'Post.dart';

class DBProvider {
  DBProvider._();
  static final DBProvider db = DBProvider._();

  static Database _database;

  Future<Database> get database async {
    if (_database != null)
      return _database;

    // if _database is null we instantiate it
    _database = await initDB();
    return _database;
  }

  Future<List<Post>> getAllFavorites() async {
    final db = await database;
    var results = await db.query("favorites");
    if (results.isEmpty) {
      print("favorites table in db is empty");
    } else {
      print("Found ${results.length} favorites");
    }
    return results.isNotEmpty ? results.map((c) => Post.fromMap(c)).toList() : [];
  }

  Future favorite(Post favorite) async {
    final db = await database;
    db.insert("favorites", favorite.toMap());
  }

  Future unFavorite(Post post) async {
    final db = await database;
    await db.delete("favorites", where: 'id = ?', whereArgs: [post.id]);
  }


  //fixme
  Future<bool> isFavorite(Post post) async => ((await getNote(post.id)) != null);

  Future<Post> getNote(int id) async {
    var dbClient = await database;
    List<Map> result = await dbClient.query("favorites",
        where: 'id = ?',
        whereArgs: [id]);

    if (result.length > 0) {
      return Post.fromMap(result.first);
    }

    return null;
  }

  Future initDB() async {
    var databasePath = await getDatabasesPath();
    String path = join(databasePath, "posts.db");
    return await openDatabase(path, version: 1, onOpen: (db) {
    }, onCreate: (Database db, int version) async {
      await db.execute(
        '''
        CREATE TABLE favorites (
          id INTEGER PRIMARY KEY,
          title TEXT,
          excerpt TEXT,
          link TEXT,
          imageUrl TEXT,
          content TEXT)
          '''
      );

    });


  }



  

  // CRUD - create, retrieve
// factory Post.fromMap(Map<String, dynamic> map) => Post(
//      title: map['title'],
//      excerpt: map['excerpt'],
//      link: map['link'],
//      imageUrl: map['imageUrl'],
//      content: map['content']
//    );
}

