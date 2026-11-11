package com.lambdadigamma.moers

object Destinations {

    /** Routes of the nested navigation graphs that back the top level tabs. */
    object Tabs {
        const val dashboard = "tab/dashboard"
        const val news = "tab/news"
        const val explore = "tab/explore"
        const val events = "tab/events"
    }

    object Onboarding {
        const val graph = "onboardingGraph"
        const val welcome = "onboarding/welcome"
        const val about = "onboarding/about"
        const val userTypeSelection = "onboarding/user-type"
        const val location = "onboarding/location"
        const val notifications = "onboarding/notifications"
        const val rubbishStreet = "onboarding/rubbishStreet"
        const val fuel = "onboarding/fuel"
        const val done = "onboarding/done"
    }

    const val graph = "main"

    /** Deep links used by launcher shortcuts. */
    object DeepLinks {
        const val events = "meinmoers://events"
        const val rubbish = "meinmoers://rubbish"
        const val fuel = "meinmoers://fuel"
    }
    const val rubbishList = "rubbish"
    const val rubbishStreet = "rubbish/street"

    const val fuelList = "fuel"
    const val fuelStationDetail = "fuel-stations/{id}"

    const val dashboard = "dashboard"
    const val news = "news"
    const val explore = "explore"
    const val map = "map"
    const val events = "events"
    const val eventDetail = "events/{id}"

    const val parkingAreas = "parking-areas"
    const val parkingAreaDetail = "parking-areas/{id}"

    const val radioBroadcasts = "radio-broadcasts"
    const val radioBroadcastDetail = "radio-broadcasts/{id}"

    const val search = "search"
    const val other = "other"

    const val settings = "settings"
    const val about = "about"
    const val feedback = "feedback"
}