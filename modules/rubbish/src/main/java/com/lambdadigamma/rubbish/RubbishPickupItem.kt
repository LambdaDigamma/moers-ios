package com.lambdadigamma.rubbish

//import androidx.room.Entity
//import com.google.gson.annotations.SerializedName
import androidx.room.Entity
import com.google.gson.annotations.SerializedName
import java.util.*

@Entity(tableName = "rubbish_pickup_items", primaryKeys = ["date", "type"])
data class RubbishPickupItem(
    @SerializedName("date")
    val date: Date,
    @SerializedName("type")
    val type: RubbishWasteType
)