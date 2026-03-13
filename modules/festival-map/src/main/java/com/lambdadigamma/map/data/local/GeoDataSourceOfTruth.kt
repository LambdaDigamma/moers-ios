package com.lambdadigamma.map.data.local

import com.google.maps.android.data.geojson.GeoJsonFeature
import com.lambdadigamma.map.data.model.GeoDataLayer
import com.lambdadigamma.map.data.model.GeoDataLayerLocal
import com.lambdadigamma.map.data.remote.models.FGDResourceKey
import kotlinx.coroutines.flow.flow
import org.mobilenativefoundation.store.store5.SourceOfTruth
import org.mobilenativefoundation.store.store5.StoreReadResponseOrigin

object GeoDataSourceOfTruth {

//    fun provide(): SourceOfTruth<FGDResourceKey, GeoDataLayerLocal, GeoDataLayer> = SourceOfTruth.of(
//        reader = { key: FGDResourceKey ->
////            require(key is FGDResourceKey.)
//            flow {
//
//
//
//                when (key) {
//                    is FGDResourceKey
//                    is NotesKey.Read.ByNoteId -> emit(db.getNoteById(key.noteId))
//                    is NotesKey.Read.ByAuthorId -> emit(db.getNotesByAuthorId(key.authorId))
//                    is NotesKey.Read.Paginated -> emit(db.getNotes(key.start, key.size))
//                }
//            }
//        },
//        writer = { key: NotesKey, input: SOT ->
////            require(key is NotesKey.Write)
//            when (key) {
//                is NotesKey.Write.Create -> db.create(input)
//                is NotesKey.Write.ById -> db.update(key.noteId, input)
//            }
//        },
////        delete = { key: NotesKey ->
////            require(key is NotesKey.Clear.ById)
////            db.deleteById(key.noteId)
////        },
////        deleteAll = db.delete()
//    )

}

//interface GeoDataSourceOfTruth<Key : Any, SOT : Any> {
//    companion object {
//        fun <Key : Any, SOT : Any> of(
//            reader: (Key) -> Flow<SOT?>,
//            writer: suspend (Key, SOT) -> Unit,
//            delete: (suspend (Key) -> Unit)? = null,
//            deleteAll: (suspend () -> Unit)? = null
//        ): GeoDataSourceOfTruth<Key, SOT>
//    }
//}