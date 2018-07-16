import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../full_version/github/parsers.dart';
import '../../full_version/github/token.dart';
import '../../full_version/github/utils.dart';

/// For more info on GitHub's GraphQL API, check out: https://developer.github.com/v4/

const url = 'https://api.github.com/graphql';
const headers = {'Authorization': 'bearer $token'};

main() async {
  print(await user('efortuna'));
}

user(String login) async {
  final query = '''
    query {
      user(login: "$login") {
        login
        name
        avatarUrl
      }
    }
  ''';

  final res = await http.post(
    url,
    headers: headers,
    body: json.encode({'query': removeSpuriousSpacing(query)}),
  );

  return parseUser(res.body);
}
