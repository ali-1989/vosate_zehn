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
        MethodChannel myChannel = new MethodChannel(flutterEngine.getDartExecutor(), "my_channel");

        myChannel.setMethodCallHandler((MethodCall call, Result result) -> {
            if (call.method.equals("set_dart_handler")) {
                setDartHandler(call, result);
            }
        });
    }

    private void setDartHandler(MethodCall call, Result result){
        Long id = call.argument("handle_id");
        SharedPreferenceHelper.setLong(getApplicationContext(), "dart_handler_id", id);
    }
}
