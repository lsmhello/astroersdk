package com.iusworks.astroer;

import android.os.Build;

import androidx.annotation.NonNull;

import com.iusworks.astroer.huawei.TokenRequester;
import com.iusworks.astroer.xiaomi.Badge;
import com.xiaomi.mipush.sdk.MiPushClient;

import java.util.HashMap;
import java.util.Map;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/**
 * AstroerPlugin
 */
public class AstroerPlugin implements FlutterPlugin, MethodCallHandler {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activitydd
    private MethodChannel channel;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        AstroerGlobal.setContext(flutterPluginBinding.getApplicationContext());
        channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "astroer");
        channel.setMethodCallHandler(this);
        AstroerGlobal.setChannel(channel);
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        if (call.method.equals("device")) {
            result.success(device());
        } else if ("registration".equals(call.method)) {
            registration(call.arguments);
        } else if ("setBadge".equals(call.method)) {
            int badge = 0;
            try {
                badge = Integer.parseInt(call.arguments.toString());
            } catch (Exception ex) {
                System.out.println(ex);
            }
            setBadge(badge);
        } else {
            result.notImplemented();
        }
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        AstroerGlobal.setChannel(null);
        channel.setMethodCallHandler(null);
        AstroerGlobal.setContext(null);
    }

    private void registration(Object obj) {
        Map<String, Map<String, String>> args;
        args = (Map<String, Map<String, String>>) obj;
        if (Tool.isXiaomi()) {
            Map<String, String> x = args.get("xiaomi");
            MiPushClient.registerPush(AstroerGlobal.getContext(), x.get("appId"), x.get("key"));
        } else if (Tool.ixHuawei()) {
            Map<String, String> x = args.get("huawei");
            TokenRequester.requestToken(x.get("appId"));
        }
    }

    Map<String, Object> device() {
        Map<String, Object> d = new HashMap<>();
        d.put("brand", Build.BRAND);
        d.put("name", Build.USER);
        d.put("os", Build.VERSION.RELEASE + "; " + String.valueOf(Build.VERSION.SDK_INT));

        Map<String, String> info = new HashMap<>();
        info.put("product", Build.PRODUCT);
        info.put("model", Build.MODEL);
        info.put("factor", Build.MANUFACTURER);
        info.put("hardware", Build.HARDWARE);
        info.put("host", Build.HOST);
        info.put("device", Build.DEVICE);

        d.put("informations", info);
        d.put("credentials", Storage.getAllToken());


        return d;
    }

    void setBadge(int badge) {
        if (Tool.isXiaomi()) {
            Badge.set(AstroerGlobal.getContext(), badge);
        }
    }
}
