package com.lambdadigamma.core;

import androidx.room.TypeConverter;

import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;

import java.lang.reflect.Type;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

public class Converters {

    @TypeConverter
    public static Date toDate(Long dateLong) {
        return dateLong == null ? null: new Date(dateLong);
    }

    @TypeConverter
    public static Long fromDate(Date date){
        return date == null ? null : date.getTime();
    }

//    @TypeConverter
//    public static Date fromTimestamp(Long value) {
//        return value == null ? null : new Date(value);
//    }
//
//    @TypeConverter
//    public static Long dateToTimestamp(Date date) {
//        return date == null ? null : date.getTime();
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

    @TypeConverter
    public static List<String> stringListFromString(String value) {
        Type listType = new TypeToken<List<String>>() {
        }.getType();
        return new Gson().fromJson(value, listType);
    }

    @TypeConverter
    public static String stringFromList(List<String> list) {
        Gson gson = new Gson();
        return gson.toJson(list);
    }

}