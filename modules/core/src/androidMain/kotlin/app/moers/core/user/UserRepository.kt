package app.moers.core.user

import android.content.Context
import androidx.datastore.preferences.core.edit
import androidx.datastore.preferences.core.stringPreferencesKey
import com.lambdadigamma.core.utils.dataStore
import dagger.hilt.android.qualifiers.ApplicationContext
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map
import javax.inject.Inject

const val USER_TYPE_KEY = "user.user_type"

class UserRepository @Inject constructor(
    @ApplicationContext val context: Context
) {

    private val dataStore = context.dataStore

    val userType: Flow<UserType> = dataStore.data
        .map { settings ->
            settings[userTypeKey]?.let {
                try {
                    UserType.fromString(it)
                } catch (e: Exception) {
                    defaultUserType
                }
            } ?: defaultUserType
        }

    suspend fun updateUserType(userType: UserType) {
        dataStore.edit {
            it[userTypeKey] = userType.value
        }
    }

    companion object {
        val userTypeKey = stringPreferencesKey(USER_TYPE_KEY)
        val defaultUserType = UserType.CITIZEN
    }

}