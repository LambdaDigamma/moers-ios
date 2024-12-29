package com.lambdadigamma.rubbish

data class RubbishCollectionDate(
    val id: Int,
    val date: String,
    val residualWaste: Int?,
    val organicWaste: Int?,
    val paperWaste: Int?,
    val yellowBag: Int?,
    val greenWaste: Int?
)