package com.lambdadigamma.fuel.data

/**
 * Currently supported are three fuel types:
 * diesel, e5 and e10.
 */
enum class FuelType(var value: String) {
    DIESEL("diesel"),
    E5("e5"),
    E10("e10");

    fun localizedName(): String {
        return when (this) {
            DIESEL -> "Diesel"
            E5 -> "E5"
            E10 -> "E10"
        }
    }

    fun apiValue(): String {
        return when (this) {
            DIESEL -> "diesel"
            E5 -> "e5"
            E10 -> "e10"
        }
    }

    companion object {
        fun fromString(s: String): FuelType {
            return when (s) {
                DIESEL.value -> DIESEL
                E5.value -> E5
                E10.value -> E10
                else -> throw IllegalArgumentException("Unknown fuel type: $s")
            }
        }
    }
}