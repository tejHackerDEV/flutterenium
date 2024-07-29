import 'package:driver/driver.dart';

Future<void> main() async {
  FluttereniumDriver? driver;
  try {
    driver = await FluttereniumDriver.init('path_to_chrome_executable');
    print('Driver created');

    await driver.open(Uri.parse('http://127.0.0.1:5500/'));
    print('Page opened');

    Future<void> wait() async {
      await Future.delayed(const Duration(seconds: 2));
    }

    final tester = MyTester(driver);
    await tester.checkGetText('Test the flutterenium plugin');

    await wait();
    await tester.checkSetText('text-field', 'Testing Flutterenium plugin');

    await wait();
    await tester.checkScroll('list-view', -1, '24');

    await wait();
    await tester.checkScroll('list-view', 0, '0');

    await wait();
    await tester.checkClick('Test the flutterenium plugin');

    await wait();
    print('All test cases passed');
  } catch (error, stackTrace) {
    print(error);
    print(stackTrace);
  } finally {
    await driver?.close(withBrowser: true);
    print('Driver closed');
  }
}

class MyTester {
  final FluttereniumDriver _driver;

  MyTester(this._driver);

  Future<void> checkGetText(String text) async {
    final textElement = _driver.get(By.text(text));
    assert(await textElement.find());
    assert(await textElement.getText() == text);
  }

  Future<void> checkSetText(String label, String text) async {
    final textFieldElement = _driver.get(By.label(label));
    assert(await textFieldElement.setText(text));
    assert(await textFieldElement.getText() == text);
  }

  Future<void> checkScroll(
    String label,
    double delta,
    String textToDetect,
  ) async {
    final scrollableElement = _driver.get(By.label(label));
    final textElement = _driver.get(By.text(textToDetect));
    assert(!(await textElement.isVisible()));
    assert(await scrollableElement.scrollBy(delta));
    assert(await textElement.isVisible());
  }

  Future<void> checkClick(String text) async {
    final textElement = _driver.get(By.text(text));
    assert(await textElement.click());
  }
}
