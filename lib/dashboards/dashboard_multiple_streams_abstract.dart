// Copyright (c) 2024, the Flutter project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_reorderable_grid_view/widgets/reorderable_builder.dart';
import 'package:multiple_stream_builder/multiple_stream_builder.dart';

import '../isolates/isolate_helper.dart';

List<int>? _widgetsOrderList;

abstract class DashboardMultipleStreams extends StatefulWidget {
  final List<IsolateWrapper> isolateWrappers;
  final List<InitTaskResult> initResults;
  final int crossAxisCount;
  DashboardMultipleStreams({
    super.key,
    required this.isolateWrappers,
    required this.initResults,
    this.crossAxisCount = 2,
  }) {
    if (isolateWrappers.isEmpty) {
      throw ArgumentError("isolateWrappers can not be empty");
    }
    if (initResults.isEmpty) {
      throw ArgumentError("initResults can not be empty");
    }

    if (isolateWrappers.length != initResults.length) {
      throw ArgumentError(
          "isolateWrappers initResults must have the same size");
    }
    if (!(isolateWrappers.length > 1 && isolateWrappers.length <= 5)) {
      throw ArgumentError(
          "stream number range error: $isolateWrappers.length is not in the range [2-5] ");
    }
  }

  Map<int, Widget> buildUI(List<TaskResult> result);

  @override
  State<DashboardMultipleStreams> createState() =>
      _DashboardMultipleStreamsState();
}

class _DashboardMultipleStreamsState extends State<DashboardMultipleStreams> {
  final List<StreamController<TaskResult>> controllers = [];
  final _gridViewKey = GlobalKey();
  final _scrollController = ScrollController();

  ReorderableBuilder buildGrid(Map<int, Widget> widgetMap) {
    _widgetsOrderList ??= List.generate(widgetMap.length, (index) => index);
    var widgets = <Widget>[];
    for (int index in _widgetsOrderList!) {
      widgets.add(widgetMap[index]!);
    }

    return ReorderableBuilder(
      scrollController: _scrollController,
      onReorder: (ReorderedListFunction reorderedListFunction) {
        setState(() {
          _widgetsOrderList =
              reorderedListFunction(_widgetsOrderList as List<int>)
                  as List<int>;
        });
      },
      builder: (children) {
        return GridView(
          key: _gridViewKey,
          controller: _scrollController,
          padding: const EdgeInsets.all(5),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: widget.crossAxisCount,
            mainAxisSpacing: 5,
            crossAxisSpacing: 8,
            mainAxisExtent: 150,
          ),
          children: children,
        );
      },
      children: widgets,
    );
  }

  @override
  void initState() {
    super.initState();
    _widgetsOrderList = null;
    for (var w in widget.isolateWrappers) {
      controllers.add(startIsolate(w));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isolateWrappers.length == 2) {
      return StreamBuilder2<TaskResult, TaskResult>(
          streams: StreamTuple2(controllers[0].stream, controllers[1].stream),
          initialData: InitialDataTuple2(
            widget.initResults[0],
            widget.initResults[1],
          ),
          builder: (context, snapshots) {
            return buildGrid(widget.buildUI(
                [snapshots.snapshot1.data!, snapshots.snapshot2.data!]));
          });
    } else if (widget.isolateWrappers.length == 3) {
      return StreamBuilder3<TaskResult, TaskResult, TaskResult>(
          streams: StreamTuple3(controllers[0].stream, controllers[1].stream,
              controllers[2].stream),
          initialData: InitialDataTuple3(
            widget.initResults[0],
            widget.initResults[1],
            widget.initResults[2],
          ),
          builder: (context, snapshots) {
            return buildGrid(widget.buildUI([
              snapshots.snapshot1.data!,
              snapshots.snapshot2.data!,
              snapshots.snapshot3.data!
            ]));
          });
    } else if (widget.isolateWrappers.length == 4) {
      return StreamBuilder4<TaskResult, TaskResult, TaskResult, TaskResult>(
          streams: StreamTuple4(controllers[0].stream, controllers[1].stream,
              controllers[2].stream, controllers[3].stream),
          initialData: InitialDataTuple4(
            widget.initResults[0],
            widget.initResults[1],
            widget.initResults[2],
            widget.initResults[3],
          ),
          builder: (context, snapshots) {
            return buildGrid(widget.buildUI([
              snapshots.snapshot1.data!,
              snapshots.snapshot2.data!,
              snapshots.snapshot3.data!,
              snapshots.snapshot4.data!
            ]));
          });
    } else if (widget.isolateWrappers.length == 5) {
      return StreamBuilder5<TaskResult, TaskResult, TaskResult, TaskResult,
              TaskResult>(
          streams: StreamTuple5(
              controllers[0].stream,
              controllers[1].stream,
              controllers[2].stream,
              controllers[3].stream,
              controllers[4].stream),
          initialData: InitialDataTuple5(
            widget.initResults[0],
            widget.initResults[1],
            widget.initResults[2],
            widget.initResults[3],
            widget.initResults[4],
          ),
          builder: (context, snapshots) {
            return buildGrid(widget.buildUI([
              snapshots.snapshot1.data!,
              snapshots.snapshot2.data!,
              snapshots.snapshot3.data!,
              snapshots.snapshot4.data!,
              snapshots.snapshot5.data!
            ]));
          });
    }

    // TODO display error
    return const Placeholder();
  }
}
