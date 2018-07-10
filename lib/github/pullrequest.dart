// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:dwmpr/github/repository.dart';

class PullRequest {
  final Repository repo;
  final int id;
  final String url;
  final String title;
  final String diffUrl;

  PullRequest(this.id, this.title, this.url, this.repo)
      : diffUrl = url + '.diff';

  String toString() => '$title, $id, $url, $repo, $diffUrl';
}