import 'package:driver/driver.dart';

void main() {
  FluttereniumDriver.init(
    '/*Path to the chrome driver*/',
    DriverType.chrome,
  );
}
