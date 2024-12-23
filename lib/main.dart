// Copyright (c) 2024, the Flutter project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:isolate/components/error_box.dart';
import 'package:isolate/dashboards/dashboard_bme680.dart';
import 'package:isolate/dashboards/dashboard_cozir.dart';
import 'package:isolate/dashboards/dashboard_gesture.dart';
import 'package:isolate/dashboards/dashboard_hat_adc.dart';
import 'package:isolate/dashboards/dashboard_leds.dart';
import 'package:isolate/dashboards/dashboard_overview.dart';
import 'package:isolate/isolates/isolate_cozir.dart';
import 'package:isolate/isolates/isolate_hat_adc.dart';
import 'package:isolate/isolates/isolate_leds.dart';
import 'package:isolate/tab/about_tab.dart';
import 'package:isolate/tab/configuration_tab.dart';
import 'package:window_manager/window_manager.dart';

import 'components/sensor_image_info.dart';
import 'components/waiting_for_data.dart';
import 'constants.dart';
import 'dashboards/dashboard_bme280.dart';
import 'dashboards/dashboard_demo.dart';
import 'dashboards/dashboard_mcp9808.dart';
import 'dashboards/dashboard_mlx90615.dart';
import 'dashboards/dashboard_sdc30.dart';
import 'dashboards/dashboard_sgp30.dart';
import 'dashboards/dashboard_sht31.dart';
import 'dashboards/dashboard_si1145.dart';
import 'dashboards/dashboard_tsl2591.dart';
import 'isolates/isolate_bme280.dart';
import 'isolates/isolate_bme680.dart';
import 'isolates/isolate_demo.dart';
import 'isolates/isolate_gesture.dart';
import 'isolates/isolate_helper.dart';
import 'isolates/isolate_mcp9808.dart';
import 'isolates/isolate_mlx90615.dart';
import 'isolates/isolate_sdc30.dart';
import 'isolates/isolate_sgp30.dart';
import 'isolates/isolate_sht31.dart';
import 'isolates/isolate_si1145.dart';
import 'isolates/isolate_tsl2591.dart';

void main() async {
  // Sets the size of the desktop app to a fixed size to enable making
  // screenshots with the same size.
  if (Platform.isWindows || Platform.isMacOS) {
    WidgetsFlutterBinding.ensureInitialized();
    await windowManager.ensureInitialized();
    WindowManager.instance.setMinimumSize(const Size(1000, 600));
    WindowManager.instance.setMaximumSize(const Size(1000, 600));
  }

  runApp(const SensorApp());
}

const String appTitle = 'Flutter Sensor Tester';

class SensorApp extends StatelessWidget {
  const SensorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: appTitle,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E2041),
        ),
        useMaterial3: true,
      ),
      home: const SensorDemoPage(title: appTitle),
    );
  }
}

class SensorDemoPage extends StatefulWidget {
  const SensorDemoPage({super.key, required this.title});
  final String title;

  @override
  State<SensorDemoPage> createState() => _SensorDemoPageState();
}

typedef ParentUpdateCallback = void Function(Widget widget);

Widget createDashboard(ParentUpdateCallback callback) {
  return Banner(
    message: gSimulateSensor ? "Simulation" : "Hardware",
    location: BannerLocation.topStart,
    child: _createDashboard(callback),
  );
}

/// _
Widget _createDashboard(ParentUpdateCallback callback) {
  switch (gDashboard) {
    case DashboardType.demo:
      return DashboardDemo(
        isolateWrappers: [
          DemoIsolate("demo1", 1),
          DemoIsolate("demo2", 15),
          DemoIsolate("demo3", 20)
        ],
        initResults: [
          InitTaskResult('', {"counter": 1, "duration": 1}),
          InitTaskResult('', {"counter": 1, "duration": 15}),
          InitTaskResult('', {"counter": 1, "duration": 30}),
        ],
      );
    case DashboardType.bme680:
      return DashboardBME680(
        isolateWrapper:
            BME680isolate(DashboardType.bme680.name, gSimulateSensor),
      );
    case DashboardType.bme280:
      return DashboardBME280(
        isolateWrapper:
            BME280isolate(DashboardType.bme280.name, gSimulateSensor),
      );
    case DashboardType.sht31:
      return DashboardSHT31(
        isolateWrapper: SHT31isolate(DashboardType.sht31.name, gSimulateSensor),
      );
    case DashboardType.mcp9808:
      return DashboardMCP9808(
        isolateWrapper:
            MCP9808isolate(DashboardType.mcp9808.name, gSimulateSensor),
      );
    case DashboardType.mlx90615:
      return DashboardMLX90615(
        isolateWrapper:
            MLX90615isolate(DashboardType.mlx90615.name, gSimulateSensor),
      );
    case DashboardType.sdc30:
      return DashboardSDC30(
        isolateWrapper: SDC30isolate(DashboardType.sdc30.name, gSimulateSensor),
      );
    case DashboardType.gesture:
      return DashboardGesture(
        isolateWrapper:
            GestureDetectorIsolate(DashboardType.gesture.name, gSimulateSensor),
      );
    case DashboardType.sgp30:
      return DashboardSGP30(
        isolateWrapper: SGP30isolate(DashboardType.sgp30.name, gSimulateSensor),
      );
    case DashboardType.cozir:
      return DashboardCozIR(
        isolateWrapper: CozIRisolate(DashboardType.cozir.name, gSimulateSensor),
      );
    case DashboardType.leds:
      return DashboardLeds(
        isolateWrapper: LedsIsolate(DashboardType.leds.name, gSimulateSensor),
      );
    case DashboardType.si1145:
      return DashboardSI1145(
        isolateWrapper:
            SI1145isolate(DashboardType.si1145.name, gSimulateSensor),
      );
    case DashboardType.overview:
      return DashboardOverview(callback: callback);
    case DashboardType.adc:
      return DashboardHatADC(
          isolateWrapper:
              HatADCisolate(DashboardType.adc.name, gSimulateSensor));
    case DashboardType.tsl2591:
      return DashboardTSL2591(
          isolateWrapper: TSL2591isolate(gDashboard.name, gSimulateSensor));
  }
}

class _SensorDemoPageState extends State<SensorDemoPage> {
  final List<Widget> _tabs = <Widget>[];
  final _appBarKey = GlobalKey<ConvexAppBarState>();
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    _tabs.add(
      createDashboard(setDemoCallback),
    );
    _tabs.add(ConfigurationTab(
      callback: setDemoCallback,
    ));
    _tabs.add(const AboutTab());
    initSensorImages();
  }

  /// Changes the current demo or overview to another [demo] by an callback
  /// by a child widget. The child updates the parent.
  void setDemoCallback(Widget demo) {
    setState(() {
      // dashboard tab
      _tabs[0] = demo;
      if (_selectedIndex != 0) {
        _selectedIndex = 0;
      }
      _appBarKey.currentState?.animateTo(_selectedIndex);
    });
    // force dashboard tab
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int>(
        future: initSensorImages(),
        builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
          if (snapshot.hasError) {
            return ErrorBox(
              error: IsolateError.text("Error during loading assets"),
              scaffold: true,
            );
          } else if (snapshot.hasData) {
            return Scaffold(
                backgroundColor: gBackgroundColor,
                body: _tabs[_selectedIndex],
                // https://pub.dev/packages/convex_bottom_bar#theming
                bottomNavigationBar: ConvexAppBar(
                  key: _appBarKey,
                  initialActiveIndex: _selectedIndex,
                  backgroundColor: gNavBarBackgroundColor,
                  shadowColor: gNavBarShadowBackground,
                  //style: TabStyle.fixedCircle,
                  items: const [
                    // home
                    TabItem(icon: Icons.dashboard_rounded, title: 'Dashboard'),
                    TabItem(icon: Icons.settings, title: 'Configuration'),
                    TabItem(icon: Icons.info, title: 'About'),
                  ],
                  //  initialActiveIndex: 0,
                  onTap: _onItemTapped,
                ));
          } else {
            return const WaitingForData(
              scaffold: true,
            );
          }
        });
  }
}
