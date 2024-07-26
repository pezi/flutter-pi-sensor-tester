// Copyright (c) 2024, the Flutter project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';

import '../constants.dart';

class TitleBox extends StatelessWidget {
  final String text;

  const TitleBox({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.fromLTRB(25, 10, 25, 0),
        child: ListTile(
          title: Text(
            text,
            style: gTextLabelStyle,
          ),
        ));
  }
}
