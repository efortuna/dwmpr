import 'package:dwmpr/github/graphql.dart';
import 'package:dwmpr/github/pullrequest.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:math' as math;
import 'dart:convert';
import 'package:bidirectional_scroll_view/bidirectional_scroll_view.dart';
import 'package:dwmpr/github/token.dart';

import 'package:dwmpr/github/graphql.dart' as graphql;
import 'package:dwmpr/github/user.dart';

void main() => runApp(MyApp());

// Bunch o'hard-coded stuff that will get updated from the response of the JSON/GraphQL API.
// General info about a repo (example): https://api.github.com/repos/efortuna/memechat
// PRs (example): https://api.github.com/repos/flutter/flutter/pulls
var repoInfo = {
  'name': 'A Repository',
  'stargazers_count': '3',
  'forks_count': '5',
};
// Example URL.
// You want to start with listing the PRs:
// https://api.github.com/repos/efortuna/test_commits/pulls
// We'll pass in the issue_url (for commenting) as well as the diff_url
// (for displaying the diff)
// The logic for getting that will be in GraphQL.
final diffUrl = 'https://github.com/efortuna/test_commits/pull/2.diff';
//'https://patch-diff.githubusercontent.com/raw/flutter/flutter/pull/18193.diff';
final issueUrl = 'https://api.github.com/repos/efortuna/test_commits/issues/2';
final reviewUrl = 'https://api.github.com/repos/efortuna/test_commits/pulls/1';
final testRepo = 'https://api.github.com/repos/efortuna/test_commits/';
final enableReactions = 'application/vnd.github.squirrel-girl-preview+json';
// Github brand colors:
// https://gist.github.com/christopheranderton/4c88326ab6a5604acc29
final Color githubBlue = Color(0xff4078c0);
final Color githubGrey = Color(0xff333000);
final Color githubPurple = Color(0xff6e5494);

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
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
        //backgroundColor: Color(0xff999999),
        appBar: AppBar(
            leading: Icon(FontAwesomeIcons.github),
            title: Text('Dude, Where\'s My Pull Request?')),
        body: Center(
            child: FutureBuilder(
                future: graphql.user(),
                builder: (context, AsyncSnapshot<User> snapshot) {
                  var user = snapshot.data;
                  if (snapshot.connectionState == ConnectionState.done)
                    return GitHubUser(
                      user: user,
                      child: Column(
                        children: <Widget>[
                          CircleAvatar(
                              backgroundImage: NetworkImage(user.avatarUrl),
                              radius: 50.0),
                          Text(user.login,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 32.0)),
                          Expanded(
                            child: FutureBuilder(
                                future: openPullRequestReviews(user.login),
                                builder: (context,
                                    AsyncSnapshot<Iterable<PullRequest>>
                                        snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.done) {
                                    if (snapshot.data.length == 0)
                                      return Center(
                                          child: Text('No PR Reviews for You'));
                                    return ListView(
                                      children: snapshot.data
                                          .map((pr) => RepoWidget(pr))
                                          .toList(),
                                    );
                                  } else {
                                    return Center(
                                        child: CircularProgressIndicator());
                                  }
                                }),
                          ),
                        ],
                      ),
                    );
                  else
                    return CircularProgressIndicator();
                })));
  }
}

class RepoWidget extends StatelessWidget {
  final PullRequest pullRequest;

  RepoWidget(this.pullRequest);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(pullRequest.title),
      onTap: () async {
        var result = await http
            .get(pullRequest.diffUrl)
            .then((response) => response.body);
        return Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ReviewPage(result, pullRequest.url)));
      },
      trailing: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(Icons.star),
              Text(pullRequest.repo.starCount.toString()),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(FontAwesomeIcons.codeBranch, color: githubPurple),
              Text(pullRequest.repo.forkCount.toString()),
            ],
          ),
        ],
      ),
    );
  }
}

class FancyFab extends StatefulWidget {
  final String issueUrl;

  FancyFab(this.issueUrl);

  @override
  State<StatefulWidget> createState() => FancyFabState();
}

class FancyFabState extends State<FancyFab> with TickerProviderStateMixin {
  AnimationController _controller;

  static const List<IconData> icons = const [
    Icons.check,
    Icons.do_not_disturb,
    Icons.thumb_up,
    Icons.thumb_down,
    Icons.favorite,
    FontAwesomeIcons.question,
    Icons.cake,
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List<Widget>.generate(icons.length, (int index) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: _controller, curve: Curves.easeOut),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: FloatingActionButton(
              heroTag: null,
              backgroundColor: Theme.of(context).cardColor,
              mini: true,
              child: Icon(icons[index], color: Theme.of(context).accentColor),
              onPressed: () {
                if (icons[index] == Icons.check) {
                  acceptPR(context);
                } else if (icons[index] == Icons.do_not_disturb) {
                  closePR(context);
                } else {
                  addEmoji(context, icons[index]);
                }
              },
            ),
          ),
        );
      }).toList()
        ..add(
          FloatingActionButton(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (BuildContext context, Widget child) {
                return Transform.rotate(
                  angle: _controller.value * math.pi,
                  child:
                      Icon(_controller.isDismissed ? Icons.code : Icons.close),
                );
              },
            ),
            onPressed: () {
              if (_controller.isDismissed) {
                _controller.forward();
              } else {
                _controller.reverse();
              }
            },
          ),
        ),
    );
  }

  acceptPR(BuildContext context) {
    http.put('$reviewUrl/merge',
        headers: {'Authorization': 'token $token'}).then(respondToRequest);
  }

  closePR(BuildContext context) {
    http
        .patch(reviewUrl,
            headers: {'Authorization': 'token $token'},
            body: '{"state": "closed"}')
        .then(respondToRequest);
  }

  void addEmoji(BuildContext context, IconData icon) {
    String reaction = 'heart';
    if (icon == Icons.thumb_up) {
      reaction = '+1';
    } else if (icon == Icons.thumb_down) {
      reaction = '-1';
    } else if (icon == Icons.cake) {
      reaction = 'hooray';
    } else if (icon == FontAwesomeIcons.question) {
      reaction = 'confused';
    }
    http
        .post('${widget.issueUrl}/reactions',
            headers: {
              'Authorization': 'token $token',
              'Accept': enableReactions
            },
            body: '{"content": "$reaction"}')
        .then(respondToRequest);
  }

  respondToRequest(http.Response response) {
    if (response.statusCode == 200 || response.statusCode == 201) {
      Navigator.pop(context);
    } else {
      print(
          'Problem completing request: ${response.statusCode} ${response.body}');
    }
  }
}

class ReviewPage extends StatelessWidget {
  final String prDiff;
  // TODO(mattsullivan): Passing issueUrl around all the way down to FancyFab
  // seems suboptimal. What's the right way to do this?
  final String issueUrl;

  // Yes, this assumes only one review per repo. We could add a button for
  // "next review" or something if we wanted.
  ReviewPage(this.prDiff, this.issueUrl);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Review Pull Request')),
      body: BidirectionalScrollViewPlugin(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child:
              RichText(softWrap: false, text: TextSpan(children: styledCode())),
        ),
      ),
      floatingActionButton: FancyFab(issueUrl),
    );
  }

  List<TextSpan> styledCode() {
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
          style: TextStyle(color: color, fontFamily: 'monospace')));
    }
    return lines;
  }
}

class GitHubUser extends InheritedWidget {
  const GitHubUser({
    Key key,
    @required this.user,
    @required Widget child,
  })  : assert(user != null),
        assert(child != null),
        super(key: key, child: child);

  final User user;

  static GitHubUser of(BuildContext context) {
    return context.inheritFromWidgetOfExactType(GitHubUser);
  }

  @override
  bool updateShouldNotify(GitHubUser old) => user != old.user;
}
