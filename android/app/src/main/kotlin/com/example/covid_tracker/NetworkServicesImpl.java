package com.example.covid_tracker;

import android.util.Log;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.JsonObject;

import org.json.JSONObject;

import java.util.concurrent.TimeUnit;

import okhttp3.OkHttpClient;
import okhttp3.RequestBody;
import okhttp3.logging.HttpLoggingInterceptor;
import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Retrofit;
import retrofit2.converter.gson.GsonConverterFactory;
import retrofit2.converter.scalars.ScalarsConverterFactory;

public class NetworkServicesImpl implements NetworkServices {
    private static Gson gson = new GsonBuilder()
            .setLenient()
            .create();
    private static OkHttpClient okHttpClient = new OkHttpClient.Builder()
            .readTimeout(300, TimeUnit.SECONDS)
            .connectTimeout(360, TimeUnit.SECONDS)
            .cache(null)
            .build();
    //Singleton instance
    private static volatile NetworkServicesImpl sInstance;
    private static Retrofit.Builder builder =
            new Retrofit.Builder()
                    .addConverterFactory(GsonConverterFactory.create(gson));
    //APIServices instance
    ApiServicesList mAPIServices = null;
    //Retrofit instance
    private Retrofit mRetrofit = null;

    /**
     * Constructor is made private to make sure that outside classes can't instantiate it to constructor.
     * Thus sticking to the singleton pattern
     */
    private NetworkServicesImpl() {
        HttpLoggingInterceptor logging = new HttpLoggingInterceptor();
        logging.level(HttpLoggingInterceptor.Level.BODY);
        okHttpClient = new OkHttpClient.Builder()
                .readTimeout(300, TimeUnit.SECONDS)
                .connectTimeout(360, TimeUnit.SECONDS)
                .addInterceptor(logging)
                .cache(null)
                .build();
        mAPIServices = createService(ApiServicesList.class);
    }

    private static <S> S createService(Class<S> serviceClass) {
        Retrofit retrofit = builder.client(okHttpClient)

                .baseUrl("https://us-central1-covid-tracker-85a72.cloudfunctions.net/")
                .addConverterFactory(ScalarsConverterFactory.create()) //important
                .addConverterFactory(GsonConverterFactory.create(gson)).build();
        return retrofit.create(serviceClass);
    }

    /**
     * @return Singleton instance of the ServiceHolder class
     */
    public static NetworkServices getInstance() {
        if (null == sInstance) {
            synchronized (NetworkServicesImpl.class) {
                sInstance = new NetworkServicesImpl();
            }
        }
        return sInstance;
    }

    @Override
    public void sendLocation(String contentType, JsonObject request, Callback<JsonObject> listener) {
        Call<JsonObject> call = mAPIServices
                .sendLocation(contentType, request);
        call.enqueue(listener);
    }
}

