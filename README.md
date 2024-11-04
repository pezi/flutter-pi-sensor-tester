# flutter_pi_sensor_tester

This project is built upon [dart_periphery](https://github.com/pezi/dart_periphery) and [flutter-pi](https://github.com/ardera/flutter-pi) for running Flutter on the 
Raspberry Pi.

UI-Overview 

![alt text](https://raw.githubusercontent.com/pezi/dart_periphery_img/main/flutter_sensor_tester.gif "Flutter Sensor Tester")

Test setup with a Raspberry Pi 3 with attached LEDs, sensors and a small touch screen running the 
led demo.

![alt text](https://github.com/pezi/dart_periphery_img/blob/main/touch_screen_small.jpg?raw=true "Touch screen")

[Video snippet for reordering UI elements](https://github.com/pezi/dart_periphery_img/raw/main/reoder.mp4)

## Overview

This subproject of [dart_periphery](https://pub.dev/packages/dart_periphery) based 
on [flutter-pi](https://github.com/ardera/flutter-pi) implements an isolate/stream architecture 
designed to transfer sensor data from an isolate to the Flutter UI. 

**Isolate Interface**: This consists of the steps InitTask, MainTask, and ExitTask, along with a 
limited back channel for controlling the isolate. This setup is typically used for sensor 
measurements:
* `InitTask`: Initializes the sensor.
* `MainTask`: Collects sensor data and passes it to a stream.
* `ExitTask`: Disposes of the sensor.

**Listening Mode**: Features `InitTask` and user-defined handling for isolate events. This variant 
remains on standby for data; once data is processed, the result is passed to the stream and 
subsequently to the Flutter UI. This model is used for actuator control, such as operating an LED.

**Support for Multiple Streams**: Enables handling of multiple data streams simultaneously.

**Import hints:**
* The project is currently in its early stages, and development is ongoing including API changes.
* For using real hardware, go to the configuration panel and disable the simulation mode checkbox.
* Application can be build for the other Flutter desktop variants: MacOS, Windows and Linux and 
tested in the simulation mode.
* Dart isolates can be tricky compared to programming languages like Java. Therefore, the first 
version of the API may appear somewhat unrefined and incomplete.
* The project code is free to use, but be aware, the icons from [Flaticon](https://www.flaticon.com) must attribute
the creator of the icon - for further details see the AboutTab with an automated list of used 
icons including their attribution link.
* Used colors looks on your device perhaps a little strange. This demo was tested on a small 
external touch screen with a limited color dynamic. The used colors are result of this restriction.

**Known problems:**
To avoid application crashes when using Dart periphery methods within an isolate, it’s essential to 
call `reuseTmpFileLibrary(true)` before any periphery method invocations.

```
reuseTmpFileLibrary(true);
i2c = I2C(gI2C);
sgp30 = SGP30(i2c);
```

Dart periphery temporarily stores a copy of the c-periphery library in the system’s temp directory. 
If an isolate attempts this initialization again without the reuseTmpFileLibrary(true) setting, it 
will cause the application to crash, with no opportunity to catch the error. 

As an alternative solution, you can use
`void loadLibFromFlutterAssetDir(bool load)`  to address this issue.
For more details, refer to the documentation [here](https://github.com/pezi/dart_periphery?tab=readme-ov-file#flutter-pi).  

**Starting**
The isolate related code can be found here:

* [isolate_helper.dart](https://github.com/pezi/flutter-pi-sensor-tester/blob/main/lib/isolates/isolate_helper.dart)
* [isolate_factory.dart](https://github.com/pezi/flutter-pi-sensor-tester/blob/main/lib/isolates/isolate_factory.dart)


**Next steps:**
* Improve documentation
* Extend this demo to use a Flutter state management library like [riverpod](https://pub.dev/packages/riverpod)
* **TBD**: Extend the isolate API for code generation support to reduce manual coding. 
