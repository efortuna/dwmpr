// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// Collection of utility functions

/// Pretty prints numbers
String prettyPrintInt(int num) =>
    (num >= 1000) ? (num / 1000.0).toStringAsFixed(1) + 'k' : '$num';
