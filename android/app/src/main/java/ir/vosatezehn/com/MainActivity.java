package ir.vosatezehn.com;

import android.os.Bundle;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugins.GeneratedPluginRegistrant;
import androidx.annotation.NonNull;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.MethodCall;

//public class MyApplication extends FlutterApplication

public class MainActivity extends FlutterActivity {

    static boolean flutterAppIsRun = false;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
    }

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine){
        super.configureFlutterEngine(flutterEngine);
        //GeneratedPluginRegistrant.registerWith(flutterEngine);
        init(flutterEngine);
    }

    private void init(FlutterEngine flutterEngine){
        //FlutterView view = getFlutterView();
        //MethodChannel myChannel = new MethodChannel(view, "my_channel");
        MethodChannel myChannel = new MethodChannel(flutterEngine.getDartExecutor(), "my_channel");

        myChannel.setMethodCallHandler((MethodCall call, Result result) -> {
            if (call.method.equals("set_dart_handler")) {
                setDartHandler(call, result);
            }
            else if (call.method.equals("setAppIsRun")) {
                flutterAppIsRun = true;
                result.success(null);
                return;
            }
            else if (call.method.equals("isAppRun")) {
                result.success(flutterAppIsRun);
                return;
            }
            else if (call.method.equals("dismissNotification")) {
                dismissNotification(call, result);
                result.success(true);
                return;
            }

            result.success(null);
        });
    }

    private void setDartHandler(MethodCall call, Result result){
        Long id = call.argument("handle_id");
        SharedPreferenceHelper.setLong(getApplicationContext(), "dart_handler_id", id);
    }

    private void dismissNotification(MethodCall call, Result result){
        Integer id = call.argument("notification_id");
        NotificationHelper.dismissNotification(getApplicationContext(), id);
    }
}
