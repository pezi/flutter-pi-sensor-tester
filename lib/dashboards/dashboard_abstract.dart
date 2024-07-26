import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_reorderable_grid_view/widgets/reorderable_builder.dart';

import '../components/error_box.dart';
import '../components/waiting_for_data.dart';
import '../isolates/isolate_helper.dart';

abstract class Dashboard extends StatefulWidget {
  const Dashboard({
    super.key,
    required this.isolateWrapper,
    this.crossAxisCount = 2,
    this.passErrors = false,
  });
  final IsolateWrapper isolateWrapper;
  final int crossAxisCount;
  final bool passErrors;

  Map<int, Widget> buildUI(TaskResult result);

  @override
  State<Dashboard> createState() => _DashboardState();
}

List<int>? _widgetsOrderList;

class _DashboardState extends State<Dashboard> {
  final _gridViewKey = GlobalKey();
  final _scrollController = ScrollController();

  late StreamController<TaskResult> isolateStreamController;

  @override
  void initState() {
    super.initState();
    _widgetsOrderList = null;
    isolateStreamController = startIsolate(widget.isolateWrapper);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        // mention the data source to the stream
        stream: isolateStreamController.stream,
        // context and snapshot is used to capture the data coming from stream
        builder: (context, snapshot) {
          // check the snapshot (hasError, hasData, etc.)
          if (snapshot.hasError) {
            isolateStreamController.close();
            return ErrorBox(
              error: IsolateError.text("Stream exception"),
            );
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return const WaitingForData(); // adaptive make iOS or android circular progress accordingly
          }

          if (snapshot.data!.error && snapshot.data is InitTaskResult) {
            isolateStreamController.close();
            return ErrorBox(error: IsolateError.fromMap(snapshot.data!.data!));
          }

          // TODO: pass errors
          var widgetMap = widget.buildUI(snapshot.data!);

          _widgetsOrderList ??=
              List.generate(widgetMap.length, (index) => index);
          var widgets = <Widget>[];
          for (int index in _widgetsOrderList!) {
            widgets.add(widgetMap[index]!);
          }

          return ReorderableBuilder(
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
        });
  }
}
