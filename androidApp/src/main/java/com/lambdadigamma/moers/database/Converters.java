package com.lambdadigamma.moers.database;

import androidx.room.TypeConverter;

import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;

import java.lang.reflect.Type;
import java.util.ArrayList;
import java.util.Date;

public class Converters {

    @TypeConverter
    public static Date fromTimestamp(Long value) {
        return value == null ? null : new Date(value);
    }

    @TypeConverter
    public static Long dateToTimestamp(Date date) {
        return date == null ? null : date.getTime();
    }

//    @TypeConverter
//    public static ArrayList<PetrolStationTimeEntry> fromString(String value) {
//        Type listType = new TypeToken<ArrayList<PetrolStationTimeEntry>>() {
//        }.getType();
//        return new Gson().fromJson(value, listType);
//    }
//
//    @TypeConverter
//    public static String fromArrayList(ArrayList<PetrolStationTimeEntry> list) {
//        Gson gson = new Gson();
//        return gson.toJson(list);
//    }

    @TypeConverter
    public static ArrayList<String> stringArrayListFromString(String value) {
        Type listType = new TypeToken<ArrayList<String>>() {
        }.getType();
        return new Gson().fromJson(value, listType);
    }

    @TypeConverter
    public static String stringFromArrayList(ArrayList<String> list) {
        Gson gson = new Gson();
        return gson.toJson(list);
    }

//    @TypeConverter
//    public static RubbishWasteType wasteTypeFromString(String value) {
//        return value == null ? null : RubbishWasteType.valueOf(value.toUpperCase(Locale.ROOT));
//    }
//
//    @TypeConverter
//    public static String stringFromWasteType(RubbishWasteType type) {
//        return type == null ? null : type.getValue();
//    }

}