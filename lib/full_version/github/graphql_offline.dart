/// Offline version of GraphQL package, for testing/demo purposes

import 'dart:async';

import '../../full_version/github/parsers.dart';
import '../../full_version/github/user.dart';
import '../../full_version/github/pullrequest.dart';

Future<User> user(String login) async =>
  parseUser('''
  {
    "data":{
      "user":{
        "login":"efortuna",
        "name":"Emily Fortuna",
        "avatarUrl":"https://avatars0.githubusercontent.com/u/2112792?v=4"
      }
    }
  }
  ''');

  Future<User> currentUser() async => user('');

  Future<List<PullRequest>> openPullRequestReviews(String login) async =>
    parseOpenPullRequestReviews('''
    {"data":
    {"search":
    {"issueCount":3,"pageInfo":
    {"endCursor":"Y3Vyc29yOjM=","startCursor":"Y3Vyc29yOjE="},"edges":[
      {"node":{
        "repository":{
          "name":"dwmpr",
          "url":"https://github.com/efortuna/dwmpr",
          "stargazers":{"totalCount":2}},
          "title":"make fancy fab","id":"MDExOlB1bGxSZXF1ZXN0MjAxNzUzNzg2",
          "url":"https://github.com/efortuna/dwmpr/pull/8"}},{
            "node":{
              "repository":{
                "name":"test_commits",
                "url":"https://github.com/efortuna/test_commits",
                "stargazers":{"totalCount":0}
              },"title":"Adjust text of README file.",
              "id":"MDExOlB1bGxSZXF1ZXN0MjAxNTMzNTI3",
              "url":"https://github.com/efortuna/test_commits/pull/6"}},
              {"node":{"repository":
              {"name":"dwmpr",
              "url":"https://github.com/efortuna/dwmpr",
              "stargazers":{"totalCount":2}},
              "title":" Add in profile picture to initial page.",
              "id":"MDExOlB1bGxSZXF1ZXN0MjAxNTMzMTk5",
              "url":"https://github.com/efortuna/dwmpr/pull/6"
    }}]}}}
    ''');


getDiff(PullRequest pullRequest) async =>
'''
diff --git a/README.md b/README.md
index 2565b02..b83938e 100644
--- a/README.md
+++ b/README.md
@@ -1,4 +1,5 @@
-hello world!
+hello world.
 
 This tests the Github API.
 
+It works so well!
''';
