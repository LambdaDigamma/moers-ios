package app.moers.news.data

import okhttp3.ResponseBody
import org.xml.sax.InputSource
import retrofit2.Converter
import javax.xml.parsers.SAXParserFactory

class RssResponseBodyConverter : Converter<ResponseBody, List<RssItem>> {

    override fun convert(value: ResponseBody): List<RssItem>? {

        val rssFeed = RssFeed()
        try {
            val parser = XMLParser()
            val parserFactory = SAXParserFactory.newInstance()
            val saxParser = parserFactory.newSAXParser()
            val xmlReader = saxParser.xmlReader
            xmlReader.contentHandler = parser
            val inputSource = InputSource(value.charStream())
            xmlReader.parse(inputSource)
            val items = parser.items
            rssFeed.items = items
        } catch (e: Exception) {
            e.printStackTrace()
        }

        return rssFeed.items
    }

}