import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:dwmpr/github/token.dart';
import 'package:dwmpr/github/user.dart';
import 'package:dwmpr/github/serializers.dart';

const url = 'https://api.github.com/graphql';
const headers = {'Authorization': 'bearer $token'};

/// Sends a GraphQL query to Github and returns raw response
Future<String> _makeCall(String query) async {
  // GraphQL doesn't like returns; strip them out
  final gqlQuery = '{"query": "$query"}'.replaceAll(RegExp(r'\n'), '');
  final response = await http.post(url, headers: headers, body: gqlQuery);
  if (response.statusCode == 200)
    return response.body;
  else
    throw Exception('Error: ${response.statusCode}');
}

/// Fetches user data from Github
Future<User> user() async {
  const query = '''
    query {
      viewer {
        login
        name
        location
        company
        avatarUrl
      }
    }''';
  final result = await _makeCall(query);
  final parsedResult = json.decode(result);
  final user = serializers.deserializeWith(
      User.serializer, parsedResult['data']['viewer']);
  return user;
}

/// Fetches user repo data from Github
Future<String> repos() async {
  const query = '''
    query {
      viewer {
        name
        repositories(last: 5) {
          nodes {
            name
            labels(first:5) {
              edges {
                node {
                  name
                }
              }          
            }
          }
        }
      }
    }
''';
  final result = await _makeCall(query);
  final parsedResult = json.decode(result);
  return result;
}
