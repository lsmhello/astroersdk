package com.iusworks.astroer;

import android.content.Intent;
import android.os.Bundle;

import org.json.JSONObject;

import java.util.HashMap;
import java.util.Locale;
import java.util.Map;

import io.flutter.embedding.android.FlutterActivity;

public class AstroerActivity extends FlutterActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        getIntentData(getIntent());
    }

    @Override
    public void onNewIntent(Intent intent) {
        super.onNewIntent(intent);
        setIntent(intent);
        getIntentData(intent);
    }

    private void getIntentData(Intent intent) {
        if (null == intent) {
            return;
        }

        Bundle bundle = intent.getExtras();
        if (bundle == null) {
            return;
        }

        JSONObject jsonObject = new JSONObject();
        try {
            String action = "";
            Map<String, String> params = new HashMap<>();

            for (String key : bundle.keySet()) {
                if (!key.startsWith("ast.")) {
                    continue;
                }

                if ("ast.action".equals(key)) {
                    action = bundle.getString(key);
                } else {
                    params.put(key.substring(4), bundle.getString(key));
                }
            }

            if (action.length() < 1) {
                return;
            }
            jsonObject.put("action", action);
            jsonObject.put("params", params);

        } catch (Exception ex) {
            System.out.println(ex.getLocalizedMessage());
        }


        Map<String, String> noti = new HashMap<>();
        noti.put("id", "");
        noti.put("title", "");
        noti.put("json", jsonObject.toString());

        System.out.println(noti.get("json"));

        AstroerGlobal.invokeDart("OnRecvNotification", noti);
    }

}
