package com.example.covid_tracker;


import android.app.Activity;
import android.app.ActivityManager;
import android.content.Context;
import android.content.IntentSender;
import android.location.Location;
import android.util.Log;
import android.widget.Toast;

import androidx.annotation.NonNull;

import com.google.android.gms.common.api.ApiException;
import com.google.android.gms.common.api.ResolvableApiException;
import com.google.android.gms.location.LocationRequest;
import com.google.android.gms.location.LocationServices;
import com.google.android.gms.location.LocationSettingsRequest;
import com.google.android.gms.location.LocationSettingsResponse;
import com.google.android.gms.location.LocationSettingsStatusCodes;
import com.google.android.gms.location.SettingsClient;
import com.google.android.gms.tasks.OnFailureListener;
import com.google.android.gms.tasks.OnSuccessListener;

import java.util.HashMap;
import java.util.Map;

import io.flutter.plugin.common.MethodChannel;

public class LocationUtil {

    public static boolean locationSpoofingEnabled = true;

    /**
     * Provides access to the Location Settings API.
     */
    private static SettingsClient mSettingsClient;

    /**
     * Stores parameters for requests to the FusedLocationProviderApi.
     */
    private static LocationRequest mLocationRequest;

    /**
     * Stores the types of location services the client is interested in using. Used
     * for checking settings to determine if the device has optimal location
     * settings.
     */
    private static LocationSettingsRequest mLocationSettingsRequest;
    /**
     * The desired interval for location updates. Inexact. Updates may be more or
     * less frequent.
     */
    private static final long UPDATE_INTERVAL_IN_MILLISECONDS = 1000 * 20;

    /**
     * The fastest rate for active location updates. Exact. Updates will never be
     * more frequent than this value.
     */
    private static final long FASTEST_UPDATE_INTERVAL_IN_MILLISECONDS = UPDATE_INTERVAL_IN_MILLISECONDS / 2;
    /**
     * Constant used in the location settings dialog.
     */
    public static final int REQUEST_CHECK_SETTINGS = 1005;
    public static MethodChannel.Result mResult = null;

    private static boolean isDialogShowing = false;
    static Activity context;

    public static void init(Context cxt) {
        mSettingsClient = LocationServices.getSettingsClient(cxt);
        createLocationRequest();
        buildLocationSettingsRequest();
        context = (Activity) cxt;
    }

    /**
     * Sets up the location request. Android has two location request settings:
     * {@code ACCESS_COARSE_LOCATION} and {@code ACCESS_FINE_LOCATION}. These
     * settings control the accuracy of the current location. This sample uses
     * ACCESS_FINE_LOCATION, as defined in the AndroidManifest.xml.
     * <p/>
     * When the ACCESS_FINE_LOCATION setting is specified, combined with a fast
     * update interval (5 seconds), the Fused Location Provider API returns location
     * updates that are accurate to within a few feet.
     * <p/>
     * These settings are appropriate for mapping applications that show real-time
     * location updates.
     */
    private static void createLocationRequest() {
        mLocationRequest = new LocationRequest();
        // Sets the desired interval for active location updates. This interval is
        // inexact. You may not receive updates at all if no location sources are
        // available, or
        // you may receive them slower than requested. You may also receive updates
        // faster than
        // requested if other applications are requesting location at a faster interval.
        mLocationRequest.setInterval(UPDATE_INTERVAL_IN_MILLISECONDS);
        // Sets the fastest rate for active location updates. This interval is exact,
        // and your
        // application will never receive updates faster than this value.
        mLocationRequest.setFastestInterval(FASTEST_UPDATE_INTERVAL_IN_MILLISECONDS);

        mLocationRequest.setPriority(LocationRequest.PRIORITY_HIGH_ACCURACY);
    }

    /**
     * Uses a
     * {@link com.google.android.gms.location.LocationSettingsRequest.Builder} to
     * build a {@link com.google.android.gms.location.LocationSettingsRequest} that
     * is used for checking if a device has the needed location settings.
     */
    private static void buildLocationSettingsRequest() {
        LocationSettingsRequest.Builder builder = new LocationSettingsRequest.Builder();
        builder.addLocationRequest(mLocationRequest);
        mLocationSettingsRequest = builder.build();
    }

    /**
     * Requests location updates from the FusedLocationApi. Note: we don't call this
     * unless location runtime permission has been granted.
     */
    public static void checkLocation(final Activity activity, MethodChannel.Result result) {
        if (activity == null) {
            return;
        }

        if(mLocationSettingsRequest==null){
            buildLocationSettingsRequest();
        }
        // Begin by checking if the device has the necessary location settings.
        // if (isDialogShowing) return;
        Log.i("checkLocation", "checkLocation");

        mResult = result;
        mSettingsClient.checkLocationSettings(mLocationSettingsRequest)
                .addOnSuccessListener(activity, new OnSuccessListener<LocationSettingsResponse>() {
                    @Override
                    public void onSuccess(LocationSettingsResponse locationSettingsResponse) {
                        Log.i("", "All location settings are satisfied.");
                        isDialogShowing = false;
                        try {
                            if (mResult != null)
                                mResult.success(true);
                        } catch (IllegalStateException w) {
                            w.printStackTrace();
                        }
                        // noinspection MissingPermission

                    }
                }).addOnFailureListener((Activity) activity, new OnFailureListener() {
            @Override
            public void onFailure(@NonNull Exception e) {
                int statusCode = ((ApiException) e).getStatusCode();
                switch (statusCode) {
                    case LocationSettingsStatusCodes.RESOLUTION_REQUIRED:
                        Log.i("TAG", "Location settings are not satisfied. Attempting to upgrade "
                                + "location settings ");

                        if (isDialogShowing)
                            return;
                        try {
                            // Show the dialog by calling startResolutionForResult(), and check the
                            // result in onActivityResult().
                            ResolvableApiException rae = (ResolvableApiException) e;
                            rae.startResolutionForResult((Activity) activity, REQUEST_CHECK_SETTINGS);
                            isDialogShowing = true;

                        } catch (IntentSender.SendIntentException sie) {
                            Log.i("TAG", "PendingIntent unable to execute request.");
                            isDialogShowing = false;

                        }
                        break;
                    case LocationSettingsStatusCodes.SETTINGS_CHANGE_UNAVAILABLE:
                        try {
                            if (mResult != null)
                                mResult.success(false);
                        } catch (IllegalStateException w) {
                            w.printStackTrace();
                        }
                        String errorMessage = "Location settings are inadequate, and cannot be "
                                + "fixed here. Fix in Settings.";
                        Log.e("TAG", errorMessage);
                        Toast.makeText(activity, errorMessage, Toast.LENGTH_LONG).show();
                        // mRequestingLocationUpdates = false;
                        isDialogShowing = false;

                        break;
                    default:
                        isDialogShowing = false;
                        try {
                            if (mResult != null)
                                mResult.success(false);
                        } catch (IllegalStateException w) {
                            w.printStackTrace();
                        }
                        break;
                }

            }
        });
    }


    public static boolean isMyServiceRunning(Context activity, Class<?> serviceClass) {
        ActivityManager manager = (ActivityManager) activity.getSystemService(Context.ACTIVITY_SERVICE);
        for (ActivityManager.RunningServiceInfo service : manager.getRunningServices(Integer.MAX_VALUE)) {
            if (serviceClass.getName().equals(service.service.getClassName())) {
                return true;
            }
        }
        return false;
    }

    public static void handlePermissionPopup(boolean granted, Activity activity) {
        isDialogShowing = false;

        if (granted) {
            try {
                if (mResult != null) {
                    mResult.success(true);
                }
            } catch (IllegalStateException w) {
                w.printStackTrace();
            }
        } else {
            LocationUtil.checkLocation(activity, mResult);
        }

    }

}

