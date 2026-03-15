package com.lambdadigamma.pages.data.local.dao

import androidx.lifecycle.LiveData
import androidx.room.Dao
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import androidx.room.Transaction
import androidx.room.Upsert
import com.lambdadigamma.pages.data.local.model.PageBlockCached
import com.lambdadigamma.pages.data.local.model.PageCached
import com.lambdadigamma.pages.data.local.model.PageWithBlocksCached
import kotlinx.coroutines.flow.Flow

@Dao
interface PageDao {

    @Upsert
    suspend fun savePages(events: List<PageCached>)

    @Query("SELECT * FROM pages")
    fun getAllPages(): Flow<List<PageCached>>

    @Query("SELECT * FROM pages WHERE id = :id")
    fun getPage(id: Int): Flow<PageCached?>

    @Transaction
    @Query("SELECT * FROM pages WHERE id = :pageId")
    fun getPageWithBlocks(pageId: Int): Flow<PageWithBlocksCached?>

    // ---- Page Blocks ----

    @Upsert
    suspend fun savePageBlocks(events: List<PageBlockCached>)

    @Query("SELECT * FROM page_blocks WHERE pageID = :pageID")
    fun getAllBlocks(pageID: Int): Flow<List<PageBlockCached>>

    @Query("DELETE FROM page_blocks WHERE pageID IN (:pageIds)")
    suspend fun deletePageBlocksByPageIds(pageIds: List<Int>)

}