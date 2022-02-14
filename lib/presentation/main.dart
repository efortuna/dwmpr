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
    final ThemeData theme = ThemeData();
    return MaterialApp(
      theme: theme.copyWith(
        colorScheme: theme.colorScheme
            .copyWith(primary: githubGrey, secondary: githubBlue),
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Dude, Where's My Pull Request?")));
  }
}

showReview(BuildContext context, PullRequest pullRequest) async {
  var result = await http
      .get(Uri.parse(pullRequest.diffUrl))
      .then((response) => response.body);
  return Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              ReviewPage(result, pullRequest.id, pullRequest.url)));
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

class UserBanner extends StatelessWidget {
  final User user;
  UserBanner(this.user);

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      CircleAvatar(backgroundImage: NetworkImage(user.avatarUrl), radius: 50.0),
      Text(
        user.login,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25.0),
      ),
    ]);
  }
}

class UserAndPRs extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
        child: FutureBuilder(
      future: graphql.currentUser(),
      builder: (BuildContext context, AsyncSnapshot<User> snapshot) {
        if (snapshot.connectionState == ConnectionState.done)
          return Body(snapshot.data);
        else
          return CircularProgressIndicator();
      },
    ));
  }
}

class Body extends StatelessWidget {
  final User user;
  Body(this.user);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: UserBanner(user),
        ),
        Expanded(
          child: FetchDataWidget(
              future: graphql.openPullRequestReviews(user.login),
              builder: (List<PullRequest> prs) => PRList(prs)),
        ),
      ],
    );
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
