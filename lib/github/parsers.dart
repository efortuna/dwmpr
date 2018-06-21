/// Set of hand-crafted JSON parsers for GraphQL responses
///
import 'dart:convert';

import 'package:dwmpr/github/pullrequest.dart';
import 'package:dwmpr/github/repository.dart';

Iterable<PullRequest> parseopenPullRequestReviews(String resBody) {
  final jsonRes = json.decode(resBody);
  return (jsonRes['data']['search']['edges'] as List).map((edge) {
    final node = edge['node'];
    final repoName = node['repository']['name'];
    final repoUrl = node['repository']['url'];
    final repoForkCount = node['repository']['forkCount'];
    final repoStarCount = node['repository']['stargazers']['totalCount'];
    final repo = Repository(
        name: repoName,
        url: repoUrl,
        forkCount: repoForkCount,
        starCount: repoStarCount);

    final prId = node['number'];
    final prTitle = node['title'];
    final prUrl = node['url'];
    final pr = PullRequest(id: prId, title: prTitle, url: prUrl, repo: repo);

    return pr;
  });
}
