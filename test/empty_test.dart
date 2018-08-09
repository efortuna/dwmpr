// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:dwmpr/full_version/github/parsers.dart';
import 'package:dwmpr/full_version/github/token.dart';
import 'package:dwmpr/full_version/github/utils.dart';

/// For more info on GitHub's GraphQL API, check out: https://developer.github.com/v4/

const url = 'https://api.github.com/graphql';
const headers = {'Authorization': 'bearer $token'};

void main() {
  test('Lets test us some GraphQL!', () async {
    expect(true, true);
  });
}
