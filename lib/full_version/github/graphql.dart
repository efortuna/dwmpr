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
import 'utils.dart';

const url = 'https://api.github.com/graphql';
const headers = {'Authorization': 'bearer $token'};

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
              number
              url
            }
          }
        }
      }
    }''';
  final result = await _query(query);
  return parseOpenPullRequestReviews(result);
}

/// Sends a GraphQL query to Github and returns raw response
Future<String> _query(String query) async {
  final gqlQuery = json.encode({'query': removeSpuriousSpacing(query)});
  final response = await http.post(url, headers: headers, body: gqlQuery);
  return response.statusCode == 200
      ? response.body
      : throw Exception('Error: ${response.statusCode}');
}
