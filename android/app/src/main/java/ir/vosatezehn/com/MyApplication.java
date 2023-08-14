package ir.vosatezehn.com;

import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.os.Build;
import android.util.Log;

import java.util.HashMap;
import java.util.Map;

import io.flutter.app.FlutterApplication;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.dart.DartExecutor;
import io.flutter.plugin.common.MethodChannel;

public class MyApplication extends FlutterApplication {
    private MethodChannel channel;
    private FlutterEngine flutterEngine;
    private final String mName = "error_handler";

    public void onCreate () {
        super.onCreate();

        Thread.setDefaultUncaughtExceptionHandler(this::handleUncaughtException);

        flutterEngine = new FlutterEngine(this);
        
        // this is call main() method in dart
        //flutterEngine.getDartExecutor().executeDartEntrypoint(DartExecutor.DartEntrypoint.createDefault());
        
        //FlutterEngineCache.getInstance().put("my_engine_id", flutterEngine);
        //flutterEngine.getNavigationChannel().setInitialRoute("/");
    }

    public void handleUncaughtException(Thread thread, Throwable e) {
        try {
            PackageManager manager = this.getPackageManager();
            String model = Build.MODEL;
            Map<String, String> report = new HashMap<>();
            String txt = "";

            if (!model.startsWith(Build.MANUFACTURER)) {
                model = Build.MANUFACTURER + " (" + model + ")";
            }

            try {
                PackageInfo info = manager.getPackageInfo(this.getPackageName(), 0);
                txt += "packageName: " + info.packageName;
                txt += " | app_version_name: " + info.versionName;

                report.put("app_name", info.packageName);
                report.put("app_version_name", info.versionName);
            }
            catch (Exception ignored) {}
            //catch (PackageManager.NameNotFoundException ignored) {}

            txt += " | SDK: " + Build.VERSION.SDK_INT;
            txt += " | model: " + model;
            txt += " | error: " + e.toString();

            report.put("device_type", "android");
            report.put("catcher", "java");
            report.put("SDK", Build.VERSION.SDK_INT + "");
            report.put("model", model);
            report.put("error", e.toString());

            Log.i("▄▀▄ Err >>>>>>", txt);
            passDataToFlutter(report);
            //System.exit(1);
        }
        catch (Exception ignored) {}
    }

    public void passDataToFlutter(Object data) {
        if(channel == null) {
            try{
                channel = new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), mName);
            }
            catch (Exception ignored){}
        }

        channel.invokeMethod("report_error", data);
    }
}