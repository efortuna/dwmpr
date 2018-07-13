// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

import 'github/graphql.dart' as graphql;
import 'github/user.dart';
import 'github/pullrequest.dart';

// Github brand colors
// https://gist.github.com/christopheranderton/4c88326ab6a5604acc29
final Color githubBlue = Color(0xff4078c0);
final Color githubGrey = Color(0xff333000);
final Color githubPurple = Color(0xff6e5494);

void main() => runApp(MyApp());

// Root widget of the app
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Dude, Where's My Pull Request?",
      theme: ThemeData(
        primaryColor: githubGrey,
        accentColor: githubBlue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            leading: Icon(FontAwesomeIcons.github),
            title: Text("Dude, Where's My Pull Request?")),
        body: FetchDataWidget(
            future: graphql.openPullRequestReviews('hixie'),
            builder: (List<PullRequest> prs) => PullRequestList(prs)));
  }
}

/// Displays a list of pull requests, from the PullRequestDetails inherited widget
class PullRequestList extends StatelessWidget {
  final List<PullRequest> prs;
  PullRequestList(this.prs);

  @override
  Widget build(BuildContext context) => ListView(
        children: prs.map((pr) => RepoWidget(pr)).toList(),
      );
}

class RepoWidget extends StatelessWidget {
  final PullRequest pullRequest;
  RepoWidget(this.pullRequest);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(pullRequest.repo.name),
      subtitle: Text(pullRequest.title),
      trailing: StarWidget(pullRequest.repo.starCount),
    );
  }
}

class FetchDataWidget extends StatelessWidget {
  Future<List<PullRequest>> future;
  Function builder;

  FetchDataWidget({@required this.future, @required builder});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: future,
        builder:
            (BuildContext context, AsyncSnapshot<List<PullRequest>> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return snapshot.data.length != 0
                ? builder(snapshot.data)
                : Center(child: Text('No PR reviews today!'));
          } else {
            return Center(child: CircularProgressIndicator());
          }
        });
  }
}

class StarWidget extends StatelessWidget {
  final int starCount;
  StarWidget(this.starCount);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(Icons.star, color: githubPurple),
        Text(_prettyPrintInt(starCount)),
      ],
    );
  }

  String _prettyPrintInt(int num) =>
      (num >= 1000) ? (num / 1000.0).toStringAsFixed(1) + 'k' : '$num';
}
