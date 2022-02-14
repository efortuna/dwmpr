import 'package:flutter/material.dart';

import 'dart:convert';
import 'package:bidirectional_scroll_view/bidirectional_scroll_view.dart';
import 'package:http/http.dart' as http;

import 'package:dwmpr/full_version/github/token.dart';
import 'github/graphql.dart' as graphql;
import 'github/semgrepresult.dart';

class ReviewPage extends StatelessWidget {
  final String prDiff;
  final String id;
  final String reviewUrl;
  final SemgrepResult semgrepResult;

  ReviewPage(this.prDiff, this.id, this.reviewUrl, [this.semgrepResult]);

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text('Review Pull Request')));
  }

  RichText styledCode(String prDiff) {
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
    await graphql.acceptPR(reviewUrl);
    Navigator.pop(context);
  }
}
