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
import 'review_code.dart';

// Github brand colors
// https://gist.github.com/christopheranderton/4c88326ab6a5604acc29
final Color githubBlue = Color(0xff4078c0);
final Color githubGrey = Color(0xff333000);
final Color githubPurple = Color(0xff6e5494);

final mattGithubAvatar =
    'https://avatars1.githubusercontent.com/u/102488?s=400&v=4';
final emilyGithubAvatar =
    'https://avatars2.githubusercontent.com/u/2112792?s=400&v=4';

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
        appBar: AppBar(title: Text("Dude, Where's My Pull Request?")),
        body: Center(
            child: Column(children: [
          UserBanner(),
          Expanded(
              child: FetchDataWidget(
                  future: graphql.openPullRequestReviews('efortuna'),
                  builder: (List<PullRequest> prs) => PullRequestList(prs)))
        ])));
  }
}

class PullRequestList extends StatelessWidget {
  final List<PullRequest> prs;
  PullRequestList(this.prs);

  @override
  Widget build(BuildContext context) {
    return ListView(
        children: prs
            .map((PullRequest pr) => ListTile(
                title: Text(pr.repo.name),
                subtitle: Text(pr.title),
                trailing: StarWidget(pr.repo.starCount)))
            .toList());
  }
}

class UserBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(children: [
          CircleAvatar(
              backgroundImage: NetworkImage(mattGithubAvatar), radius: 50.0),
          Text(
            'mjohnsullivan',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25.0),
          ),
        ]));
  }
}

class FetchDataWidget extends StatelessWidget {
  final Future<List<PullRequest>> future;
  final Function builder;

  FetchDataWidget({@required this.future, @required this.builder});

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

  String _prettyPrintInt(int num) {
    var numStr = num.toString();
    if (num >= 1000) return (num / 1000.0).toStringAsFixed(1) + 'k';
    return numStr.padLeft(6 - numStr.length);
  }
}
