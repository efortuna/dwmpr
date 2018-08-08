// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

class User {
  final String login;
  final String name;
  final String avatarUrl;

  User(this.login, this.name, this.avatarUrl);

  @override
  String toString() =>
      'USER:\n{login: $login, name: $name, avatar: $avatarUrl}';

  @override
  bool operator ==(u) =>
      u is User &&
      u.login == login &&
      u.name == name &&
      u.avatarUrl == avatarUrl;

  @override
  int get hashCode => login.hashCode + name.hashCode + avatarUrl.hashCode;
}
