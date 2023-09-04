package ir.vosatezehn.com;

import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.media.Ringtone;
import android.media.RingtoneManager;
import android.net.Uri;
import android.os.Build;
import android.os.Vibrator;
import android.widget.Toast;

import androidx.core.app.NotificationCompat;
import androidx.core.app.NotificationManagerCompat;

import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.dart.DartExecutor;
import io.flutter.embedding.engine.dart.DartExecutor.DartEntrypoint;
import io.flutter.embedding.engine.loader.FlutterLoader;
import io.flutter.plugin.common.MethodChannel;

public class BootReceiver extends BroadcastReceiver {

    @Override
    public void onReceive(Context context, Intent intent) {
        //String appName = context.getPackageName();

        //if(Intent.ACTION_BOOT_COMPLETED.equals(intent.getAction())) {}
        //createNotificationChannel(context, "channel_" + appName, "N_" + appName);
        //sendNotification(context, "channel_" + appName, "unBoot", "Hi user");

        run(context, intent);
    }

    private static void run(Context context, Intent intent){
        startEngin(context);
    }

    private static void startEngin(Context context){
        FlutterLoader loader = new FlutterLoader();

        if(!loader.initialized()) {
            loader.startInitialization(context.getApplicationContext());
            loader.ensureInitializationComplete(context, null/*new String[0]*/);
        }
        //----- run dart function ----------------------------------
        DartEntrypoint entryPoint = new DartExecutor.DartEntrypoint("lib/main.dart", "dartFunction");
        //DartExecutor.DartEntrypoint.createDefault();
        //DartEntrypoint.createDefault();
        //new DartExecutor.DartEntrypoint(loader.findAppBundlePath(), "dartFunction");
        //-------- FlutterEngine
        FlutterEngine flutterEngine = new FlutterEngine(context.getApplicationContext());
        flutterEngine.getDartExecutor().executeDartEntrypoint(entryPoint);
        //-------- invoke channel -------------------------------
        MethodChannel channel = new MethodChannel(flutterEngine.getDartExecutor(), "my_android_channel");
        channel.invokeMethod("androidReceiverIsCall", null);

        //MyApplication.launchApp(context);
    }

    private static void prompt(Context context, String msg){
        Vibrator vibrator = (Vibrator) context.getSystemService(Context.VIBRATOR_SERVICE);
        vibrator.vibrate(500L);

        Toast.makeText(context, msg, Toast.LENGTH_SHORT).show();
    }

    private static void playRing(Context context){
        Uri alarmUri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_ALARM);

        if (alarmUri == null) {
            alarmUri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION);
        }

        Ringtone ringtone = RingtoneManager.getRingtone(context, alarmUri);
        ringtone.play();
    }

    static void createNotificationChannel(Context context, String channelId, String channelName) {
        NotificationManagerCompat manager = NotificationManagerCompat.from(context);

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            int importance = NotificationManager.IMPORTANCE_DEFAULT;
            NotificationChannel channel = new NotificationChannel(channelId, channelName, importance);
            channel.setDescription("channel");
            channel.enableVibration(true);
            channel.enableLights(true);

            manager.createNotificationChannel(channel);
        }
    }

    static void sendNotification(Context context, String channelId, String title, String message){
        Intent intent = new Intent(context, MainActivity.class);
        PendingIntent pendingIntent = PendingIntent.getActivity(context, 1010120, intent, PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE);

        NotificationCompat.Builder notificationBuilder = new NotificationCompat.Builder(context, channelId)
                .setSmallIcon(R.mipmap.ic_launcher)
                //.setContentTitle(getString(R.string.app_name)
                .setContentTitle(title)
                .setContentText(message)
                .setAutoCancel(true)
                .setSound(RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION))
                .setContentIntent(pendingIntent);

        NotificationManager notificationManager = (NotificationManager) context.getSystemService(Context.NOTIFICATION_SERVICE);
        notificationManager.notify(100, notificationBuilder.build());
    }
}


/*
======================================================================================
DartEntrypoint entrypoint = DartEntrypoint.createDefault();
DartEntrypoint entryPoint = new DartEntrypoint(loader.findAppBundlePath(), "dartFunction");
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
if(Intent.ACTION_BOOT_COMPLETED.equals(intent.getAction())) {
            Intent activityIntent = new Intent(context, MainActivity.class);
            activityIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            context.startActivity(activityIntent);
        }
==================================================================================
private static void run(Context context, Intent intent){
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
*/
