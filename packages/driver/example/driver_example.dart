import 'package:driver/driver.dart';

Future<void> main() async {
  final driver = await FluttereniumDriver.init(
    '/*Path to the chrome driver*/',
    DriverType.chrome,
  );
  try {
    print('Driver created');
    driver.open(Uri.parse('https://www.google.com'));
    await Future.delayed(Duration(seconds: 5));
  } finally {
    driver.close(withBrowser: true);
    print('Driver closed');
  }
}
