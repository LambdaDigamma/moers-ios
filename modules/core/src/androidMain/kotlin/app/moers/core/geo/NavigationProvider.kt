package app.moers.core.geo

import app.moers.core.TravelMode

interface NavigationProvider {

    fun startNavigation(
        latitude: Double,
        longitude: Double,
        travelMode: TravelMode = TravelMode.DRIVING
    )

    fun startNavigation(
        destination: Point,
        travelMode: TravelMode = TravelMode.DRIVING
    )

}
