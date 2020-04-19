package com.example.covid_tracker;


import android.app.ActivityManager;
import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.Service;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.location.Location;
import android.location.LocationManager;
import android.os.Build;
import android.os.IBinder;
import android.os.Looper;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.app.NotificationCompat;
import androidx.core.content.ContextCompat;

import com.google.android.gms.location.FusedLocationProviderClient;
import com.google.android.gms.location.LocationCallback;
import com.google.android.gms.location.LocationRequest;
import com.google.android.gms.location.LocationResult;
import com.google.android.gms.location.LocationServices;
import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.Task;
import com.google.gson.JsonObject;

import org.json.JSONObject;

import java.text.DateFormat;
import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.TimeUnit;

import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;

import static com.example.covid_tracker.MethodChannels.NOTIFICATION_CHANNEL_ID;


public class LocationService extends Service {
    private static final String TAG = LocationService.class.getSimpleName();

    private static final String PACKAGE_NAME =
            "com.example.covid_tracker";
    static final String ACTION_BROADCAST = PACKAGE_NAME + ".broadcast";

    public static final String EXTRA_LOCATION = PACKAGE_NAME + ".location";
    /**
     * Provides access to the Fused Location Provider API.
     */
    private FusedLocationProviderClient mFusedLocationClient;
    /**
     * Callback for changes in location.
     */
    private LocationCallback mLocationCallback;
    /**
     * Contains parameters used by {@link com.google.android.gms.location.FusedLocationProviderApi}.
     */
    private LocationRequest mLocationRequest;
    /**
     * The desired interval for location updates. Inexact. Updates may be more or less frequent.
     */
    private static long UPDATE_INTERVAL_IN_MILLISECONDS = 60000;
    private NotificationManager mNotificationManager;
    /**
     * The identifier for the notification displayed for the foreground service.
     */
    private static final int NOTIFICATION_ID = 1231234;
    /**
     * The fastest rate for active location updates. Updates will never be more frequent
     * than this value.
     */
    private static final long FASTEST_UPDATE_INTERVAL_IN_MILLISECONDS =
            UPDATE_INTERVAL_IN_MILLISECONDS / 2;
    /**
     * The current location.
     */
    private Location mLocation;

    private long locationUpdatedAt = Long.MIN_VALUE;

    String email="";
    String id="";

    static void startService(Context context, String message) {
        Intent startIntent = new Intent(context, LocationService.class);
        startIntent.putExtra("inputExtra", message);
        ContextCompat.startForegroundService(context, startIntent);

    }

    static void stopService(Context context) {
        Intent stopIntent = new Intent(context, LocationService.class);
        context.stopService(stopIntent);
    }

    private void createNotificationChannel() {
        NotificationManager notificationManager = (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            CharSequence name = "hawkeye location";
            // Create the channel for the notification
            NotificationChannel mChannel = new NotificationChannel(NOTIFICATION_CHANNEL_ID, name,
                    NotificationManager.IMPORTANCE_DEFAULT);
            mChannel.setSound(null, null);
            // Set the Notification Channel for the Notification Manager.
            notificationManager.createNotificationChannel(mChannel);
        }
    }

    /**
     * Makes a request for location updates. Note that in this sample we merely log the
     * {@link SecurityException}.
     */
    public void requestLocationUpdates() {
        Log.i("LocationUpdates", "Requesting location updates");
        startService(new Intent(getApplicationContext(), LocationService.class));
        try {
            mFusedLocationClient.requestLocationUpdates(mLocationRequest,
                    mLocationCallback, Looper.myLooper());
        } catch (SecurityException unlikely) {
            Log.e(TAG, "Lost location permission. Could not request updates. " + unlikely);
        }
    }

    /**
     * Removes location updates. Note that in this sample we merely log the
     * {@link SecurityException}.
     */
    public void removeLocationUpdates() {
        Log.i(TAG, "Removing location updates");
        try {
            mFusedLocationClient.removeLocationUpdates(mLocationCallback);
            stopSelf();
        } catch (SecurityException unlikely) {
            Log.e(TAG, "Lost location permission. Could not remove updates. " + unlikely);
        }
    }

    @Nullable
    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }

    @Override
    public void onCreate() {
        super.onCreate();
        Log.d("Service", "onCreate");
        createNotificationChannel();
        mFusedLocationClient = LocationServices.getFusedLocationProviderClient(this);
        mLocationCallback = new LocationCallback() {
            @Override
            public void onLocationResult(LocationResult locationResult) {
                super.onLocationResult(locationResult);
                boolean updateLocationAndUpload = false;
                if (mLocation == null) {
                    mLocation = locationResult.getLastLocation();
                    locationUpdatedAt = System.currentTimeMillis();
                    updateLocationAndUpload = true;
                } else {
                    long secondsElapsed = TimeUnit.MILLISECONDS.toSeconds(System.currentTimeMillis() - locationUpdatedAt);
                    Log.i("secondsElapsed", " " + secondsElapsed);
                    if (secondsElapsed >= 10) {
                        mLocation = locationResult.getLastLocation();
                        locationUpdatedAt = System.currentTimeMillis();
                        updateLocationAndUpload = true;
                    }
                }
                Log.i("onLocationResult", "location: " + locationResult.getLastLocation());
                if (updateLocationAndUpload) {
                    onNewLocation(locationResult.getLastLocation());
                }
            }
        };

        createLocationRequest();
        getLastLocation();

        mNotificationManager = (NotificationManager) getSystemService(NOTIFICATION_SERVICE);
        IntentFilter filter = new IntentFilter(LocationManager.PROVIDERS_CHANGED_ACTION);
        filter.addAction(Intent.ACTION_PROVIDER_CHANGED);
        this.registerReceiver(gpsSwitchStateReceiver, filter);
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        Log.d("Service", "onStartCommand");
        email = intent.getExtras().getString("email");
        id = intent.getExtras().getString("id");


        startForeground(NOTIFICATION_ID, getNotification(getLocationText(mLocation)));
        try {
            Log.e("LocationRequest ", "updateInterval : " + mLocationRequest.getInterval());
            mFusedLocationClient.requestLocationUpdates(mLocationRequest,
                    mLocationCallback, Looper.myLooper());
        } catch (SecurityException unlikely) {
            Log.e(TAG, "Lost location permission. Could not request updates. " + unlikely);
        }
        return START_REDELIVER_INTENT;
    }


    @Override
    public void onDestroy() {
        try {
            this.unregisterReceiver(gpsSwitchStateReceiver);
            mFusedLocationClient.removeLocationUpdates(mLocationCallback);
        } catch (SecurityException unlikely) {
            Log.e(TAG, "Lost location permission. Could not remove updates. " + unlikely);
        }
        super.onDestroy();

        Log.d("Service", "Service Destroyed");
    }

    @Override
    public void onTaskRemoved(Intent rootIntent) {
        Log.e("Service", "onTaskRemoved");
        super.onTaskRemoved(rootIntent);
    }

    private Notification getNotification(String contentMessage) {
        String title = "Covid Tracker Running";
        NotificationCompat.Builder builder = new NotificationCompat.Builder(this,
                NOTIFICATION_CHANNEL_ID).setContentTitle(title).setContentText(contentMessage)
                .setSmallIcon(R.mipmap.ic_launcher)
                .setOngoing(true)
                .setPriority(Notification.PRIORITY_MAX)
                .setTicker(contentMessage)
                .setAutoCancel(false)
                .setWhen(System.currentTimeMillis());
        return builder.build();
    }

    /**
     * Sets the location request parameters.
     */
    private void createLocationRequest() {
        mLocationRequest = new LocationRequest();
        mLocationRequest.setInterval(UPDATE_INTERVAL_IN_MILLISECONDS);
        mLocationRequest.setFastestInterval(FASTEST_UPDATE_INTERVAL_IN_MILLISECONDS);
        mLocationRequest.setPriority(LocationRequest.PRIORITY_BALANCED_POWER_ACCURACY);
        Log.e("LocationRequest ", "updateInterval create : " + mLocationRequest.getInterval());

    }

    private void getLastLocation() {
        try {
            mFusedLocationClient.getLastLocation()
                    .addOnCompleteListener(new OnCompleteListener<Location>() {
                        @Override
                        public void onComplete(@NonNull Task<Location> task) {
                            if (task.isSuccessful() && task.getResult() != null) {
                                mLocation = task.getResult();
                                locationUpdatedAt = System.currentTimeMillis();
                                onNewLocation(mLocation);

                            } else {
                                Log.w("getLastLocation", "Failed to get location.");
                            }
                        }
                    });
        } catch (SecurityException unlikely) {
            Log.e("getLastLocation", "Lost location permission." + unlikely);
        }
    }

    private void onNewLocation(Location location) {
        Log.i("New Location Got", "New location: " + location);
        mLocation = location;
        if (LocationPackagePlugin.methodChannel != null)
            LocationPackagePlugin.methodChannel.invokeMethod("locationUpdated", getLocationMap(location));
//        mNotificationManager.notify(NOTIFICATION_ID, getNotification(getLocationText(mLocation)));

        sendToServer();
    }

    private void sendToServer() {
        AppExecutors.getInstance().networkIO().execute(new Runnable() {
            @Override
            public void run() {
                JsonObject locationUploadRequest = new JsonObject();
                locationUploadRequest.addProperty("lat", mLocation.getLatitude());
                locationUploadRequest.addProperty("long", mLocation.getLongitude());
                locationUploadRequest.addProperty("email", email);
                locationUploadRequest.addProperty("id", id);

                NetworkServicesImpl.getInstance().sendLocation("application/json",  locationUploadRequest, new Callback<JsonObject>() {
                            @Override
                            public void onResponse(Call<JsonObject> call, Response<JsonObject> response) {
                                Log.e("response", "" + response);

                            }

                            @Override
                            public void onFailure(Call<JsonObject> call, Throwable t) {
                                t.printStackTrace();
                                Log.e("response", "fail");
                            }
                        });
            }
        });
    }


    private Map getLocationMap(Location location) {
        Map map = new HashMap();
        map.put("lat", location.getLatitude());
        map.put("lng", location.getLongitude());
        return map;
    }

    /**
     * Returns true if this is a foreground service.
     *
     * @param context The {@link Context}.
     */
    public boolean serviceIsRunningInForeground(Context context) {
        ActivityManager manager = (ActivityManager) context.getSystemService(
                Context.ACTIVITY_SERVICE);
        for (ActivityManager.RunningServiceInfo service : manager.getRunningServices(
                Integer.MAX_VALUE)) {
            if (getClass().getName().equals(service.service.getClassName())) {
                if (service.foreground) {
                    return true;
                }
            }
        }
        return false;
    }

    public static String getLocationText(Location location) {
        return location == null ? "Stay Inside, Stay Safe" :
                "Location Service is running";
    }


    private BroadcastReceiver gpsSwitchStateReceiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {

            if (LocationManager.PROVIDERS_CHANGED_ACTION.equals(intent.getAction())) {
                // Make an action or refresh an already managed state.

                LocationManager locationManager = (LocationManager) context.getSystemService(Context.LOCATION_SERVICE);
                boolean isGpsEnabled = locationManager.isProviderEnabled(LocationManager.GPS_PROVIDER);
                boolean isNetworkEnabled = locationManager.isProviderEnabled(LocationManager.NETWORK_PROVIDER);

                if (isGpsEnabled || isNetworkEnabled) {
                    // Log.i(this.getClass().getName(), "gpsSwitchStateReceiver.onReceive() location
                    // is enabled : isGpsEnabled = "
                    // + isGpsEnabled + " isNetworkEnabled = " + isNetworkEnabled);

                } else {
                    Log.w(this.getClass().getName(), "gpsSwitchStateReceiver.onReceive() location disabled ");
                    LocationUtil.checkLocation(MainActivity.activity, null);
                }
            }
        }
    };
}

