import 'dart:html' as html;

import 'package:flutter/foundation.dart';

void changeAddressBar(String url, {dynamic data, bool reload = false}) {
  //final location = '${html.window.location.protocol}//${html.window.location.host + (html.window.location.pathname?? '')}';
  // html.window.location.href == location
  /// html.window.location.href = location   : this is reload page
  if(!kIsWeb) {
    return;
  }

  data ??= html.window.history.state;

  if(!url.toLowerCase().startsWith(html.document.baseUri?? '')){
    var old = html.window.location.href;

    if(old.endsWith('/')){
      old = old.substring(0, old.length -1);
    }

    url = '$old/$url';
  }

  if(reload) {
    // can press Back button
    html.window.history.pushState(data, '', url);
  }
  else {
    // can not press Back button
    html.window.history.replaceState(data, '', url);
  }
}

void clearAddressBar(String? part) {
  if(part == null) {
    final location = '${html.window.location.protocol}//${html.window.location.host}/';
    html.window.history.replaceState(html.window.history.state, '', location);
  }
  else {
    String url = html.window.location.href;
    int lIdx = url.lastIndexOf(part);

    if(lIdx < 0){
      return;
    }

    url = url.replaceFirst(part, '', lIdx);

    if(url.endsWith('//')){
      url = url.substring(0, url.length -1);
    }

    html.window.history.replaceState(html.window.history.state, '', url);
  }
}

String getBaseWebAddress() {
  return html.document.baseUri?? '';
}

void backAddressBar() {
  html.window.history.back();
}

String getCurrentWebAddress() {
  return html.window.location.href;
}
