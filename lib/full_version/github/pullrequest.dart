// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'repository.dart';

class PullRequest {
  final Repository repo;
  final String id;
  final String url;
  final String title;
  final String diffUrl;

  PullRequest(this.id, this.title, String url, this.repo)
      : diffUrl = url + '.diff',
        url = url
            .replaceFirst('github.com', 'api.github.com/repos')
            .replaceFirst('/pull/', '/pulls/');

  String toString() => '$title, $id, $url, $repo, $diffUrl';
}
