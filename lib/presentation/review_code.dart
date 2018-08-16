import 'package:flutter/material.dart';

import 'dart:convert';
import 'package:bidirectional_scroll_view/bidirectional_scroll_view.dart';
import 'package:http/http.dart' as http;

import 'github/token.dart';
import 'github/graphql.dart' as graphql;

class ReviewPage extends StatelessWidget {
  final String prDiff;
  final String id;
  final String reviewUrl;

  ReviewPage(this.prDiff, this.id, this.reviewUrl);

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text('Review Pull Request')));
  }
}
