import 'package:flutter/material.dart';

import 'dart:convert';
import 'package:bidirectional_scroll_view/bidirectional_scroll_view.dart';
import 'package:http/http.dart' as http;

import 'github/token.dart';

final enableReactions = 'application/vnd.github.squirrel-girl-preview+json';

class ReviewPage extends StatelessWidget {
  final String prDiff;
  final String reviewUrl;

  ReviewPage(this.prDiff, this.reviewUrl);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Review Pull Request')),
      body: BidirectionalScrollViewPlugin(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child:
              RichText(softWrap: false, text: TextSpan(children: styledCode())),
        ),
      ),
      floatingActionButton: new FloatingActionButton(
          child: Icon(Icons.check), onPressed: () => acceptPR(context)),
    );
  }

  List<TextSpan> styledCode() {
    var lines = <TextSpan>[];
    for (var line in LineSplitter.split(prDiff)) {
      var color = Colors.black;
      if (line.startsWith('+')) {
        color = Colors.green;
      } else if (line.startsWith('-')) {
        color = Colors.red;
      }
      lines.add(TextSpan(
          text: line + '\n',
          style: TextStyle(color: color, fontFamily: 'monospace')));
    }
    return lines;
  }

  acceptPR(BuildContext context) {
    http.put('$reviewUrl/merge', headers: {
      'Authorization': 'token $token'
    }).then((response) => respondToRequest(response, context));
  }

  respondToRequest(http.Response response, BuildContext context) {
    if (response.statusCode == 200 || response.statusCode == 201) {
      Navigator.pop(context);
    } else {
      print(
          'Problem completing request: ${response.statusCode} ${response.body}');
    }
  }
}
