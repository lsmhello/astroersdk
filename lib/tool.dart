import 'package:device_info_plus/device_info_plus.dart';
import 'package:sp_util/sp_util.dart';
import 'package:uuid/uuid.dart';
import 'log.dart';

class Tool {
  static const deviceIdKey = "ASTROER_DEVICE_ID";
  static const astClientIdKey = "ASTROER_AST_CLIENT_ID";

  static void clearDeviceId() {
    Log.logger().w("clear device id");
    SpUtil.remove(deviceIdKey);
  }

  static void setDeviceId(String id) {
    Log.logger().i("set device id:$id");

    SpUtil.putString(deviceIdKey, id);
  }

  static String getDeviceId() {
    var id = SpUtil.getString(deviceIdKey, defValue: "");
    if (id == null) {
      return "0";
    }

    // Log.logger().i("getDeviceId：" + id);
    return id.toString();
  }

  static Future<String> astClientId() async {
    var id = SpUtil.getString(astClientIdKey, defValue: "");
    if (id != null && id.isNotEmpty) {
      return id;
    }

    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    String newid = "";
    try {
      IosDeviceInfo iosinfo = await deviceInfo.iosInfo;
      if (iosinfo.identifierForVendor != null && iosinfo.identifierForVendor!.isNotEmpty) {
        newid = iosinfo.identifierForVendor!;
      }
    } catch (_) {}
    try {
      AndroidDeviceInfo andinfo = await deviceInfo.androidInfo;
      if (andinfo.androidId != null && andinfo.androidId!.isNotEmpty) {
        newid = andinfo.androidId!;
      }
    } catch (_) {}

    if (newid.isEmpty) {
      newid = genastid();
    }

    SpUtil.putString(astClientIdKey, newid);
    return newid;
  }

  static String genastid() {
    return const Uuid().v1().toString();
  }
}
