import 'package:dwmpr/full_version/main.dart';
import 'package:flutter/material.dart';

import 'dart:convert';
import 'package:bidirectional_scroll_view/bidirectional_scroll_view.dart';
import 'package:http/http.dart' as http;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:math' as math;

import 'package:dwmpr/full_version/github/token.dart';
import 'github/graphql.dart' as graphql;
import 'github/semgrepresult.dart';

class ReviewPage extends StatelessWidget {
  final String prDiff;
  final String id;
  final String reviewUrl;
  final SemgrepResult semgrepResult;

  ReviewPage(this.prDiff, this.id, this.reviewUrl, [this.semgrepResult]);

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text('Review Pull Request')));
  }

  RichText styledCode(String prDiff) {
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
          style: TextStyle(color: color, fontFamily: 'RobotoMono')));
    }
    return RichText(softWrap: false, text: TextSpan(children: lines));
  }

  acceptPR(BuildContext context) async {
    await graphql.acceptPR(reviewUrl);
    Navigator.pop(context);
  }
}

class FancyFab extends StatefulWidget {
  final String id;
  final String reviewUrl;
  final Color buttonColor;
  FancyFab(this.id, this.reviewUrl, [this.buttonColor = null]);

  @override
  createState() => FancyFabState();
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
    FontAwesomeIcons.rocket,
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
              backgroundColor: githubGrey,
              mini: true,
              child: Icon(icons[index]),
              onPressed: () {
                if (icons[index] == Icons.check) {
                  graphql.acceptPR(widget.reviewUrl);
                } else if (icons[index] == Icons.do_not_disturb) {
                  graphql.closePR(widget.reviewUrl);
                } else {
                  addEmoji(context, icons[index]);
                }
                Navigator.pop(context);
              },
            ),
          ),
        );
      }).toList()
        ..add(
          FloatingActionButton(
            backgroundColor: widget.buttonColor,
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

  void addEmoji(BuildContext context, IconData icon) async {
    String reaction = 'HEART';
    if (icon == Icons.thumb_up) {
      reaction = 'THUMBS_UP';
    } else if (icon == Icons.thumb_down) {
      reaction = 'THUMBS_DOWN';
    } else if (icon == FontAwesomeIcons.rocket) {
      reaction = 'ROCKET';
    } else if (icon == FontAwesomeIcons.question) {
      reaction = 'CONFUSED';
    }
    await graphql.addEmoji(widget.id, reaction);
  }
}
