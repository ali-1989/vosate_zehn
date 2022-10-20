package ir.vosatezehn.com;

import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.content.Context;
import android.content.Intent;
import android.graphics.Color;
import android.os.Build;
import androidx.core.app.NotificationCompat;
import androidx.core.app.NotificationManagerCompat;
//import androidx.core.app.RemoteInput;
//import android.app.PendingIntent;


public class NotificationHelper {
    static private final String CHANNEL_ID = "c_01";
    static private final String CHANNEL_NAME = "flutter_app";
    static private final int NOTIFICATION_ID = 101;

    static void createChannel(Context context) {
        NotificationManagerCompat manager = NotificationManagerCompat.from(context);

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            int importance = NotificationManager.IMPORTANCE_DEFAULT;
            NotificationChannel channel = new NotificationChannel(CHANNEL_ID, CHANNEL_NAME, importance);
            channel.setDescription("channel");
            channel.enableVibration(false);
            channel.enableLights(true);

            manager.createNotificationChannel(channel);
        }
    }

    static void showNotification(Context context, String msg) {
        Notification notification = new NotificationCompat.Builder(context, CHANNEL_ID)
                .setDefaults(Notification.DEFAULT_ALL)
                .setSmallIcon(R.mipmap.ic_launcher)
                .setPriority(NotificationCompat.PRIORITY_HIGH)
                .setContentTitle(msg)
                .setColor(Color.BLUE)
                .setAutoCancel(true)
                .setOnlyAlertOnce(true)
                .build();

        NotificationManagerCompat.from(context).notify(NOTIFICATION_ID, notification);
    }
}
