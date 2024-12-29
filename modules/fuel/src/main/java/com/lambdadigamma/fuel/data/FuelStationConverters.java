package com.lambdadigamma.fuel.data;

import androidx.room.TypeConverter;

import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;

import java.lang.reflect.Type;
import java.util.ArrayList;

public class FuelStationConverters {

    @TypeConverter
    public static ArrayList<FuelStationTimeEntry> fromString(String value) {
        Type listType = new TypeToken<ArrayList<FuelStationTimeEntry>>() {
        }.getType();
        return new Gson().fromJson(value, listType);
    }

    @TypeConverter
    public static String fromArrayList(ArrayList<FuelStationTimeEntry> list) {
        Gson gson = new Gson();
        return gson.toJson(list);
    }

}