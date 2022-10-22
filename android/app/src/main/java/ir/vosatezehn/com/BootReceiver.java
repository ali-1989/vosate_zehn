package ir.vosatezehn.com;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.util.Log;

import io.flutter.embedding.engine.loader.FlutterLoader;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.dart.DartExecutor;
import io.flutter.embedding.engine.dart.DartExecutor.DartCallback;
import io.flutter.embedding.engine.dart.DartExecutor.DartEntrypoint;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.view.FlutterCallbackInformation;
import android.os.Looper;
import android.os.Handler;
import io.flutter.plugins.GeneratedPluginRegistrant;

//import io.flutter.embedding.engine.FlutterJNI;
//import io.flutter.view.FlutterNativeView;
//import io.flutter.view.FlutterRunArguments;
//import io.flutter.view.FlutterMain;

//https://github.com/firebase/flutterfire/blob/master/packages/firebase_messaging/firebase_messaging/android/src/main/java/io/flutter/plugins/firebase/messaging/FlutterFirebaseMessagingBackgroundExecutor.java

public class BootReceiver extends BroadcastReceiver {
    @Override
    public void onReceive(Context context, Intent intent) {
        run(context);
    }

    /*
    private static void run(Context context){
        //FlutterMain.ensureInitializationComplete(context, null);
        FlutterLoader loader = new FlutterLoader();
        loader.startInitialization(context.getApplicationContext());
        loader.ensureInitializationComplete(context, null);

        DartEntrypoint entrypoint = DartEntrypoint.createDefault();

        FlutterRunArguments flutterRunArguments = new FlutterRunArguments();
        flutterRunArguments.bundlePath = loader.findAppBundlePath();
        flutterRunArguments.entrypoint = entrypoint.dartEntrypointFunctionName;//flutterCallbackInformation.callbackName;
        flutterRunArguments.libraryPath = entrypoint.dartEntrypointLibrary;//flutterCallbackInformation.callbackLibraryPath;

        FlutterNativeView flutterView = new FlutterNativeView(context, true);
        flutterView.runFromBundle(flutterRunArguments);

        MethodChannel mBackgroundChannel = new MethodChannel(flutterView, "boot_compelated_channel");
        mBackgroundChannel.invokeMethod("boot_compelated", "");
    }
    */

    /*
    private static void run(Context context){
        FlutterLoader loader = new FlutterLoader();
        loader.startInitialization(context.getApplicationContext());
        loader.ensureInitializationComplete(context, null);

        DartEntrypoint entrypoint = DartEntrypoint.createDefault();
        FlutterJNI flutterJNI = new FlutterJNI();
        DartExecutor executor = new DartExecutor(flutterJNI, context.getAssets());

        executor.executeDartEntrypoint(entrypoint);

        MethodChannel mBackgroundChannel = new MethodChannel(executor, "boot_completed_channel");
        mBackgroundChannel.invokeMethod("bootCompletedHandler", "boot");
    }
    */

    private static void run(Context context){
        FlutterLoader loader = new FlutterLoader();
        Handler handler = new Handler(Looper.getMainLooper());

        Runnable r = new Runnable() {
            @Override
            public void run() {
                if(!loader.initialized()) {
                    loader.startInitialization(context.getApplicationContext());
                    loader.ensureInitializationCompleteAsync(
                            context.getApplicationContext(),
                            null,
                            handler,
                            new Runnable() {
                                @Override
                                public void run() {
                                    startEngin(context, loader);
                                }
                            }
                    );
                }
                else {
                    startEngin(context, loader);
                }
            }
        };

        handler.post(r);
    }

    private static void startEngin(Context context, FlutterLoader loader){
        FlutterEngine engine = new FlutterEngine(context.getApplicationContext());
        //GeneratedPluginRegistrant.registerWith(engine);

        String bundlePath = loader.findAppBundlePath();//FlutterInjector.instance().flutterLoader().findAppBundlePath();
        Long handlerId = SharedPreferenceHelper.getLong(context.getApplicationContext(), "dart_handler_id");
        FlutterCallbackInformation cbInfo = FlutterCallbackInformation.lookupCallbackInformation(handlerId);
        DartExecutor.DartCallback dcb = new DartCallback(context.getAssets(), bundlePath, cbInfo);

        engine.getDartExecutor().executeDartCallback(dcb);

        //DartEntrypoint entrypoint = DartEntrypoint.createDefault();
        /*DartEntrypoint entryPoint = new DartEntrypoint(loader.findAppBundlePath(), "bootCompletedHandler");
        engine.getDartExecutor().executeDartEntrypoint(entryPoint);*/

        //.getBinaryMessenger()
        /*MethodChannel myChannel = new MethodChannel(engine.getDartExecutor(), "my_channel");
        myChannel.invokeMethod("bootCompletedHandler", null, new MethodChannel.Result() {
            @Override
            public void success(Object o) {}

            @Override
            public void error(String s, String s1, Object e) {}

            @Override
            public void notImplemented() {}
        });*/

        //NotificationHelper.createChannel(context);
        //NotificationHelper.showNotification(context, "boot - " + handlerId.toString());
    }
}
