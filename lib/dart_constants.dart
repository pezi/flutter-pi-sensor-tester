const gIsolateDebug = false;

enum Interface { none, i2c, serial, gpio, analog }

/// Supported dashboards
enum DashboardType {
  overview.dummy(),
  demo('clock_v3.png', 'Multi-stream demo'),
  bme680(
      'sensor_v1.png', 'Temperature, Humidity, Pressure, AQI', Interface.i2c),
  bme280('sensor_v3.png', 'Temperature, Humidity, Pressure', Interface.i2c),
  sht31('thermometer_v4.png', 'Temperature', Interface.i2c),
  sgp30('iaq_v1.png', 'Air quality sensor', Interface.i2c),
  cozir('co2_v2.png', 'Serial CO₂,Temperature, Humidity sensor',
      Interface.serial),
  leds('rgb.png', 'GPIO based actuator demo', Interface.gpio),
  gesture('gesture_v2.png', 'Grove gesture sensor', Interface.i2c),
  mcp9808('thermometer_v5.png', 'Temperature', Interface.i2c),
  mlx90615('thermometer_v7.png', 'Temperature', Interface.i2c),
  sdc30('co2_v2.png', 'CO₂, Temperature, Humidity', Interface.i2c),
  si1145('light_v1.png', 'Visible & IR light, UV index', Interface.i2c),
  adc('converter_v1.png', "ADC - Analog to Digital", Interface.analog),
  tsl2591('spectrum_v2.png', 'Lux, Visible, IR, Full spectrum light',
      Interface.i2c);

  const DashboardType.dummy()
      : image = 'dummy.png',
        description = 'dummy',
        interface = Interface.none;
  const DashboardType(this.image, this.description,
      [this.interface = Interface.none]);
  final String image;
  final String description;
  final Interface interface;
}

/// Led colors: red, yellow and green
enum LedColor {
  red(0xFFDC143C),
  yellow(0xFFFFD700),
  green(0xFF98FF98);

  const LedColor(this.color);
  final int color;
}
