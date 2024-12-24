package app.moers.news.data

import okhttp3.ResponseBody
import retrofit2.Converter
import retrofit2.Retrofit
import java.lang.reflect.Type

class RssConverterFactory
/**
 * Constructor
 */
private constructor() : Converter.Factory() {

    override fun responseBodyConverter(
        type: Type?,
        annotations: Array<Annotation>?,
        retrofit: Retrofit?
    ): Converter<ResponseBody, *> = RssResponseBodyConverter()

    companion object {

        fun create(): RssConverterFactory {
            return RssConverterFactory()
        }
    }
}