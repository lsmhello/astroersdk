import 'package:astroer/config.dart';

class Device {
  String id = "0";
  int appId = AstroerConfig.appId;
  int appUid = AstroerConfig.appUid;

  String os;
  String name;
  String brand;

  Map<String, String> credentials = {};
  Map<String, String> infomations = {};

  Device(this.brand, this.name, this.os);

  @override
  String toString() {
    return 'Device{id: $id, appId: $appId, appUid: $appUid, os: $os, name: $name, brand: $brand, credentials: $credentials, infomations: $infomations}';
  }
}
