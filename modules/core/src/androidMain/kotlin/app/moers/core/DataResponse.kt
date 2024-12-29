package app.moers.core

import com.google.gson.annotations.SerializedName

data class DataResponse<WrappedData>(@SerializedName("data") val data: WrappedData)