package app.moers.core.user

enum class UserType(var value: String) {
    CITIZEN("citizen"),
    VISITOR("visitor");

    companion object {
        fun fromString(value: String): UserType {
            return values().first { it.value == value }
        }
    }
}