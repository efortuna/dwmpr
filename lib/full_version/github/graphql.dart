// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'parsers.dart';
import 'pullrequest.dart';
import 'token.dart';
import 'user.dart';
import 'semgrepresult.dart';

final url = 'https://api.github.com/graphql';
final headers = {'Authorization': 'bearer $token'};
final postHeaders = {'Authorization': 'token $token'};

/// Fetches the details of the specified user
Future<User> user(String login) async {
  final query = '''
    query {
      user(login:"$login") {
        login
        name
        avatarUrl
      }
    }
  ''';

  final result = await _query(query);
  return parseUser(result);
}

/// Fetches user data for the auth'd user
Future<User> currentUser() async {
  const query = '''
    query {
      viewer {
        login
        name
        avatarUrl
      }
    }''';
  final result = await _query(query);
  return parseUser(result);
}

/// Fetches all PR review requests for the logged in user
Future<List<PullRequest>> openPullRequestReviews(String login) async {
  final query = '''
    query GetOpenReviewRequests {
      search(query: "type:pr state:open user:$login", type: ISSUE, first: 100) {
        issueCount
        pageInfo {
          endCursor
          startCursor
        }
        edges {
          node {
            ... on PullRequest {
              repository {
                name
                url
                stargazers(first: 1) {
                  totalCount
                }
              }
              title
              id
              url
            }
          }
        }
      }
    }''';
  final result = await _query(query);
  return parseOpenPullRequestReviews(result);
}

addEmoji(String id, String reaction) async {
  var query = '''
    mutation AddReactionToIssue {
      addReaction(input:{subjectId:"$id", content:$reaction}) {
        reaction {
          content
        }
        subject {
          id
        }
      }
    }
    ''';
  await _query(query);
}

acceptPR(String reviewUrl) async {
  var response =
      await http.put(Uri.parse('$reviewUrl/merge'), headers: postHeaders);
  return response.statusCode == 200
      ? response.body
      : throw Exception('Error: ${response.statusCode} ${response.body}');
}

closePR(String reviewUrl) async {
  var response = await http.patch(Uri.parse(reviewUrl),
      headers: postHeaders, body: '{"state": "closed"}');
  return response.statusCode == 200
      ? response.body
      : throw Exception('Error: ${response.statusCode} ${response.body}');
}

getDiff(PullRequest pullRequest) async {
  var response = await http.get(Uri.parse(pullRequest.diffUrl));
  return response.body;
}

Future<SemgrepResult> getSemgrepResult(PullRequest pullRequest) async {
  var prUrl = pullRequest.url.substring(0, pullRequest.url.indexOf('pull')) +
      'actions/runs';
  final response = await http.get(Uri.parse(prUrl), headers: headers);
  if (response.statusCode != 200)
    throw Exception('Error: ${response.statusCode}');
  return await _parseWorkflowRunsForPR(pullRequest, response.body);
}

/// Sends a GraphQL query to Github and returns raw response
Future<String> _query(String query) async {
  final gqlQuery = json.encode({'query': _removeSpuriousSpacing(query)});
  final response =
      await http.post(Uri.parse(url), headers: headers, body: gqlQuery);
  return response.statusCode == 200
      ? response.body
      : throw Exception('Error: ${response.statusCode}');
}

/// breaks the paser.dart separation. sorry. I blame GraphQL+GithubActions not
/// being compatible. Parses the json for a set of workflows for a particular
/// repo, and then updates the corresponding pr. if there is a match.
Future<SemgrepResult> _parseWorkflowRunsForPR(
    PullRequest pr, String resBody) async {
  List runs = json.decode(resBody)['workflow_runs'];
  for (var run in runs) {
    for (var a_pr in run['pull_requests']) {
      if (a_pr['url'] == pr.url) {
        // this is the workflow run we want.
        final response =
            await http.get(Uri.parse(run['jobs_url']), headers: headers);
        if (response.statusCode != 200)
          throw Exception('Error: ${response.statusCode}');
        // Just gonna take the first one.... is this okay???
        List jobs = json.decode(response.body)['jobs'];
        var job = jobs[0];
        if (job['conclusion'] == 'failure') {
          final response_url =
              await http.get(Uri.parse(job['url'] + '/logs'), headers: headers);
          if (response_url.statusCode != 200)
            throw Exception('Error: ${response.statusCode}');
          //_parseSemgrepLogs(pr, response_url.body);
          return SemgrepResult(false);
        }
      }
    }
  }
  return SemgrepResult(true);
}

_parseSemgrepLogs(PullRequest pr, String logs) {
  // TODO. not currently used.
  final separator = '===';
  var issues_index =
      logs.indexOf('$separator analyzing new issues in this scan');
  logs.substring(
      issues_index, logs.indexOf(separator, issues_index + separator.length));
}

_removeSpuriousSpacing(String str) => str.replaceAll(RegExp(r'\s+'), ' ');
