import unittest

from lib import *


class TestMyModule(unittest.TestCase):

    def test_my_function(self):
        driver = FluttereniumDriver(browser_kind=BrowserKind.CHROME)
        driver.open("http://127.0.0.1:5500")

        # Find a element by the text
        app_bar_text = "Flutterenium Plugin example app"
        element = driver.get(By.text(app_bar_text))
        self.assertEqual(element.get_text(), app_bar_text)

        # Find a SVG by the name
        flutter_logo = driver.get(By.svg("flutter_logo.svg$"))
        self.assertTrue(flutter_logo.is_visible())

        # Find a TextField by the hint-text & set some text to it
        text_field = driver.get(By.text("Enter here"))
        text_field_text = "Hello, glad to see you are testing me"
        self.assertTrue(text_field.set_text(text_field_text))

        # Press the button
        show_toast_button = driver.get(By.text("Show as toast"))
        self.assertTrue(show_toast_button.press())

        # Wait till taost will be shown
        self.assertTrue(driver.pump(PumpKind.SETTLE))

        # Find an element by an custom label
        list_view = driver.get(By.label("list-view"))

        # Scroll an element by some pixels
        self.assertTrue(list_view.scroll_by(200, duration=500))
        self.assertTrue(list_view.get(By.text("4")).is_visible())

        # Scroll an element to the very bottom
        self.assertTrue(list_view.scroll_by(-1))
        self.assertTrue(list_view.get(By.text("24")).is_visible())

        # Scroll an element by some pixels in reverse direction
        self.assertTrue(list_view.scroll_by(-200, duration=500))
        self.assertTrue(list_view.get(By.text("20")).is_visible())

        # Scroll an element to very top
        self.assertTrue(list_view.scroll_by(0))
        self.assertTrue(list_view.get(By.text("0")).is_visible())

        # Find preceding sibling
        self.assertEqual(
            text_field.get_text(), show_toast_button.get_preceding_sibling().get_text()
        )
        self.assertNotEqual(
            text_field.get_text(),
            show_toast_button.get_preceding_sibling(skip_gaps=False).get_text(),
        )


if __name__ == "__main__":
    unittest.main()
