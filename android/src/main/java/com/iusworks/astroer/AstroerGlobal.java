package com.iusworks.astroer;

import android.content.Context;
import android.os.Handler;
import android.os.Looper;

import io.flutter.plugin.common.MethodChannel;

public class AstroerGlobal {

    private static MethodChannel channel;
    private static Context context;

    public static Context getContext() {
        return context;
    }

    public static void setContext(Context context) {
        AstroerGlobal.context = context;
    }

    public static MethodChannel getChannel() {
        return channel;
    }

    public static void setChannel(MethodChannel channel) {
        AstroerGlobal.channel = channel;
    }

    public static void invokeDart(String method, Object param) {
        if (channel != null) {
            new Handler(Looper.getMainLooper()).post(() -> channel.invokeMethod(method, param));
            return;
        }

        new Thread(() -> {
            try {
                int trys = 2;
                while (AstroerGlobal.getChannel() == null && trys-- > 0) {
                    Thread.sleep(1000);

                }
            } catch (Exception ex) {
                System.out.println(ex.toString());
            }


            if (AstroerGlobal.getChannel() == null) {
                System.out.println("==============channel astroer is null=============");
                return;
            }

            new Handler(Looper.getMainLooper()).post(() -> AstroerGlobal.getChannel().invokeMethod(method, param));
        });

    }

}
