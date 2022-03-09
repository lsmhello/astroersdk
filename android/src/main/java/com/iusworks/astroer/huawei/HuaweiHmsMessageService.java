package com.iusworks.astroer.huawei;


import android.os.Bundle;

import com.huawei.hms.push.HmsMessageService;
import com.huawei.hms.push.RemoteMessage;
import com.iusworks.astroer.AstroerGlobal;

import java.util.HashMap;
import java.util.Map;

public class HuaweiHmsMessageService extends HmsMessageService {

    @Override
    public void onMessageReceived(RemoteMessage remoteMessage) {
        System.out.println("=====|onMessageReceived||===================================");
        super.onMessageReceived(remoteMessage);

        AstroerGlobal.invokeDart("OnRecvNotification", formatNotification(remoteMessage));
    }

    @Override
    public void onMessageDelivered(String s, Exception e) {
        System.out.println("=====|onMessageDelivered||===================================");

        super.onMessageDelivered(s, e);
    }

    @Override
    public void onNewToken(String s) {
        System.out.println("=====|onNewToken||===================================");
        super.onNewToken(s);
    }

    @Override
    public void onNewToken(String s, Bundle bundle) {
        System.out.println("=====|onNewToken|Bundle|===================================");

        super.onNewToken(s, bundle);
    }

    @Override
    public void onTokenError(Exception e) {
        System.out.println("=====|onTokenError||===================================");
        super.onTokenError(e);
    }

    @Override
    public void onTokenError(Exception e, Bundle bundle) {
        System.out.println("=====|onTokenError|Bundle|===================================");
        super.onTokenError(e, bundle);
    }


    private static Map<String, Object> formatNotification(RemoteMessage message) {
        Map<String, Object> f = new HashMap<>();
        f.put("id", message.getMessageId() == null ? "" : message.getMessageId());
        f.put("title", message.getNotification().getTitle() == null ? "" : message.getNotification().getTitle());

        if (message.getData() != null && message.getData().length() > 0) {
            String content = message.getData().trim();
            f.put("json", content);
        } else {
            f.put("json", "");
        }

        return f;
    }
}
