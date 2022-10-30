import 'package:newsapp/article.dart';
import 'package:sqflite/sqflite.dart';

final String tableName = 'article';
final String id = 'id';
final String name = 'name';
final String author = 'author';
final String title = 'title';
final String description = 'description';
final String url = 'url';
final String urlToImagae = 'urlToImage';
final String publishedAt = 'publishedAt';
final String content = 'content';

class DatabaseHelper {
  static Database _database;
  static DatabaseHelper _databaseHelper;
  DatabaseHelper._createInstance();

  factory DatabaseHelper() {
    if (_databaseHelper == null) {
      _databaseHelper = DatabaseHelper._createInstance();
    }
    return _databaseHelper;
  }

  Future<Database> get database async {
    if (_database == null) {
      _database = await initDatabase();
    }
    return _database;
  }

  Future<Database> initDatabase() async {
    var directory = await getDatabasesPath();
    var path = directory + 'news.db';

    var database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        db.execute(''' 
        create table $tableName(
          $id integer primary key autoincrement,
          $name text,
          $author text,
          $title text,
          $description text,
          $url text,
          $urlToImagae text,
          $publishedAt text,
          $content text
        );
        ''');
      },
    );
    return database;
  }

  // Add Articles
  void insertArtical(Article article) async {
    var db = await this.database;
    var result = await db.insert(tableName, article.toJson());
    print("result" + result.toString());
  }

  // Get All list of aricles
  Future<List<Article>> getArticle() async {
    List<Article> _article = [];
    var db = await this.database;
    var result = await db.query(tableName);

    print("result" + result.toString());

    for (var item in result) {
      var article = Article.fromJson(item);
      _article.add(article);
    }

    return _article;
  }
}
