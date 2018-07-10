// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';

import 'github/pullrequest.dart';

/// Inherited Widget that holds list of PRs for review
class PullRequestListDetails extends InheritedWidget {
  const PullRequestListDetails({
    Key key,
    @required this.prs,
    @required Widget child,
  })  : assert(prs != null),
        assert(child != null),
        super(key: key, child: child);

  final List<PullRequest> prs;

  static PullRequestListDetails of(BuildContext context) =>
      context.inheritFromWidgetOfExactType(PullRequestListDetails);

  @override
  bool updateShouldNotify(PullRequestListDetails old) => prs != old.prs;
}

/// Inherited Widget that holds a PR for review
class PullRequestDetails extends InheritedWidget {
  const PullRequestDetails({
    Key key,
    @required this.pr,
    @required Widget child,
  })  : assert(pr != null),
        assert(child != null),
        super(key: key, child: child);

  final PullRequest pr;

  static PullRequest of(BuildContext context) =>
      (context.inheritFromWidgetOfExactType(PullRequestDetails)
      as PullRequestDetails)
          .pr;

  @override
  bool updateShouldNotify(PullRequestDetails old) => pr != old.pr;
}
