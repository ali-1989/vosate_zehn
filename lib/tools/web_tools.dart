import 'dart:html' as html;

class WebTools {

  static Future<List<String>> deviceLocales() async {
    List<String> result = [];
    html.window.navigator.languages?.forEach(result.add);

    return result;
  }

  static Future<String> deviceLocale() async {
    return html.window.navigator.language;
  }
}