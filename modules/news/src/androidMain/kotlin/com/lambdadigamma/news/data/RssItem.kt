package com.lambdadigamma.newsfeature.data

import androidx.room.ColumnInfo
import androidx.room.Entity
import androidx.room.Index
import java.io.Serializable
import java.text.ParseException
import java.text.SimpleDateFormat
import java.util.*

@Entity(
    tableName = "rss_items",
    primaryKeys = ["id"],
    indices = [Index(value = ["guid"], unique = true)]
)
class RssItem() : Serializable {

    init {

    }

    //    @PrimaryKey(autoGenerate = true)
    @ColumnInfo(name = "id")
    var id: Int? = null

    lateinit var guid: String

    var title: String = ""
        set(title) {
            field = title.replace("&#39;", "'").replace("&#039;", "'")
        }

    var link: String? = null
        set(link) {
            field = link?.trim { it <= ' ' }
        }

    var image: String? = null
    var publishDate: String? = null
    var description: String? = null

    val date: Date?
        get() {
            publishDate?.let {
                return try {
                    dateFormat.parse(it)
                } catch (e: ParseException) {
                    null
                }
            }
            return null
        }

    override fun toString(): String {
        val builder = StringBuilder()
        builder.append(title).append("\n")
        if (link != null) {
            builder.append(link).append("\n")
        }
        if (image != null) {
            builder.append(image).append("\n")
        }
        if (description != null) {
            builder.append(description)
        }
        return builder.toString()
    }

    override fun equals(other: Any?): Boolean {
        if (this === other) return true
        if (javaClass != other?.javaClass) return false

        other as RssItem

        if (title != other.title) return false
        if (link != other.link) return false
        if (image != other.image) return false
        if (publishDate != other.publishDate) return false
        if (description != other.description) return false

        return true
    }

    override fun hashCode(): Int {
        var result = title.hashCode()
        result = 31 * result + (link?.hashCode() ?: 0)
        result = 31 * result + (image?.hashCode() ?: 0)
        result = 31 * result + (publishDate?.hashCode() ?: 0)
        result = 31 * result + (description?.hashCode() ?: 0)
        return result
    }

    companion object {
        private val dateFormat = SimpleDateFormat("E, dd MMM yyyy HH:mm:ss z", Locale.US)
    }

}