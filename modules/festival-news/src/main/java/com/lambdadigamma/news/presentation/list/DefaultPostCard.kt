package com.lambdadigamma.news.presentation.list

import android.text.format.DateUtils
import androidx.compose.foundation.layout.*
import androidx.compose.material3.Card
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.unit.dp
import com.lambdadigamma.medialibrary.composable.MediaImageView
import com.lambdadigamma.news.presentation.PostDisplayable

@Composable
fun DefaultPostCard(post: PostDisplayable, modifier: Modifier = Modifier, onClick: () -> Unit) {

    val typography = MaterialTheme.typography

    Card(onClick) {

        post.mediaCollections.getFirstMedia("default")?.let { media ->
            MediaImageView(
                media = media,
                alignment = Alignment.TopCenter,
                contentScale = ContentScale.FillWidth,
                modifier = Modifier
                    .fillMaxWidth()
                    .clip(MaterialTheme.shapes.medium)
            )
        }

        Column(
            modifier = modifier
                .fillMaxWidth()
                .padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(8.dp)
        ) {

            Text(
                text = post.title,
                style = typography.bodyLarge,
                maxLines = 2
            )

            Text(
                text = post.summary,
                style = typography.bodySmall,
                maxLines = 3
            )

            post.publishedAt?.let {
                val text = DateUtils.formatDateTime(
                    LocalContext.current,
                    it.time,
                    DateUtils.FORMAT_SHOW_TIME or DateUtils.FORMAT_SHOW_DATE
                )

                Text(
                    text = text,
                    style = typography.bodyMedium
                )

            }

        }

    }

}
