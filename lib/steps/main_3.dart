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
import 'github/graphql_3.dart' as graphql;

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
    return FutureBuilder(
        // Hardcoding user for testing purposes
        // future: openPullRequestReviews(user.login),
        future: graphql.openPullRequestReviews('hixie'),
        builder: _fetchPullRequests(PullRequestList()));
  }
}

class PullRequestList extends StatelessWidget {
  @override
  Widget build(BuildContext context) => ListView(
        children: PullRequestListDetails
            .of(context)
            .prs
            .map((pr) => PullRequestDetails(pr: pr, child: RepoWidget()))
            .toList(),
      );
}

class RepoWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var pullRequest = PullRequestDetails.of(context);
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

/// Handles fetching and caching pull request data for a FutureBuilder
_fetchPullRequests(Widget child) {
  return (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.done) {
      return snapshot.data.length != 0
          ? PullRequestListDetails(prs: snapshot.data, child: child)
          : Center(child: Text('No PR reviews for you'));
    } else {
      return Center(child: CircularProgressIndicator());
    }
  };
}
