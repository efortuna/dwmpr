// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;

import 'github/graphql.dart' as graphql;
import 'github/user.dart';
import 'github/pullrequest.dart';

import 'review_code.dart';

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
        body: Center(
            child: FutureBuilder(
          future: graphql.currentUser(),
          builder: _buildUser,
        )));
  }

  Widget _buildUser(BuildContext context, AsyncSnapshot<User> snapshot) {
    if (snapshot.connectionState == ConnectionState.done)
      return Body(snapshot.data);
    else
      return CircularProgressIndicator();
  }
}

/// Displays the app's main body, and is dependent on the UserDetails inherited widget
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
          child: FutureBuilder(
              // Hardcoding user for testing purposes
              // future: openPullRequestReviews(user.login),
              future: graphql.openPullRequestReviews('efortuna'),
              builder: _buildPRList),
        ),
      ],
    );
  }

  Widget _buildPRList(
      BuildContext context, AsyncSnapshot<List<PullRequest>> snapshot) {
    if (snapshot.connectionState == ConnectionState.done) {
      return snapshot.data.length != 0
          ? PullRequestList(snapshot.data)
          : Center(child: Text('No PR reviews for you'));
    } else {
      return Center(child: CircularProgressIndicator());
    }
  }
}

/// Displays the user's login and avatar
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

/// Displays a list of pull requests, from the PullRequestDetails inherited widget
class PullRequestList extends StatelessWidget {
  final List<PullRequest> prs;
  PullRequestList(this.prs);

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: prs
          .map((pullRequest) => ListTile(
                title: Text(pullRequest.repo.name),
                subtitle: Text(pullRequest.title),
                onTap: () => showReview(context, pullRequest),
                trailing: StarWidget(pullRequest.repo.starCount),
              ))
          .toList(),
    );
  }

  showReview(BuildContext context, PullRequest pullRequest) async {
    var result = await graphql.getDiff(pullRequest);
    return Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                ReviewPage(result, pullRequest.id, pullRequest.url)));
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
