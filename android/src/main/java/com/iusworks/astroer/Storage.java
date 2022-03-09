package com.iusworks.astroer;

import android.content.Context;
import android.content.SharedPreferences;

import java.util.HashMap;
import java.util.Map;

public class Storage {
    public static final String ASTROER_PREFERENCES = "ASTROER_PREFERENCES";
    public static final String ASTROER_PUSH_TOKEN_XIAOMI = "ASTROER_PUSH_TOKEN_XIAOMI";
    public static final String ASTROER_PUSH_TOKEN_HUAWEI = "ASTROER_PUSH_TOKEN_HUAWEI";

//    private static Context context;
//
//    public static Context getContext() {
//        return context;
//    }
//
//    public static void setContext(Context context) {
//        Storage.context = context;
//    }

    public static void setToken(PushFactory factory, String token) {
        SharedPreferences preferences = AstroerGlobal.getContext().getSharedPreferences(ASTROER_PREFERENCES,
                Context.MODE_PRIVATE);
        if (preferences == null) {
            return;
        }

        SharedPreferences.Editor editor = preferences.edit();
        if (editor == null) {
            return;
        }
        switch (factory) {
            case Huawei:
                editor.putString(ASTROER_PUSH_TOKEN_HUAWEI, token);
                break;
            case Xiaomi:
                editor.putString(ASTROER_PUSH_TOKEN_XIAOMI, token);
                break;
        }
        editor.apply();
    }

    public static Map<String, String> getAllToken() {
        Map<String, String> tokens = new HashMap<>();
        SharedPreferences preferences = AstroerGlobal.getContext().getSharedPreferences(ASTROER_PREFERENCES,
                Context.MODE_PRIVATE);
        tokens.put("xiaomi", preferences.getString(ASTROER_PUSH_TOKEN_XIAOMI, ""));
        tokens.put("huawei", preferences.getString(ASTROER_PUSH_TOKEN_HUAWEI, ""));

        return tokens;
    }
}
