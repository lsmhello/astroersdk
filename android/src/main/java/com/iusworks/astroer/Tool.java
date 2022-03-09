package com.iusworks.astroer;

import android.os.Build;

import java.util.Locale;

public class Tool {
    public static boolean isXiaomi() {
        String brand = Build.BRAND.toLowerCase(Locale.ROOT);
        return brand.contains("xiaomi");
    }

    public static boolean ixHuawei() {
        String brand = Build.BRAND.toLowerCase(Locale.ROOT);
        return brand.contains("huawei") || brand.contains("honor");
    }
}
