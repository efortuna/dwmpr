import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:math' as math;
import 'dart:convert';
import 'package:bidirectional_scroll_view/bidirectional_scroll_view.dart';
import 'package:dwmpr/github/token.dart';

void main() => runApp(MyApp());

// Bunch o'hard-coded stuff that will get updated from the response of the JSON/GraphQL API.
// General info about a repo (example): https://api.github.com/repos/efortuna/memechat
// PRs (example): https://api.github.com/repos/flutter/flutter/pulls
var profilePic = 'https://avatars0.githubusercontent.com/u/2112792?v=4';
var username = 'efortuna';
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

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Dude, Where's My Pull Request?",
      theme: ThemeData(
        primarySwatch: Colors.blue,
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
          child: Column(
            children: <Widget>[
              CircleAvatar(
                  backgroundImage: NetworkImage(profilePic), radius: 50.0),
              Text(username,
                  style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 32.0)),
              Expanded(
                child: ListView(
                    children: List.generate(
                        15, (i) => RepoWidget(diffUrl, issueUrl))),
              ),
            ],
          ),
        ));
  }
}

class RepoWidget extends StatelessWidget {
  final String diffUrl;
  final String issueUrl;

  RepoWidget(this.diffUrl, this.issueUrl);

  @override
  Widget build(BuildContext context) {
    return ListTile(
        title: Text(repoInfo['name']),
        onTap: () async {
          var result =
              await http.get(diffUrl).then((response) => response.body);
          return Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ReviewPage(result, issueUrl)));
        },
        trailing: Row(children: [
          Icon(Icons.star),
          Text(repoInfo['stargazers_count']),
          Icon(FontAwesomeIcons.codeBranch),
          Text(repoInfo['forks_count'])
        ]));
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
    FontAwesomeIcons.heart
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
    if (response.statusCode >= 200 && response.statusCode < 300) {
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
