import unittest
import time

from lib import *

class TestMyModule(unittest.TestCase):

    def test_my_function(self):
        driver = FluttereniumDriver(browser_kind=BrowserKind.CHROME)
        driver.open("http://127.0.0.1:5500")

        text = "Test the flutterenium plugin"
        element = driver.get(By.text(text))
        self.assertEqual(element.get_text(), text)

        self.assertTrue(element.press())
        time.sleep(5)
        self.assertTrue(driver.pump())
        self.assertTrue(driver.pump(PumpKind.SETTLE))

        element = driver.get(By.label("text-field"))
        self.assertTrue(element.set_text(text))
        self.assertEqual(element.get_text(), text)

        element = driver.get(By.label("list-view"))
        self.assertTrue(element.scroll_by(200, duration=500))
        self.assertTrue(driver.get(By.text("4")).is_visible())

        self.assertTrue(element.scroll_by(-1))
        self.assertTrue(driver.get(By.text("24")).is_visible())

        self.assertTrue(element.scroll_by(-200, duration=500))
        self.assertTrue(driver.get(By.text("20")).is_visible())

        self.assertTrue(element.scroll_by(0))
        self.assertTrue(driver.get(By.text("0")).is_visible())

        element = driver.get(By.svg("https://raw.githubusercontent.com/dnfield/flutter_svg/master/packages/flutter_svg/example/assets/flutter_logo.svg"))
        self.assertTrue(element.is_visible())

        element = driver.get(By.svg("flutter_logo.svg$"))
        self.assertTrue(element.is_visible())


if __name__ == '__main__':
    unittest.main()
