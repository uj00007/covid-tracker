package com.example.covid_tracker;


import com.google.gson.JsonObject;

import org.json.JSONObject;

import okhttp3.RequestBody;
import retrofit2.Callback;

public interface NetworkServices {
    void sendLocation(String contentType, JsonObject request, Callback<JsonObject> listener);

}

