import 'package:flutter/material.dart';
import 'package:newsapp/article.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class NewsContent extends StatelessWidget {
  final Article article;

  const NewsContent(this.article);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          padding: EdgeInsets.only(left: 20),
          icon: Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: ListView(
          children: [
            getNewsAuthor(),
            getNewsTitle(context),
            SizedBox(height: 20),
            getNewsContent(),
            SizedBox(height: 20),
            getNewsImage()
          ],
        ),
      ),
    );
  }

  Widget getNewsAuthor() {
    initializeDateFormatting();

    var dateString = new DateFormat("dd, MMM yyyy").format(article.publishedAt);
    return ListTile(
      contentPadding: EdgeInsets.all(0),
      leading: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            backgroundColor: Colors.red,
            radius: 24,
            child: Padding(
                padding: EdgeInsets.all(5),
                child: FittedBox(
                    child: Text(
                  article.author == null ? "" : article.author.substring(0, 1),
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'QuickSand-Bold',
                    fontSize: 18,
                  ),
                ))),
          ),
          SizedBox(
            width: 10,
          ),
          VerticalDivider(
            color: Colors.black87, //color of divider
            width: 10, //width space of divider
            thickness: 2.5, //thickness of divier line
            indent: 10, //Spacing at the top of divider.
            endIndent: 10, //S
          )
        ],
      ),
      title: Text(
        dateString,
        style: TextStyle(
            fontFamily: "AvenirRegular",
            fontWeight: FontWeight.w900,
            color: Color(0xFF989898)),
      ),
      subtitle: Text(
        article.author == null ? "" : article.author,
        style: TextStyle(
            fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
      ),
    );
  }

  Widget getNewsTitle(context) {
    return Text(
      article.title == null ? "" : article.title,
      style: Theme.of(context).textTheme.headline2,
    );
  }

  Widget getNewsContent() {
    return Text(
      article.content,
      style: TextStyle(
          letterSpacing: 1,
          fontSize: 18,
          fontFamily: "SomApp",
          fontWeight: FontWeight.w800,
          color: Color(0xFF989898)),
    );
  }

  Widget getNewsImage() {
    return Container(
      width: double.infinity,
      height: 220,
      child: Image.network(
        article.urlToImage != null ? article.urlToImage : "",
        // "https://ichef.bbci.co.uk/news/1024/branded_news/238E/production/_127420190_guantanmobay.jpg",
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: double.infinity,
            height: 60,
            decoration:
                BoxDecoration(shape: BoxShape.rectangle, color: Colors.grey),
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
                  ? loading.cumulativeBytesLoaded / loading.expectedTotalBytes
                  : null,
            )),
          );
        },
      ),
    );
  }
}
