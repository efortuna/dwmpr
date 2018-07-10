// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

class Repository {
  final String name;
  final String url;
  final int starCount;

  Repository(this.name, this.url, this.starCount);

  String toString() => '$name, $url, $starCount';
}