import 'package:flutter/material.dart';

import 'dart:convert';
import 'package:bidirectional_scroll_view/bidirectional_scroll_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:math' as math;

import 'github/token.dart';

final authHeaders = {'Authorization': 'token $token'};
final reactionHeaders = {
  'Authorization': 'token $token',
  'Accept': 'application/vnd.github.squirrel-girl-preview+json'
};

class ReviewPage extends StatelessWidget {
  final String prDiff;
  final String reviewUrl;

  ReviewPage(this.prDiff, this.reviewUrl);

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
      floatingActionButton: FancyFab(reviewUrl),
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

class FancyFab extends StatefulWidget {
  final String reviewUrl;
  FancyFab(this.reviewUrl);

  @override
  createState() => FancyFabState();

  String get mergeUrl => '$reviewUrl/merge';
  String get reactionsUrl => '$reviewUrl/reactions';
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
    http.put(widget.mergeUrl, headers: authHeaders).then(respondToRequest);
  }

  closePR(BuildContext context) {
    http
        .patch(widget.reviewUrl,
            headers: authHeaders, body: '{"state": "closed"}')
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
        .post(widget.reactionsUrl,
            headers: reactionHeaders, body: '{"content": "$reaction"}')
        .then(respondToRequest);
  }

  respondToRequest(http.Response response) {
    if (response.statusCode == 200 || response.statusCode == 201) {
      Navigator.pop(context);
    } else {
      Scaffold.of(context).showSnackBar(SnackBar(
          content: Text('Problem completing request: '
              '${response.statusCode} ${response.body}')));
    }
  }
}
