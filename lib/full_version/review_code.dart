import 'package:flutter/material.dart';

import 'dart:convert';
import 'package:bidirectional_scroll_view/bidirectional_scroll_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:math' as math;

import 'github/graphql.dart' as graphql;

class ReviewPage extends StatelessWidget {
  final String prDiff;
  final String id;
  final String reviewUrl;

  ReviewPage(this.prDiff, this.id, this.reviewUrl);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Review Pull Request')),
      body: BidirectionalScrollViewPlugin(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: styledCode(),
        ),
      ),
      floatingActionButton: FancyFab(id, reviewUrl),
    );
  }

  RichText styledCode() {
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
}

class FancyFab extends StatefulWidget {
  final String id;
  final String reviewUrl;
  FancyFab(this.id, this.reviewUrl);

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
    } else if (icon == Icons.cake) {
      reaction = 'HOORAY';
    } else if (icon == FontAwesomeIcons.question) {
      reaction = 'CONFUSED';
    }
    await graphql.addEmoji(widget.id, reaction);
  }
}
