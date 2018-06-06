import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

void main() => runApp(new MyApp());

// Bunch o'hard-coded stuff that will get updated from the response of the JSON/GraphQT API.
// General info about a repo (example): https://api.github.com/repos/efortuna/memechat
// PRs (example): https://api.github.com/repos/flutter/flutter/pulls
var profilePic = 'https://avatars0.githubusercontent.com/u/2112792?v=4';
var username = 'efortuna';
var defaultRepoInfo = {
  'name': 'A Repository',
  'stargazers_count': '3',
  'forks_count': '5',
};

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: "Dude, Where's My Pull Request?",
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
            title: new Row(
          children: <Widget>[
            new Icon(FontAwesomeIcons.github),
            new Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: new Text("Dude, Where's My Pull Request?"),
            ),
          ],
        )),
        body: new Center(
          child: new Column(
            children: <Widget>[
              new CircleAvatar(
                  backgroundImage: new NetworkImage(profilePic), radius: 50.0),
              new Text(username,
                  style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 32.0)),
              new Expanded(
                child: new ListView(
                    children: new List.generate(15, (i) => new RepoWidget())),
              ),
            ],
          ),
        ));
  }
}

class RepoWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new ListTile(
        title: new Text(defaultRepoInfo['name']),
        trailing: new Row(children: [
          Icon(Icons.star),
          Text(defaultRepoInfo['stargazers_count']),
          Icon(FontAwesomeIcons.codeBranch),
          Text(defaultRepoInfo['forks_count'])
        ]));
  }
}
