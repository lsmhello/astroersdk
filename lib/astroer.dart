import 'dart:async';

import 'package:astroer/tool.dart';
import 'package:flutter/services.dart';
import 'signaling.dart';
import 'config.dart';
import 'log.dart';
import 'event.dart';
import 'api.dart';

import 'package:sp_util/sp_util.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:notification_permissions/notification_permissions.dart';

// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:package_info_plus/package_info_plus.dart';
// import 'package:uuid/uuid.dart';

const int astroerEnvDev = 1;
const int astroerEnvProd = 2;

typedef EventHandler = void Function(dynamic);

class Astroer {
  static const MethodChannel _channel = MethodChannel('astroer');
  static const String astroerVersion = '0.0.1 dev';

  static init(int env, int appId) async {
    if (env != 1 && env != 2) {
      AstroerConfig.env = env;
      Log.logger().e("unkown env value.");
      return;
    }

    AstroerConfig.appId = appId;

    _channel.setMethodCallHandler(astroerChannelHandleMethod);
    await SpUtil.getInstance();
  }

  static Future<dynamic> astroerChannelHandleMethod(MethodCall call) async {
    if (call.method == "OnReceiveRegisterResult") {
      Event.onRecvRegisterResult(call.arguments);
    } else if (call.method == "OnRecvNotification") {
      Event.onRecvNotification(call.arguments);
    } else if (call.method == "OnClickedNotification") {
      Event.onClickedNotification(call.arguments);
    } else {
      Log.logger().i("Unknow Method:" + call.method, call.arguments);
    }
  }

  static setEnv(int env) {
    AstroerConfig.env = env;
  }

  static setAppId(int appId) {
    AstroerConfig.appId = appId;
  }

  static setAppUser(int appUid, String secret) {
    AstroerConfig.appUid = appUid;
    AstroerConfig.secret = secret;
  }

  static Future<Device?> get device async {
    final Map? result = await _channel.invokeMethod('device');
    if (result == null) {
      return null;
    }

    var d = Device(result["brand"], result["name"], result["os"]);
    d.id = Tool.getDeviceId();
    d.credentials = Map<String, String>.from(result["credentials"]);
    d.infomations = Map<String, String>.from(result["informations"]);

    Map<String, String> imap = {};
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

    try {
      IosDeviceInfo iosinfo = await deviceInfo.iosInfo;
      iosinfo.toMap().forEach((key, value) {
        imap[key] = value.toString();
      });
    } catch (_) {}

    try {
      AndroidDeviceInfo andinfo = await deviceInfo.androidInfo;
      andinfo.toMap().forEach((key, value) {
        imap[key] = value.toString();
      });
      imap.remove("systemFeatures");
    } catch (_) {}

    imap.forEach((key, value) {
      d.infomations[key] = value;
    });

    return d;
  }

  static Future<bool> getNotificationPermissionStatus() async {
    var permissionStatus = await NotificationPermissions.getNotificationPermissionStatus();
    var r = permissionStatus == PermissionStatus.granted || permissionStatus == PermissionStatus.provisional;
    return r;
  }

  static requestNotificationPermissions() {
    NotificationPermissions.requestNotificationPermissions().then((status) {
      if (status == PermissionStatus.granted || status == PermissionStatus.provisional) {
        registration();
      }
    });
  }

  static Future<bool> registration() async {
    // var connectivityResult = await (Connectivity().checkConnectivity());
    // if (connectivityResult == ConnectivityResult.none) {
    //   return;
    // }

    bool result = await _channel.invokeMethod('registration', {
      "xiaomi": {"appId": AstroerConfig.xiaomi.appId, "key": AstroerConfig.xiaomi.key},
      "huawei": {"appId": AstroerConfig.huawei.appId},
    });
    return result;
  }

  static setBadge(int badge) async {
    await _channel.invokeMethod('setBadge', badge);
  }

  static unregistration() async {
    Log.logger().i("unregistration");
    API.unregister();
  }
}
