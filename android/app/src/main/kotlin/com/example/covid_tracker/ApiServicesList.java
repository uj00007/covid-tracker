package com.example.covid_tracker;


import com.google.gson.JsonObject;

import org.json.JSONObject;

import okhttp3.RequestBody;
import retrofit2.Call;
import retrofit2.http.Body;
import retrofit2.http.Header;
import retrofit2.http.POST;
import retrofit2.http.Url;

public interface ApiServicesList {
    @POST("/updateLocation")
    Call<JsonObject> sendLocation(@Header("Content-Type") String contentType,
                                  @Body  JsonObject body

    );
}
