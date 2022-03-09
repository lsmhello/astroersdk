import 'dart:convert';

import 'package:astroer/api.dart';
import 'package:astroer/astroer.dart';

import 'log.dart';

const eventRecvRegisterResult = 1;
const eventRecvNotification = 2;
const eventClickedNotification = 3;

class Event {
  static final Map<int, List<EventHandler>> _handlers = {
    eventRecvRegisterResult: [],
    eventRecvNotification: [],
    eventClickedNotification: [],
  };

  static bool addHandler(EventHandler handler, int event) {
    if (!_handlers.containsKey(event)) {
      return false;
    }

    for (var k in _handlers[event]!) {
      if (k == handler) {
        return true;
      }
    }

    _handlers[event]!.add(handler);

    return true;
  }

  static void onRecvRegisterResult(dynamic params) {
    // var logger = Log.logger();
    // var map = params as Map;
    // map.forEach((key, value) {
    //   logger.i("$key === $value");
    // });

    API.register();

    for (var handler in _handlers[eventRecvRegisterResult]!) {
      handler(params);
    }
  }

  static void onRecvNotification(dynamic notification) {
    var n = notifi(notification);

    Log.logger().i("onRecvNotification:", n);

    for (var handler in _handlers[eventRecvNotification]!) {
      handler(n);
    }
  }

  static void onClickedNotification(dynamic notification) {
    // Log.logger().i("onClickedNotification:", notification);

    var n = notifi(notification);
    Log.logger().i("onClickedNotification:", n);

    for (var handler in _handlers[eventClickedNotification]!) {
      handler(n);
    }
  }

  /// {
  ///  "id": "",
  ///  "title": "",
  ///  "json": "json string"
  ///     {
  ///       "action": "xxx"
  ///       "params": xxx
  ///     }
  /// }
  static Map<String, dynamic> notifi(dynamic notification) {
    Map<String, dynamic> notifi = {};
    if (notification is Map) {
      notifi["id"] = notification["id"];
      notifi["title"] = notification["title"];

      var jv = json.decode(notification["json"]);
      if (jv is Map) {
        notifi["action"] = jv["action"];
        notifi["params"] = jv["params"];
      }
    }

    return notifi;
  }
}
