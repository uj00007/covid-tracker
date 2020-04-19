package com.example.covid_tracker;


import android.app.Activity;
import android.content.Intent;
import android.util.Log;

import androidx.core.content.ContextCompat;

import java.util.Map;

import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry;

public class LocationPackagePlugin implements FlutterPlugin, MethodChannel.MethodCallHandler, PluginRegistry.ActivityResultListener {
    static public MethodChannel methodChannel;

    @Override
    public void onAttachedToEngine(FlutterPluginBinding binding) {
        methodChannel = new MethodChannel(binding.getFlutterEngine().getDartExecutor(), MethodChannels.LOCATION_FETCH_CHANNEL);
        methodChannel.setMethodCallHandler(this);
        LocationUtil.init(MainActivity.activity);

    }

    @Override
    public void onDetachedFromEngine(FlutterPluginBinding binding) {

    }
    /**
     * Plugin registration.
     */
    public static void registerWith(PluginRegistry.Registrar registrar) {
        methodChannel = new MethodChannel(registrar.messenger(), MethodChannels.LOCATION_FETCH_CHANNEL);
        LocationPackagePlugin plugin = new LocationPackagePlugin();
        methodChannel.setMethodCallHandler(plugin);
//        activity = registrar.activity();
        registrar.addActivityResultListener(plugin);
        LocationUtil.init(MainActivity.activity);
    }

    @Override
    public void onMethodCall(MethodCall methodCall, MethodChannel.Result result) {
        String callName = methodCall.method.trim();
        switch (callName) {
            case MethodCalls.Location.CHECK_LOCATION_PERM:
                LocationUtil.checkLocation(MainActivity.activity, result);
                break;
             case MethodCalls.Location.START_LOCATION_FETCH:
                 Map locationServiceData = (Map) methodCall.arguments;
                 Intent intent = getIntentWithExtras(locationServiceData);
                ContextCompat.startForegroundService(MainActivity.activity, intent);
                result.success("done");
                break;
            case MethodCalls.Location.STOP_LOCATION_FETCH:
                try {
                    if (LocationUtil.isMyServiceRunning(MainActivity.activity, LocationService.class)){
                        intent = new Intent(MainActivity.activity, LocationService.class);
                        intent.setAction("stop");
                        MainActivity.activity.stopService(intent);
//                    new Handler().postDelayed(() -> LocationUtil.stopContinuousLocation(activity), 500);
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                }
                break;
            default:
                result.notImplemented();
        }
    }


    private Intent getIntentWithExtras(Map locationServiceData) {
        Intent intent = new Intent(MainActivity.activity, LocationService.class);
        intent.putExtra("email", "" + locationServiceData.get("email"));
        intent.putExtra("id", "" + locationServiceData.get("id"));

        intent.setAction("start");
        return intent;
    }

    @Override
    public boolean onActivityResult(int requestCode, int resultCode, Intent data) {
        Log.e("Ign Package onAResult", "" + requestCode);
        if (requestCode == LocationUtil.REQUEST_CHECK_SETTINGS) {
            Log.d("ActivityResult", "requestCode :" + requestCode);
            Log.d("ActivityResult", "resultCode : " + resultCode);

            switch (resultCode) {
                case Activity.RESULT_OK: {
                    // All required changes were successfully made
                    LocationUtil.handlePermissionPopup(true,MainActivity.activity);
                    break;
                }
                case Activity.RESULT_CANCELED: {
                    // The user was asked to change settings, but chose not to

                    LocationUtil.handlePermissionPopup(false, MainActivity.activity);
                    break;
                }
                default: {
                    break;
                }
            }
        } else {
            return false;
        }

        return true;
    }


}
