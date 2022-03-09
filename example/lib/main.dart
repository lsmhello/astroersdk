import 'dart:io';
import 'dart:math';

import 'package:astroer/config.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:astroer/astroer.dart';
import 'package:astroer/client.dart';
import 'package:astroer/log.dart';
import 'package:astroer/tool.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';

  @override
  void initState() {
    super.initState();
    initPlatformState();
    Astroer.init(astroerEnvDev, 1, "6120180395d88561f4769b5b6ca01938e7f26211");
    Astroer.setAppUserID(0);
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      var result = await Astroer.device;
      if (result != null) {
        platformVersion = result.os + ' : ' + result.brand;
      } else {
        platformVersion = 'Unknown platform version';
      }
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: ListView(
            children: [
              Center(
                child: Text(
                  'Running on: $_platformVersion',
                  style: const TextStyle(fontSize: 16, color: Colors.red),
                  maxLines: 4,
                ),
              ),
              TextButton(
                  onPressed: () {
                    Astroer.registration();
                  },
                  child: const Text('注册设备')),
              TextButton(
                  onPressed: () {
                    Astroer.setBadge(Random().nextInt(100));
                  },
                  child: const Text('设置Badge')),
              TextButton(
                  onPressed: () async {
                    var dev = await Astroer.device;
                    Log.logger().i(dev.toString());
                  },
                  child: const Text('获取设备信息')),
              TextButton(
                  onPressed: () async {
                    Astroer.unregistration();
                  },
                  child: const Text('取消注册')),
            ],
          ),
        ),
      ),
    );
  }
}
