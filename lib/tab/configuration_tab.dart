// Copyright (c) 2024, the Flutter project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:isolate/constants.dart';

import '../components/info_box.dart';
import '../components/title_box.dart';
import '../isolates/isolate_helper.dart';
import '../main.dart';

// MonoFonts dropdownValue = MonoFonts.jetBrainsMono;
MonoFonts _font = MonoFonts.jetBrainsMono;

class ConfigurationTab extends StatefulWidget {
  const ConfigurationTab({super.key, required this.callback});
  final ParentUpdateCallback callback;

  @override
  State<ConfigurationTab> createState() => _ConfigurationTabState();
}

class _ConfigurationTabState extends State<ConfigurationTab> {
  Column fontsList() {
    var list = <Widget>[];
    for (MonoFonts f in MonoFonts.values) {
      list.add(
        ListTile(
          title: Text(f.label),
          leading: Radio<MonoFonts>(
            value: f,
            groupValue: _font,
            onChanged: (MonoFonts? value) {
              setState(() {
                _font = value!;
              });
              gMonoFontName = _font.name;
              rebuildFont();
            },
          ),
        ),
      );
    }
    return Column(children: list);
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: gBulletColor,
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var list = <Widget>[
      const TitleBox(text: 'Program control'),
      const SizedBox(
        height: 5,
      ),
      CheckboxListTile(
        controlAffinity: ListTileControlAffinity.leading,
        title: const Text("Demo mode"),
        value: gSimulateSensor,
        onChanged: (bool? value) {
          setState(() {
            gSimulateSensor = value!;
          });
        },
      ),
      ElevatedButton(
        onPressed: () {
          if (gDashboard != DashboardType.demo &&
              gDashboard != DashboardType.overview) {
            IsolateHelper ih = getByIsolateId(gDashboard.name) as IsolateHelper;
            ih.sendPort?.send("exit");
            showSnackBar('App is closing all interfaces...');
          } else {
            exit(0);
          }
        },
        style: ElevatedButton.styleFrom(
          foregroundColor: gTextColor,
          backgroundColor: gInfoBoxBackground,
          // padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
          textStyle: gTextStyle,
        ),
        child: const Text('Quit program'),
      ),
      const SizedBox(
        height: 15,
      ),
      if (gDashboard != DashboardType.overview)
        ElevatedButton(
          onPressed: () {
            // terminate all running isolates by sending 'quit'
            if (gDashboard == DashboardType.demo) {
              // this demo owns 3 separate isolates
              for (var i = 1; i <= 3; ++i) {
                IsolateHelper ih = getByIsolateId('demo$i') as IsolateHelper;
                removeIsolateFromCache(ih.isolateId);
                ih.sendPort?.send("quit");
              }
            } else {
              IsolateHelper ih =
                  getByIsolateId(gDashboard.name) as IsolateHelper;
              removeIsolateFromCache(ih.isolateId);
              ih.sendPort?.send("quit");
            }

            showSnackBar('Demo is closing all interfaces...');

            setState(() {
              gDashboard = DashboardType.overview;
              widget.callback(
                createDashboard(widget.callback),
              );
            });
          },
          style: ElevatedButton.styleFrom(
            foregroundColor: gTextColor,
            backgroundColor: gInfoBoxBackground,
            // padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
            textStyle: gTextStyle,
          ),
          child: const Text('Quit running demo'),
        ),
    ];

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(4),
        child: InfoBox(
          height: 400,
          width: 630,
          child: Row(
            children: [
              SizedBox(
                width: 300,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: list,
                ),
              ),
              SizedBox(
                width: 300,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const TitleBox(text: 'Font'),
                    const SizedBox(
                      height: 5,
                    ),
                    fontsList()
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
