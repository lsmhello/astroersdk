import 'astroer.dart';
import 'client.dart';
import 'tool.dart';
import 'log.dart';

class API {
  static String urlprefix = "http://10.0.10.1:9000/api/v1/";

  static String urlBuild(String path) {
    if (path.startsWith("/")) {
      path = path.substring(1);
    }

    return urlprefix + path;
  }

  static void register() async {
    var device = await Astroer.device;
    if (device == null) {
      return;
    }

    String astid = await Tool.astClientId();
    var params = {
      "id": Tool.getDeviceId(),
      "name": device.name,
      "astclientid": astid,
      "platform": device.infomations["brand"] == "apple" ? 10 : 11,
      "os": device.os,
      "information": device.infomations,
      "credentials": device.credentials
    };

    var res = await AstroerClient.postJson(urlBuild("/device/"), params);
    if (res["code"] == "ASTR-0000-0000-0000") {
      String id = res["data"]["id"];
      Tool.setDeviceId(id);
    } else {
      Log.logger().e(res);
    }
  }

  static void unregister() async {
    var params = {
      "id": Tool.getDeviceId(),
    };

    var res = await AstroerClient.postJson(urlBuild("/device/unregister"), params);
    if (res["code"] == "ASTR-0000-0000-0000") {
      Tool.clearDeviceId();
    } else {
      Log.logger().e(res);
    }
  }
}
