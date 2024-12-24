package com.lambdadigamma.core

data class Resource<ResultType>(
    var status: Status,
    var data: ResultType? = null,
    var errorMessage: String? = null
) {

    companion object {

        fun <ResultType> success(data: ResultType): Resource<ResultType> =
            Resource(Status.SUCCESS, data)

        fun <ResultType> loading(): Resource<ResultType> = Resource(Status.LOADING)

        fun <ResultType> error(message: String?): Resource<ResultType> =
            Resource(Status.ERROR, errorMessage = message)
    }

    fun isLoading(): Boolean = status == Status.LOADING

    fun shouldBeRedacted(): Boolean = status == Status.LOADING || status == Status.ERROR

    fun isSuccessful(): Boolean = status == Status.SUCCESS

    fun <Other> transform(transformation: (ResultType) -> Other): Resource<Other> {
        return when (status) {
            Status.SUCCESS -> Resource.success(transformation(data!!))
            Status.LOADING -> Resource.loading()
            Status.ERROR -> Resource.error(errorMessage)
        }
    }

}

fun <T> Result<T>.toResource(): Resource<T> {
    return if (this.isSuccess) {
        Resource.success(this.getOrNull()!!)
    } else {
        Resource.error(this.exceptionOrNull()?.message ?: "")
    }
}