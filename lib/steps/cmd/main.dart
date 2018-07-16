import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../full_version/github/parsers.dart';
import '../../full_version/github/token.dart';
import '../../full_version/github/utils.dart';

/// For more info on GitHub's GraphQL API, check out: https://developer.github.com/v4/

const url = 'https://api.github.com/graphql';
const headers = {'Authorization': 'bearer $token'};

main() {
  print('Hello World');
}
