import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:newsapp/article.dart';
import 'package:newsapp/database_helper.dart';
import 'package:newsapp/news_content.dart';
import 'package:sqflite/sqflite.dart';

//Debouncer (Delay For Searching 5ms)
class Debouncer {
  final int milliseconds;
  VoidCallback action;
  Timer _timer;
  Debouncer({this.milliseconds});

  run(VoidCallback action) {
    if (_timer != null) {
      _timer.cancel();
    }
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
}

class News extends StatefulWidget {
  @override
  State<News> createState() => _NewsState();
}

class _NewsState extends State<News> {
  DatabaseHelper _databaseHelper = DatabaseHelper();
  var _isLoading = true;
  List<Article> articless;
  List<Article> filterArticles;
  final _debouncer = Debouncer(milliseconds: 500);

  @override
  void initState() {
    initApi();
    super.initState();
  }

  void initApi() async {
    var databasesPath = await getDatabasesPath();
    var path = databasesPath + 'news.db';
    // Check if the database exists
    var exists = await databaseExists(path);
    if (!exists) {
      _databaseHelper.initDatabase();
      var dio = Dio();
      var response = await dio.get(
          "https://newsapi.org/v2/everything?q=tesla&from=2022-09-30&sortBy=publishedAt&apiKey=6a14e0eae2254c0e8eead37baab7ff57");

      if (response.data['status'] == "ok") {
        List<Article> maps = response.data['articles']
            .map((val) => Article.fromJson(val))
            .cast<Article>()
            .toList();

        for (int i = 0; i < maps.length; i++) {
          _databaseHelper.insertArtical(maps[i]);
        }
      }
    }
    // get All articles if data alredy present

    articless = (await _databaseHelper.getArticle());
    filterArticles = articless;
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "CNBC",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            Icon(
              Icons.list,
              color: Colors.black,
            )
          ],
        ),
        backgroundColor: Colors.white,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 22),
              child: ListView(
                scrollDirection: Axis.vertical,
                children: [
                  Text(
                    "Hey , Jon !",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Color(0XFF989898),
                        fontFamily: "AvenirRegular"),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text("Discover Latest News",
                      style: Theme.of(context).textTheme.headline1),
                  SizedBox(
                    height: 15,
                  ),
                  TextField(
                      onChanged: (searchText) {
                        _debouncer.run(() {
                          searchText = searchText.toLowerCase();
                          setState(() {
                            if (searchText.isNotEmpty) {
                              filterArticles = articless
                                  .where((element) => element.title
                                      .toLowerCase()
                                      .contains(searchText))
                                  .toList();
                            } else {
                              filterArticles = articless;
                            }
                          });
                        });
                      },
                      autofocus: false,
                      style: TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.search,
                            color: Colors.red,
                          ),
                          hintText: "Search",
                          hintStyle: TextStyle(color: Colors.black))),
                  SizedBox(
                    height: 30,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      NewsTypeContainer(
                          Icon(Icons.sports_basketball), "Sports"),
                      NewsTypeContainer(Icon(Icons.tv), "Movies"),
                      NewsTypeContainer(
                          Icon(Icons.cast_for_education), "Education"),
                      NewsTypeContainer(Icon(Icons.rule), "Politics"),
                    ],
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Row(
                    children: [
                      SizedBox(
                        height: 45,
                        child: VerticalDivider(
                          color: Colors.red,
                          width: 10,
                          thickness: 4,
                          indent: 10,
                          endIndent: 10,
                        ),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Text(
                        "Breaking News",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  NewsList(filterArticles: filterArticles),
                ],
              ),
            ),
    );
  }
}

class NewsList extends StatelessWidget {
  const NewsList({
    Key key,
    @required this.filterArticles,
  }) : super(key: key);

  final List<Article> filterArticles;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        shrinkWrap: true,
        physics: ScrollPhysics(),
        itemCount: filterArticles.length,
        itemBuilder: (c, i) {
          var dateString = new DateFormat("dd, MMM yyyy")
              .format(filterArticles[i].publishedAt);
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: GestureDetector(
                  child: ListTile(
                    contentPadding: EdgeInsets.all(0),
                    leading: Container(
                      width: 70,
                      height: 70,
                      child: Image.network(
                        filterArticles[i].urlToImage != null
                            ? filterArticles[i].urlToImage
                            : "",
                        //"https://ichef.bbci.co.uk/news/1024/branded_news/238E/production/_127420190_guantanmobay.jpg",
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 60,
                            height: 40,
                            decoration: BoxDecoration(
                                shape: BoxShape.rectangle, color: Colors.grey),
                            alignment: Alignment.center,
                            child: Text(
                              'Whoops!',
                              style: TextStyle(fontSize: 10),
                            ),
                          );
                        },
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loading) {
                          if (loading == null) return child;
                          return Container(
                            height: 40,
                            child: Center(
                                child: CircularProgressIndicator(
                              value: loading.expectedTotalBytes != null
                                  ? loading.cumulativeBytesLoaded /
                                      loading.expectedTotalBytes
                                  : null,
                            )),
                          );
                        },
                      ),
                    ),
                    title: Text(
                      filterArticles[i].title != null
                          ? filterArticles[i].title
                          : '',
                      style: TextStyle(
                        height: 1.4,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6.0),
                      child: Text(
                        dateString,
                        style: TextStyle(
                            fontFamily: "AvenirRegular",
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF989898)),
                      ),
                    ),
                  ),
                  onTap: () {
                    FocusScopeNode currentFocus = FocusScope.of(context);

                    if (!currentFocus.hasPrimaryFocus) {
                      currentFocus.unfocus();
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => NewsContent(filterArticles[i])),
                    );
                  },
                ),
              ),
              Divider(
                height: 1,
                color: Colors.grey,
              )
            ],
          );
        });
  }
}

class NewsTypeContainer extends StatelessWidget {
  final Icon icon;
  final String newsType;
  NewsTypeContainer(this.icon, this.newsType);

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(),
        () => SystemChannels.textInput.invokeMethod('TextInput.hide'));

    return Column(
      children: [
        Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: newsType == "Sports"
                    ? Color(0xFFFFCCCB)
                    : Color(0xFFdebedf0)),
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                icon,
              ],
            )),
        SizedBox(
          height: 5,
        ),
        Text(
          newsType,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
