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

  String get mergeUrl => '$reviewUrl/merge';

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text('Review Pull Request')));
  }

  respondToRequest(http.Response response, BuildContext context) {
    if (response.statusCode == 200 || response.statusCode == 201) {
      Navigator.pop(context);
    } else {
      Scaffold.of(context).showSnackBar(SnackBar(
          content: Text('Problem completing request: '
              '${response.statusCode} ${response.body}')));
    }
  }
}
