package com.lambdadigamma.rubbish

import androidx.annotation.Nullable
import androidx.room.ColumnInfo
import androidx.room.Entity
import androidx.room.PrimaryKey
import com.google.gson.annotations.SerializedName

@Entity(tableName = "rubbish_streets")
data class RubbishCollectionStreet(
    @PrimaryKey
    @ColumnInfo(name = "id")
    @SerializedName("id")
    var id: Int,

    @SerializedName("name")
    @ColumnInfo(name = "name")
    val name: String,

    @Nullable
    @SerializedName("street_addition")
    @ColumnInfo(name = "street_addition")
    val streetAddition: String?,

    @SerializedName("residual_tour")
    @ColumnInfo(name = "residual_tour")
    val residualWasteTour: Int,

    @SerializedName("organic_tour")
    @ColumnInfo(name = "organic_tour")
    val organicWasteTour: Int,

    @SerializedName("paper_tour")
    @ColumnInfo(name = "paper_tour")
    val paperWasteTour: Int,

    @SerializedName("plastic_tour")
    @ColumnInfo(name = "plastic_tour")
    val plasticWasteTour: Int,

    @SerializedName("cuttings_tour")
    @ColumnInfo(name = "cuttings_tour")
    val cuttingsWasteTour: Int,

    @Nullable
    @SerializedName("sweeper_day")
    @ColumnInfo(name = "sweeper_day")
    val sweeperDay: String? = "",

    @SerializedName("year")
    val year: Int
) {

    val displayName: String
        get() {
            return "${this.name} ${this.streetAddition ?: ""}"
        }

}