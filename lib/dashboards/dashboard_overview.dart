// Copyright (c) 2024, the Flutter project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:isolate/constants.dart';

import '../components/overview_box.dart';
import '../main.dart';

class DashboardOverview extends StatefulWidget {
  final ParentUpdateCallback callback;
  const DashboardOverview({super.key, required this.callback});

  @override
  State<DashboardOverview> createState() => _DashboardOverviewState();
}

class _DashboardOverviewState extends State<DashboardOverview> {
  @override
  Widget build(BuildContext context) {
    var list = <Widget>[];
    for (var t in DashboardType.values) {
      if (t == DashboardType.overview) {
        continue;
      }
      list.add(
        InkWell(
          onTap: () {
            setState(() {
              gDashboard = t;
              widget.callback(
                createDashboard(widget.callback),
              );
            });
          },
          child: OverviewBox(
            type: t,
            title: t.name,
            description: t.description,
            image: t.image,
          ),
        ),
      );
    }
    return GridView(
      padding: const EdgeInsets.all(5),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 5,
        crossAxisSpacing: 8,
        mainAxisExtent: 100,
      ),
      children: list,
    );
  }
}
