import 'package:flutter/material.dart';

import 'dart:convert';
import 'package:bidirectional_scroll_view/bidirectional_scroll_view.dart';
import 'package:http/http.dart' as http;

import 'github/token.dart';

final authHeaders = {'Authorization': 'token $token'};

class ReviewPage extends StatelessWidget {
  final String prDiff;
  final String reviewUrl;

  ReviewPage(this.prDiff, this.reviewUrl);

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text('Review Pull Request')));
  }

  RichText styledCode() {
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
          style: TextStyle(color: color, fontFamily: 'RobotoMono')));
    }
    return RichText(softWrap: false, text: TextSpan(children: lines));
  }

  acceptPR(BuildContext context) async {
    http.Response response = await http.put('$reviewUrl/merge', headers: authHeaders);
    if (response.statusCode == 200 || response.statusCode == 201) {
      Navigator.pop(context);
    } else {
      Scaffold.of(context).showSnackBar(SnackBar(
          content: Text('Problem completing request: '
              '${response.statusCode} ${response.body}')));
    }
  }
}
