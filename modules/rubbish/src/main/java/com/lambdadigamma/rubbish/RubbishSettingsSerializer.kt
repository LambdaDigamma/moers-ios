package com.lambdadigamma.rubbish

import android.content.Context
import androidx.datastore.core.CorruptionException
import androidx.datastore.core.DataStore
import androidx.datastore.core.Serializer
import androidx.datastore.dataStore
import androidx.datastore.preferences.protobuf.InvalidProtocolBufferException
import com.lambdadigamma.rubbish.settings.RubbishSettings
import java.io.InputStream
import java.io.OutputStream

object RubbishSettingsSerializer : Serializer<RubbishSettings> {

    override val defaultValue: RubbishSettings
        get() = RubbishSettings.getDefaultInstance()

    override suspend fun readFrom(input: InputStream): RubbishSettings {
        try {
            return RubbishSettings.parseFrom(input)
        } catch (e: InvalidProtocolBufferException) {
            throw CorruptionException("Cannot read proto.", e)
        }
    }

    override suspend fun writeTo(t: RubbishSettings, output: OutputStream) {
        t.writeTo(output)
    }

}

val Context.rubbishSettingsDataStore: DataStore<RubbishSettings> by dataStore(
    fileName = "rubbish_settings.pb",
    serializer = RubbishSettingsSerializer
)