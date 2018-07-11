// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:built_value/standard_json_plugin.dart';
import 'package:built_value/serializer.dart';

import 'user.dart';

part 'serializers.g.dart';

@SerializersFor(const [
  User,
])
final Serializers serializers =
    (_$serializers.toBuilder()..addPlugin(StandardJsonPlugin())).build();
