package app.moers.core.media


data class Media(
    val id: Int,
    val modelType: String,
    val modelId: Int,
    val uuid: String?,
    val collectionName: String,
    val name: String,
    val fileName: String
) : MediaImageDisplayable {

    override fun data(width: Int, height: Int): Any {
        return "https://picsum.photos/$width/$height"
    }

    override fun contentDescription(): String? {
        return null
    }

}
