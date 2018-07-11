// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';

import 'package:dwmpr/full_version/github/graphql.dart';
import 'package:dwmpr/full_version/github/parsers.dart';
import 'package:dwmpr/full_version/github/user.dart';

void main() {
  test('Test parsing a JSON user query response', () {
    // Response from user query
    final responseBody = '''
    {"data":
      {"user":
        {
          "login": "mjohnsullivan",
          "name":"Matt Sullivan",
          "avatarUrl":"https://avatars3.githubusercontent.com/u/102488?v=4"
        }
      }
    }''';
    final parsedUser = parseUser(responseBody);
    final expectedUser = User((u) => u
      ..name = 'Matt Sullivan'
      ..login = 'mjohnsullivan'
      ..avatarUrl = 'https://avatars3.githubusercontent.com/u/102488?v=4');

    expect(parsedUser, expectedUser);
  });

  test('Test parsing a JSON current user query response', () {
    // Response from current user query
    final responseBody = '''
    {"data":
      {"viewer":
        {
          "login":"mjohnsullivan",
          "name":"Matt Sullivan",
          "location":"London",
          "company":"",
          "avatarUrl":"https://avatars3.githubusercontent.com/u/102488?v=4"
        }
      }
    }''';
    final parsedUser = parseUser(responseBody);
    final expectedUser = User((u) => u
      ..name = 'Matt Sullivan'
      ..login = 'mjohnsullivan'
      ..avatarUrl = 'https://avatars3.githubusercontent.com/u/102488?v=4'
      ..location = 'London'
      ..company = '');

    expect(parsedUser, expectedUser);
  });
}
