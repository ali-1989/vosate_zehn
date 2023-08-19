package ir.vosatezehn.com;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.media.Ringtone;
import android.media.RingtoneManager;
import android.net.Uri;
import android.os.Handler;
import android.os.Looper;
import android.os.Vibrator;
import android.widget.Toast;

import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.dart.DartExecutor;
import io.flutter.embedding.engine.dart.DartExecutor.DartEntrypoint;
import io.flutter.embedding.engine.loader.FlutterLoader;
import io.flutter.plugin.common.MethodChannel;

//https://github.com/firebase/flutterfire/blob/master/packages/firebase_messaging/firebase_messaging/android/src/main/java/io/flutter/plugins/firebase/messaging/FlutterFirebaseMessagingBackgroundExecutor.java

public class BootReceiver extends BroadcastReceiver {

    @Override
    public void onReceive(Context context, Intent intent) {
        run(context, intent);
    }

    private static void run(Context context, Intent intent){
        prompt(context, "boot call");
        /*FlutterLoader loader = new FlutterLoader();
        loader.startInitialization(context.getApplicationContext());
        prompt(context, "startInitialization");
        loader.ensureInitializationComplete(context, null);
        prompt(context, "ensureInitializationComplete");*/
        startEngin(context);
    }

    private static void run_(Context context, Intent intent){
        FlutterLoader loader = new FlutterLoader();
        Handler handler = new Handler(Looper.getMainLooper());
        Runnable starter = new Runnable() {
            @Override
            public void run() {
                startEngin(context);
            }
        };

        if(!loader.initialized()) {
            loader.startInitialization(context.getApplicationContext());
            loader.ensureInitializationCompleteAsync(
                    context.getApplicationContext(),
                    null,
                    handler,
                    starter
            );
        }
        else {
            handler.post(starter);
        }
    }

    private static void startEngin(Context context){
        //DartEntrypoint entryPoint = DartEntrypoint.createDefault();
        //DartEntrypoint entryPoint = new DartEntrypoint(loader.findAppBundlePath(), "bootCompletedHandler");
        DartEntrypoint entryPoint = DartExecutor.DartEntrypoint.createDefault();
        //---------------------------------------
        /*FlutterJNI flutterJNI = new FlutterJNI();
        DartExecutor executor = new DartExecutor(flutterJNI, context.getAssets());

        executor.executeDartEntrypoint(entryPoint);*/
        //---------------------------------------
        FlutterEngine flutterEngine = new FlutterEngine(context.getApplicationContext());
        flutterEngine.getDartExecutor().executeDartEntrypoint(entryPoint);
        prompt(context, "dart start");
        //---------------------------------------
        //MethodChannel channel = new MethodChannel(executor, "boot_completed");
        MethodChannel channel = new MethodChannel(flutterEngine.getDartExecutor(), "my_android_channel");
        channel.invokeMethod("bootCompleted", "boot");
        prompt(context, "channel invoke");
        //playRing(context);
    }

    private static void prompt(Context context, String msg){
        Vibrator vibrator = (Vibrator) context.getSystemService(Context.VIBRATOR_SERVICE);
        //vibrator.vibrate(1000);

        //Toast.makeText(context, msg, Toast.LENGTH_SHORT).show();
    }

    private static void playRing(Context context){
        Uri alarmUri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_ALARM);

        if (alarmUri == null) {
            alarmUri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION);
        }

        Ringtone ringtone = RingtoneManager.getRingtone(context, alarmUri);
        ringtone.play();
    }
}



//======================================================================================
/*
FlutterMain.ensureInitializationComplete(context, null);
-------------------------------------------------------
DartEntrypoint entrypoint = DartEntrypoint.createDefault();
DartEntrypoint entryPoint = new DartEntrypoint(loader.findAppBundlePath(), "bootCompletedHandler");
-------------------------------------------------------
FlutterLoader loader = new FlutterLoader();
loader.startInitialization(context.getApplicationContext());
loader.ensureInitializationComplete(context, null);

DartEntrypoint entrypoint = DartEntrypoint.createDefault();
FlutterJNI flutterJNI = new FlutterJNI();
DartExecutor executor = new DartExecutor(flutterJNI, context.getAssets());

executor.executeDartEntrypoint(entrypoint);

MethodChannel mBackgroundChannel = new MethodChannel(executor, "boot_completed");
mBackgroundChannel.invokeMethod("bootCompletedHandler", "boot");
-------------------------------------------------------
FlutterLoader loader = new FlutterLoader();
loader.startInitialization(context.getApplicationContext());
loader.ensureInitializationComplete(context, null);

FlutterRunArguments flutterRunArguments = new FlutterRunArguments();
flutterRunArguments.bundlePath = loader.findAppBundlePath();
flutterRunArguments.entrypoint = entrypoint.dartEntrypointFunctionName;//flutterCallbackInformation.callbackName;
flutterRunArguments.libraryPath = entrypoint.dartEntrypointLibrary;//flutterCallbackInformation.callbackLibraryPath;

FlutterNativeView flutterView = new FlutterNativeView(context, true);
flutterView.runFromBundle(flutterRunArguments);
-------------------------------------------------------
String bundlePath = loader.findAppBundlePath();//FlutterInjector.instance().flutterLoader().findAppBundlePath();
Long handlerId = SharedPreferenceHelper.getLong(context.getApplicationContext(), "dart_handler_id");
FlutterCallbackInformation cbInfo = FlutterCallbackInformation.lookupCallbackInformation(handlerId);
DartCallback dcb = new DartCallback(context.getAssets(), bundlePath, cbInfo);

engine.getDartExecutor().executeDartCallback(dcb);
-------------------------------------------------------
channel.invokeMethod("bootCompletedHandler", null, new MethodChannel.Result() {
            @Override
            public void success(Object o) {}

            @Override
            public void error(String s, String s1, Object e) {}

            @Override
            public void notImplemented() {}
        });
-------------------------------------------------------
*/
