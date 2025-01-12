// Copyright (c) 2024, the Flutter project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';

import '../constants.dart';

import '../isolates/isolate_helper.dart';
import 'info_box.dart';

/// Box displaying errors.
class ErrorBox extends StatelessWidget {
  final IsolateError error;
  final bool scaffold;

  /// Creates a box for displaying an [error], optional with a
  /// parent [scaffold].
  const ErrorBox({super.key, required this.error, this.scaffold = false});

  @override
  Widget build(BuildContext context) {
    var widget = Center(
      child: InfoBox(
        width: 450,
        height: 320,
        child: Center(
          child: Column(
            children: [
              const Center(
                child: Icon(
                  Icons.error_outline_rounded,
                  size: 90,
                  color: gErrorTextColor,
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              Text(
                'An error occurred during phase ${error.method.name}',
                style: gErrorInfoTextStyle.copyWith(color: gErrorTextColor),
              ),
              const SizedBox(
                height: 8,
              ),
              Text(
                error.error,
                style: gErrorInfoTextStyle,
              )
            ],
          ),
        ),
      ),
    );
    if (scaffold) {
      return Scaffold(body: widget);
    }
    return widget;
  }
}
