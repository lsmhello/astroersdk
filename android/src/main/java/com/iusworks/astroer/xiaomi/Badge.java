package com.iusworks.astroer.xiaomi;

import android.annotation.SuppressLint;
import android.content.Context;
import android.content.Intent;

import java.lang.reflect.Field;

public class Badge {
    public static void set(Context context, int number) {
//        String value = String.valueOf(number == 0 ? "" : number);
        try {
            @SuppressLint("PrivateApi")
            Class miuiNotificationClass = Class.forName("android.app.MiuiNotification");
            Object miuiNotification = miuiNotificationClass.newInstance();
            Field field = miuiNotification.getClass().getDeclaredField("messageCount");
            field.setAccessible(true);
            field.set(miuiNotification, number);
        } catch (Exception e) {
            Intent localIntent = new Intent("android.intent.action.APPLICATION_MESSAGE_UPDATE");
            localIntent.putExtra("android.intent.extra.update_application_component_name", context.getPackageName() + "/." + "MainActivity");
            localIntent.putExtra("android.intent.extra.update_application_message_text", number);
            context.sendBroadcast(localIntent);
        }
    }
}
