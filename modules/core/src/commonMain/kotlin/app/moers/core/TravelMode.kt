package app.moers.core

enum class TravelMode {
    DRIVING,
    WALKING,
    BICYCLING,
    TRANSIT;

    fun toGoogleMapsMode(): String {
        return when (this) {
            DRIVING -> "driving"
            WALKING -> "walking"
            BICYCLING -> "bicycling"
            TRANSIT -> "transit"
        }
    }
}