// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// Set of hand-crafted JSON parsers for GraphQL responses

import 'dart:convert';

import 'package:dwmpr/github/pullrequest.dart';
import 'package:dwmpr/github/repository.dart';

List<PullRequest> parseOpenPullRequestReviews(String resBody) {
  List jsonRes = json.decode(resBody)['data']['search']['edges'];
  return jsonRes.map((edge) {
    final node = edge['node'];
    final repoName = node['repository']['name'];
    final repoUrl = node['repository']['url'];
    final repoForkCount = node['repository']['forkCount'];
    final repoStarCount = node['repository']['stargazers']['totalCount'];
    final repo = Repository(repoName, repoUrl, repoForkCount, repoStarCount);

    final prId = node['number'];
    final prTitle = node['title'];
    final prUrl = node['url'];
    final pr = PullRequest(prId, prTitle, prUrl, repo);

    return pr;
  }).toList();
}
