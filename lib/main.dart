import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
var diffUrl =
    'https://patch-diff.githubusercontent.com/raw/flutter/flutter/pull/18193.diff';

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
                child:
                    ListView(children: List.generate(15, (i) => RepoWidget())),
              ),
            ],
          ),
        ));
  }
}

class RepoWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListTile(
        title: Text(repoInfo['name']),
        // Might want to change how we navigate to the PRs. Maybe a FAB somewhere?
        onTap: () async {
          var result =
              await http.get(diffUrl).then((response) => response.body);
          return Navigator.push(context,
              MaterialPageRoute(builder: (context) => ReviewPage(result)));
        },
        trailing: new Row(children: [
          Icon(Icons.star),
          Text(repoInfo['stargazers_count']),
          Icon(FontAwesomeIcons.codeBranch),
          Text(repoInfo['forks_count'])
        ]));
  }
}

class ReviewPage extends StatelessWidget {
  final String prDiff;

  // Yes, this assumes only one review per repo. We could add a button for
  // "next review" or something if we wanted.
  ReviewPage(this.prDiff);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Review Pull Request')),
        body: Column(
          children: <Widget>[
            Expanded(
                child: SingleChildScrollView(
                    child: Padding(
              padding: const EdgeInsets.all(20.0),
                      // TODO(efortuna): Make this prettier.
                      // Perhaps https://github.com/toufikzitouni/flutter-bidirectional_scrollview_plugin
              child: RichText(
                  softWrap: false, text: TextSpan(children: styledCode())),
            ))),
            Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: RaisedButton.icon(
                      onPressed: () => closePR(context),
                      icon: Icon(Icons.close),
                      label: Text('Close Request'),
                      color: Colors.red),
                ),
                RaisedButton.icon(
                    onPressed: () => acceptPR(context),
                    icon: Icon(Icons.check),
                    label: Text('Accept Pull Request'),
                    color: Colors.green),
              ],
            ),
          ],
        ));
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

  acceptPR(BuildContext context) {
    // TODO(efortuna): Implement.

    Navigator.pop(context);
  }

  closePR(BuildContext context) {
    // TODO(efortuna): Implement.

    Navigator.pop(context);
  }
}
