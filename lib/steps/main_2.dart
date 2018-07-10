// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;

import 'state.dart';
import 'utils.dart';
import 'github/pullrequest.dart';
import 'github/repository.dart';

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
        body: Body());
  }
}

class Body extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(children: List.generate(10, (i) => RepoWidget()));
  }
}

class RepoWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var pullRequest =
        PullRequest(0, 'Some PR', 'url', Repository('Some Repo', 'url', 3));
    return ListTile(
      title: Text(pullRequest.repo.name),
      subtitle: Text(pullRequest.title),
      trailing: Row(
        children: <Widget>[
          Icon(Icons.star, color: githubPurple),
          Text(prettyPrintInt(pullRequest.repo.starCount)),
        ],
      ),
    );
  }
}
