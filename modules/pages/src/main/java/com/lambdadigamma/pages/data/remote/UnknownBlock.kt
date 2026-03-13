package com.lambdadigamma.pages.data.remote

import com.google.gson.annotations.SerializedName
import com.lambdadigamma.pages.data.remote.model.SomeBlockData
import com.lambdadigamma.prosemirror.Document
import kotlinx.parcelize.Parcelize

@Parcelize
data class UnknownBlock(val placeholder: String? = "") : SomeBlockData {

}