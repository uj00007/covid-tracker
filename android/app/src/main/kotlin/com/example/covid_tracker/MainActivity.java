package com.example.covid_tracker;

import android.app.Activity;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.content.ContentResolver;
import android.media.AudioAttributes;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {
    static public Activity activity;

    @Override
    public void configureFlutterEngine(FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        GeneratedPluginRegistrant.registerWith(flutterEngine);
        activity=this;

//        ShimPluginRegistry shimPluginRegistry = new ShimPluginRegistry(flutterEngine);
        flutterEngine.getPlugins().add(new LocationPackagePlugin());
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        activity=this;
//        GeneratedPluginRegistrant.registerWith(this);
        NotificationManager notificationManager = (NotificationManager) getSystemService(NOTIFICATION_SERVICE);
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O){
            CharSequence name = "my_channel";
            // Create the channel for the notification
            NotificationChannel mChannel = new NotificationChannel(MethodChannels.NOTIFICATION_CHANNEL_ID, name,
                    NotificationManager.IMPORTANCE_HIGH);
            final Uri NOTIFICATION_SOUND_URI = Uri.parse(ContentResolver.SCHEME_ANDROID_RESOURCE + "://" + getPackageName() + "/raw/soundtone_notification");
            final long[] VIBRATE_PATTERN = {0, 500};
            AudioAttributes audioAttributes = new AudioAttributes.Builder()
                    .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                    .setUsage(AudioAttributes.USAGE_NOTIFICATION)
                    .build();
            mChannel.setSound(NOTIFICATION_SOUND_URI, audioAttributes);
            mChannel.setVibrationPattern(VIBRATE_PATTERN);
            mChannel.enableVibration(true);
            notificationManager.createNotificationChannel(mChannel);
        }
    }
}
