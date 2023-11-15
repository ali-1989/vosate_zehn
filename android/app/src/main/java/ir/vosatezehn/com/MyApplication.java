package ir.vosatezehn.com;

import android.app.ActivityManager;
import android.app.AlarmManager;
import android.app.PendingIntent;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.media.Ringtone;
import android.media.RingtoneManager;
import android.net.Uri;
import android.os.Build;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;
import android.widget.Toast;

import java.util.Calendar;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Timer;
import java.util.TimerTask;

import io.flutter.app.FlutterApplication;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class MyApplication extends FlutterApplication {
    private MethodChannel androidChannel;
    private FlutterEngine flutterEngine;
    private final String myAndroidName = "my_android_channel";

    public void onCreate () {
        super.onCreate();
        Log.i("▄▀▄ Err >>>>>>", "on create");
        Log.d("▄▀▄ Err >>>>>>", "on create B");
        Thread.setDefaultUncaughtExceptionHandler(this::handleUncaughtException);
        Looper.myLooper().getThread().setDefaultUncaughtExceptionHandler(this::handleUncaughtException);
        Looper.getMainLooper().getThread().setDefaultUncaughtExceptionHandler(this::handleUncaughtException);
        flutterEngine = new FlutterEngine(this);

        prepareAndroidChannel();

        Timer timer = new Timer();
        TimerTask task = new TimerTask() {
            @Override
            public void run() {
                try {

                }
                catch (Exception e){
                    Log.i("▄▀▄ Err >>>>>>", "helli " + e.toString());
                }
            }
        };

        Runnable r = new Runnable() {
            @Override
            public void run() {
                try {
                    Log.i("▄▀▄ Err >>>>>>", "invokeMethod A ");
                    androidChannel.invokeMethod("report_error", new HashMap<>());
                    //androidChannel.invokeMethod("report_error", "err");
                    Log.i("▄▀▄ Err >>>>>>", "invokeMethod B ");
                }
                catch (Exception e){
                    Log.i("▄▀▄ Err >>>>>>", "-e " + e.toString());
                }
            }
        };

        Handler handler = new Handler(Objects.requireNonNull(Looper.getMainLooper()));
        handler.post(r);

        //timer.schedule(task, 12000L);
        // this is call main() method in dart
        //flutterEngine.getDartExecutor().executeDartEntrypoint(DartExecutor.DartEntrypoint.createDefault());
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
                txt += "package_name: " + info.packageName;
                txt += " | app_version_name: " + info.versionName;

                report.put("app_name", info.packageName);
                report.put("app_version_name", info.versionName);
            }
            catch (Exception ignored) {}

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
        }
        catch (Exception ignored) {}
    }

    public void passDataToFlutter(Object data) {
        prepareAndroidChannel();
        Runnable r = new Runnable() {
            @Override
            public void run() {
                try {
                    Log.i("▄▀▄ Err >>>>>>", "invokeMethod A ");
                    androidChannel.invokeMethod("report_error", data);
                    Log.i("▄▀▄ Err >>>>>>", "invokeMethod B ");
                }
                catch (Exception e){
                    Log.i("▄▀▄ Err >>>>>>", "helli " + e.toString());
                }
            }
        };

        Handler handler = new Handler(Objects.requireNonNull(Looper.myLooper()));
        handler.post(r);
    }

    public void prepareAndroidChannel() {
        try{
            if(androidChannel == null) {
                androidChannel = new MethodChannel(flutterEngine.getDartExecutor(), myAndroidName);
                androidChannel.setMethodCallHandler(this::androidHandler);
            }
        }
        catch (Exception e){
            Log.i("▄▀▄ Err >>>>>>", e.toString());
        }
    }

    private void androidHandler(final MethodCall call, final MethodChannel.Result result) {
        Log.i("▄▀▄ Err >>>>>>", "yesss");
        switch (call.method) {
            case "echo": {
                result.success("<------- Echo from android channel -------->");
                break;
            }
            case "play_ring": {
                ring(this);
                result.success(true);
                break;
            }
            case "show_toast": {
                List<?> argList = (List<?>) call.arguments;
                Map<String, ?> arg1 = (Map<String, ?>) argList.get(0);

                toast(this, (String) arg1.get("message"));
                result.success(true);
                break;
            }
            case "set_wakeup": {
                List<?> argList = (List<?>) call.arguments;
                Map<String, ?> arg1 = (Map<String, ?>) argList.get(0);

                wakeup(this, arg1);
                result.success(true);
                break;
            }
            default:
                //result.notImplemented();
                result.success("-- not found --");
                break;
        }
    }

    private static void toast(Context context, String msg){
        Toast.makeText(context, msg, Toast.LENGTH_LONG).show();
    }

    private static void ring(Context context){
        Uri alarmUri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_ALARM);

        if (alarmUri == null) {
            alarmUri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION);
        }

        Ringtone ringtone = RingtoneManager.getRingtone(context, alarmUri);
        ringtone.play();
    }

    private static void wakeup(Context context, Map<String, ?> arg){
        boolean repeat = (boolean) arg.get("repeat");
        int year = (int) arg.get("year");
        int month = (int) arg.get("month");
        int day = (int) arg.get("day");
        int hour = (int) arg.get("hour");
        int min = (int) arg.get("min");
        String intervalStr = (String) arg.get("interval");
        Long interval;

        if(intervalStr != null){
            interval = Long.valueOf(intervalStr);
        }
        else {
            interval = 1000L * 60 * 20;
        }

        Intent intent = new Intent(context, BootReceiver.class);
        PendingIntent pendingIntent = PendingIntent.getBroadcast(context, 0, intent, PendingIntent.FLAG_UPDATE_CURRENT);
        AlarmManager alarmManager = (AlarmManager) context.getSystemService(ALARM_SERVICE);
        long time;
        Calendar calendar = Calendar.getInstance();
        calendar.set(Calendar.YEAR, year);
        calendar.set(Calendar.MONTH, month);
        calendar.set(Calendar.DAY_OF_MONTH, day);
        calendar.set(Calendar.HOUR_OF_DAY, hour);
        calendar.set(Calendar.MINUTE, min);

        time = (calendar.getTimeInMillis() - (calendar.getTimeInMillis() % 60000));

        if (System.currentTimeMillis() > time) {
            if (Calendar.AM_PM == 0)
                time = time + (1000 * 60 * 60 * 12);
            else
                time = time + (1000 * 60 * 60 * 24);
        }

        if(repeat) {
            alarmManager.setRepeating(AlarmManager.RTC_WAKEUP, time, interval, pendingIntent);
        }
        else {
            alarmManager.setExact(AlarmManager.RTC_WAKEUP,  time, pendingIntent);
        }
    }

    static void launchApp(Context context){
        if(isActivityRunning(context, MainActivity.class)){
            Intent intent = new Intent(context, MainActivity.class);
            //intent.addFlags(Intent.FLAG_ACTIVITY_BROUGHT_TO_FRONT);
            PendingIntent contentIntent = PendingIntent.getActivity(context, 0, intent, PendingIntent.FLAG_UPDATE_CURRENT);

            try{
                contentIntent.send();
            }
            catch (Exception ignored){}
        }
        else {
            Intent intent = new Intent(context, MainActivity.class);
            intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TASK | Intent.FLAG_ACTIVITY_TASK_ON_HOME);
            context.startActivity(intent);
        }
    }

    static Boolean isActivityRunning(Context context, Class<?> activityClass) {
        ActivityManager activityManager = (ActivityManager) (context.getSystemService(Context.ACTIVITY_SERVICE));
        List<ActivityManager.RunningTaskInfo> tasks = activityManager.getRunningTasks(Integer.MAX_VALUE);

        for (ActivityManager.RunningTaskInfo taskInfo : tasks) {
            ComponentName componentName = taskInfo.baseActivity;
            ComponentName componentName2 = taskInfo.baseActivity;

            if (componentName != null && componentName.getClassName().equals(activityClass.getCanonicalName())) {
                return true;
            }

            if (componentName2 != null && componentName2.getClassName().equals(activityClass.getCanonicalName())) {
                return true;
            }
        }

        return false;
    }
}

//System.exit(1);
//FlutterEngineCache.getInstance().put("my_engine_id", flutterEngine);
//flutterEngine.getNavigationChannel().setInitialRoute("/");
