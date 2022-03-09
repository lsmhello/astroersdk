package com.iusworks.astroer.huawei;

import com.huawei.hms.aaid.HmsInstanceId;
import com.huawei.hms.common.ApiException;
import com.iusworks.astroer.AstroerGlobal;
import com.iusworks.astroer.PushFactory;
import com.iusworks.astroer.Storage;

import java.util.HashMap;
import java.util.Map;

public class TokenRequester {

    public static void requestToken(String appid) {

        new Thread() {
            @Override
            public void run() {
                try {
                    HmsInstanceId hmsInstanceId = HmsInstanceId.getInstance(AstroerGlobal.getContext());
                    String token = hmsInstanceId.getToken(appid, "HCM");
                    System.out.println("==========================:" + token);
                    System.out.println(token);

                    Map<String, String> params = new HashMap<>();
                    params.put("huawei", token);
                    Storage.setToken(PushFactory.Huawei, token);
                    AstroerGlobal.invokeDart("OnReceiveRegisterResult", params);
                } catch (ApiException e) {
                    System.out.println("+++++++++++++++:" + e.getLocalizedMessage());
                }
            }
        }.start();
    }
}
