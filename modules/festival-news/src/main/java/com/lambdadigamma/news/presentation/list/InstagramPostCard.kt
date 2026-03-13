package com.lambdadigamma.news.presentation.list

import android.text.format.DateUtils
import androidx.compose.foundation.Image
import androidx.compose.foundation.layout.*
import androidx.compose.material3.Card
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.ColorFilter
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.lambdadigamma.core.ui.ThemedPreview
import com.lambdadigamma.medialibrary.MediaCollectionsContainer
import com.lambdadigamma.medialibrary.composable.MediaImageView
import com.lambdadigamma.news.R
import com.lambdadigamma.news.presentation.PostDisplayable
import com.lambdadigamma.news.presentation.PostType
import java.util.Date

@Composable
fun InstagramPostCard(post: PostDisplayable, modifier: Modifier = Modifier, onClick: () -> Unit) {

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
            verticalArrangement = Arrangement.spacedBy(4.dp)
        ) {

            Text(
                text = post.title,
                style = typography.bodyLarge,
                maxLines = 3
            )

            Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                Image(
                    painter = painterResource(id = R.drawable.icons8_instagram),
                    contentDescription = "Instagram",
                    modifier = Modifier.size(24.dp),
                    colorFilter = ColorFilter.tint(MaterialTheme.colorScheme.onBackground)
                )

                post.publishedAt?.let {
                    val text = DateUtils.formatDateTime(
                        LocalContext.current,
                        it.time,
                        DateUtils.FORMAT_SHOW_TIME or DateUtils.FORMAT_SHOW_DATE or DateUtils.FORMAT_ABBREV_RELATIVE
                    )

                    Text(
                        text = text,
                        style = typography.bodyMedium
                    )

                }

            }


        }

    }

}

@Preview
@Composable
private fun InstagramCardPreview() {
    ThemedPreview {
        InstagramPostCard(
            post = PostDisplayable(
                id = 1,
                title = "Saturday, May 18th, witness \"HYPERPLEXIA - remapping the piano\" (CH) on stage of enni.eventhalle at 1:15 p.m.\n" + "\n" + "Line-Up: Stefan Schultze (p, player piano)\n",
                summary = "Das ist ein Test für den Post.",
                publishedAt = Date(),
                mediaCollections = MediaCollectionsContainer(),
                type = PostType.DEFAULT,
                externalHref = null,
                pageId = 1
            ),
            onClick = {}
        )
    }
}