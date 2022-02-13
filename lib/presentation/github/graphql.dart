// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'parsers.dart';
import 'pullrequest.dart';
import 'package:dwmpr/full_version/github/token.dart';
import 'user.dart';

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
      search(query: "type:pr state:open review-requested:$login", type: ISSUE, first: 100) {
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

/// Sends a GraphQL query to Github and returns raw response
Future<String> _query(String query) async {
  final gqlQuery = json.encode({'query': _removeSpuriousSpacing(query)});
  final response =
      await http.post(Uri.parse(url), headers: headers, body: gqlQuery);
  return response.statusCode == 200
      ? response.body
      : throw Exception('Error: ${response.statusCode}');
}

_removeSpuriousSpacing(String str) => str.replaceAll(RegExp(r'\s+'), ' ');
