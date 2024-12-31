const gIsolateDebug = false;

/// Raspberry Pi I2C bus number
var gI2C = 1;

int getI2Cbus() {
  return gI2C;
}

void setI2Cbus(int bus) {
  gI2C = bus;
}
