// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:dwmpr/full_version/github/graphql.dart';

main() async {
  // openPullRequestReviews('hixie').then((prs) => prs.forEach(print));
  //user('mjohnsullivan').then(print);
  currentUser().then(print);
}
