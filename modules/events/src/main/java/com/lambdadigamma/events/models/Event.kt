package com.lambdadigamma.events.models

import androidx.room.Embedded
import androidx.room.Entity
import androidx.room.PrimaryKey
import com.google.gson.annotations.SerializedName
import com.lambdadigamma.core.futureDate
import java.util.*

const val eventActiveMinuteThreshold = 30

fun List<Event>.filterEvents(): List<Event> {

    val current = Date()

    return this
        .sortedBy { it.startDate ?: futureDate() }
        .filter { event ->

            val start = event.startDate
            val end = event.endDate

            if (start != null && end != null) {
                if (start >= current && end >= current) {
                    return@filter true
                } else return@filter current >= start && current <= end
            }
            if (start != null) {

                val calendar = Calendar.getInstance()
                calendar.time = start
                calendar.add(
                    Calendar.MINUTE,
                    eventActiveMinuteThreshold
                )

                return@filter calendar.time >= current

            } else {
                return@filter true
            }

        }

}

@Entity(tableName = "events")
data class Event(
    @PrimaryKey var id: Int = 0,
    var name: String = "",
    var description: String? = null,
    var url: String? = null,
    @SerializedName("start_date") var startDate: Date? = null,
    @SerializedName("end_date") var endDate: Date? = null,
    var category: String? = null,
    @SerializedName("image_path") var imagePath: String? = null,
    @SerializedName("organisation_id") var organisationID: Int? = null,
//    @Ignore var organisation: Organisation? = null,
//    @Embedded(prefix = "entry") var entry: Entry? = null,
//    @Embedded(prefix = "extras") var extras: EventExtras? = null,
    @Embedded(prefix = "extras") var extras: EventExtras? = null,
    @SerializedName("created_at") var createdAt: Date? = null,
    @SerializedName("updated_at") var updatedAt: Date? = null
) {

    constructor() : this(name = "")

    constructor(id: Int, name: String, startDate: Date?, endDate: Date?) : this() {
        this.id = id
        this.name = name
        this.startDate = startDate
        this.endDate = endDate
    }

//    val subtitle: String
//        get() {
//
//            val start = startDate
//
//            if (start != null) {
//
//                if (isActive) {
//                    return "$locationString • ${MMAPI.instance.getString(R.string.live_now)}"
//                } else if (start.isInBeforeInterval(59.0)) {
//                    return "$locationString • $countdownString"
//                }
//
//            }
//
//            return "$locationString • $timeString"
//
//        }
//
//    val detailSubtitle: String
//        get() {
//
//            var ticket = ""
//            val extras = extras
//
//            extras?.let {
//
//                extras.isFree?.let {
//                    if (it) {
//                        ticket += " • " + MMAPI.instance.getString(R.string.free)
//                    }
//                }
//                extras.visitWithExtraTicket?.let {
//                    if (it) {
//                        ticket += " • " + MMAPI.instance.getString(R.string.festival_ticket_additional_ticket)
//                    }
//                }
//                extras.needsFestivalTicket?.let {
//                    if (it) {
//                        ticket += " • " + MMAPI.instance.getString(R.string.entry_festival_ticket)
//                    }
//                }
//
//            }
//
//            return subtitle + ticket
//
//        }
//
//    val localizedDescription: String
//        get() {
//
//            if (Locale.getDefault().language == "de") {
//                return this.description ?: ""
//            }
//            return this.extras?.descriptionEN ?: this.description ?: ""
//
//        }
//
//    val hideTicketText: Boolean
//        get() {
//            return !(this.extras?.visitWithExtraTicket ?: false)
//        }
//
//    val isActive: Boolean
//        get() {
//            val current = Date()
//            val startDate = startDate
//
//            if (startDate != null && endDate != null) {
//                return current >= startDate && current <= endDate
//            }
//
//            if (startDate != null) {
//
//                val calendar = Calendar.getInstance()
//                calendar.time = startDate
//                calendar.add(Calendar.MINUTE, eventActiveMinuteThreshold)
//
//                return startDate <= current && calendar.time >= current
//
//            }
//
//            return false
//        }
//
//    var isLiked: Boolean
//        get() {
//            return LikeService.isLiked(this.id)
//        }
//        set(value) {
//            LikeService.setLikeStatus(value, this.id)
//        }
//
//    private val locationString: String
//        get() {
//
//            extras?.isMovingAct?.let {
//                if (it) {
//                    return "Moving Act"
//                }
//            }
//
//            val location = getLocation()
//            val locationUnknown = MMAPI.instance.getString(R.string.site_soon)
//
//            if (location != null) {
//                return location.name
//            } else {
//                extras?.let {
//                    return it.location ?: locationUnknown
//                }
//            }
//
//            return locationUnknown
//
//        }
//
//    private val timeString: String
//        get() {
//            val timeComponents = time
//
//            if (startDate != null && endDate != null) {
//
//                return "${timeComponents.day}, ${timeComponents.date} ${timeComponents.startTime} - ${timeComponents.endTime}"
//
//            } else if (startDate != null) {
//
//                val calendar = Calendar.getInstance(Locale.getDefault())
//                calendar.time = startDate
//
//                return if (calendar.get(Calendar.HOUR_OF_DAY) == 0 && calendar.get(Calendar.MINUTE) == 0) {
//                    "${timeComponents.day}, ${timeComponents.date}"
//                } else {
//                    "${timeComponents.day}, ${timeComponents.date} ${timeComponents.startTime}"
//                }
//
//            } else {
//                return MMAPI.instance.getString(R.string.known_soon)
//            }
//
//        }
//
//    private val countdownString: String
//        get() {
//
//            val startDate = startDate
//
//            return if (startDate != null) {
//                "in ${startDate.minuteInterval()}min"
//            } else {
//                ""
//            }
//
//        }
//
//    private val time: TimeComponent
//        get() {
//
//            val day =
//                SimpleDateFormat("EEEE", Locale.getDefault()).format(startDate).subSequence(0, 2)
//                    .toString()
//            val date = SimpleDateFormat("dd.MM.", Locale.getDefault()).format(startDate)
//            val startTime = SimpleDateFormat("HH:mm", Locale.getDefault()).format(startDate)
//
//            if (endDate != null) {
//                val endTime = SimpleDateFormat("HH:mm", Locale.getDefault()).format(endDate)
//                return TimeComponent(day, date, startTime, endTime)
//            }
//
//            return TimeComponent(day, date, startTime, "")
//
//        }

//    fun getLocation(): Entry? {
//
//        entry?.let {
//            return it
//        }
//
//        val e = extras
//
//        e?.let {
//
//            if (e.location != null && e.street != null &&
//                e.houseNumber != null && e.postcode != null &&
//                e.place != null && e.lat != null && e.lng != null
//            ) {
//
//                return Entry(
//                    Random.nextInt(6000, 12000),
//                    e.location,
//                    e.street,
//                    e.houseNumber,
//                    e.postcode,
//                    e.place,
//                    e.lat,
//                    e.lng,
//                    Date(),
//                    Date()
//                )
//
//            }
//        }

    // TODO:
//        e?.let {
//            if (e.location != null && e.street != null &&
//                e.houseNumber != null && e.postcode != null &&
//                e.place != null && e.lat != null && e.lng != null
//            ) {
//
//                return Entry(
//
//                    Random.nextInt(6000, 12000),
//                    e.location,
//                    e.street,
//                    e.houseNumber,
//                    e.postcode,
//                    e.place,
//                    e.lat,
//                    e.lng,
//                    Date(),
//                    Date()
//                )
//
//            }
//        }
//
//        return null
//
//    }

    data class TimeComponent(
        val day: String,
        val date: String,
        val startTime: String,
        val endTime: String
    )

}