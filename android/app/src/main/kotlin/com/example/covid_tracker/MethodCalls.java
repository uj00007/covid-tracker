package com.example.covid_tracker;

public class MethodCalls {
    public interface Location {
        String START_LOCATION_FETCH = "locationServiceStart";
        String GET_CURRENT_LOCATION = "oneTimeLocationPing";
        String STOP_LOCATION_FETCH = "locationServiceEnd";
        String CHECK_LOCATION_PERM = "checkLocationPerm";
    }
}
