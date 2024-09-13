package com.lambdadigamma.core.geo

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
