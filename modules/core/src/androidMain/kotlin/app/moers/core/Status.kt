package app.moers.core

enum class Status {
    SUCCESS,
    ERROR,
    LOADING;

    fun isSuccessful() = this == SUCCESS

    fun isLoading() = this == LOADING

    fun isFailed() = this == ERROR

}