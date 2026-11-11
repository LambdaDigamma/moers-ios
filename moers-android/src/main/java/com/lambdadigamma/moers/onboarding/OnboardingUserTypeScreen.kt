package com.lambdadigamma.moers.onboarding

import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.selection.selectable
import androidx.compose.foundation.selection.selectableGroup
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.CheckCircle
import androidx.compose.material3.Button
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.Icon
import androidx.compose.material3.ListItem
import androidx.compose.material3.ListItemDefaults
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedCard
import androidx.compose.material3.RadioButton
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.runtime.collectAsState
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.alpha
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.semantics.Role
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.lambdadigamma.core.theme.MeinMoersTheme
import com.lambdadigamma.core.user.UserRepository
import com.lambdadigamma.core.user.UserType
import com.lambdadigamma.moers.R
import com.lambdadigamma.moers.onboarding.ui.OnboardingHost

// Maybe later this could be become the hometown selection?
@Composable
fun OnboardingUserTypeScreen(viewModel: OnboardingUserTypeViewModel, onContinue: () -> Unit) {

    val selectedUserType by viewModel.userType.collectAsState(initial = UserRepository.defaultUserType)

    LaunchedEffect(Unit) {
        viewModel.updateUserType(UserRepository.defaultUserType)
    }

    OnboardingUserTypeContent(
        selectedUserType = selectedUserType,
        onUpdateUserType = viewModel::updateUserType,
        onContinue = onContinue
    )
}

@Composable
fun OnboardingUserTypeContent(
    selectedUserType: UserType,
    onUpdateUserType: (UserType) -> Unit,
    onContinue: () -> Unit
) {
    OnboardingHost(
        content = {
            Text(
                modifier = Modifier.padding(16.dp),
                text = stringResource(R.string.onboarding_user_type_info),
                style = MaterialTheme.typography.bodyLarge
            )

            Column(Modifier.selectableGroup()) {
                UserTypeOption(
                    label = stringResource(R.string.onboarding_user_type_citizen),
                    selected = selectedUserType == UserType.CITIZEN,
                    onSelect = { onUpdateUserType(UserType.CITIZEN) },
                )
                UserTypeOption(
                    label = stringResource(R.string.onboarding_user_type_visitor),
                    selected = selectedUserType == UserType.VISITOR,
                    onSelect = { onUpdateUserType(UserType.VISITOR) },
                )
            }

            Text(
                text = stringResource(R.string.onboarding_user_type_activated_features),
                modifier = Modifier.padding(start = 16.dp, end = 16.dp, top = 24.dp, bottom = 8.dp),
                style = MaterialTheme.typography.titleSmall,
                color = MaterialTheme.colorScheme.primary,
            )

            OutlinedCard(modifier = Modifier.padding(horizontal = 16.dp)) {
                FeatureRow(
                    title = stringResource(R.string.feature_fuel_title),
                    text = stringResource(R.string.feature_fuel_text),
                    checked = true
                )
                HorizontalDivider()
                FeatureRow(
                    title = stringResource(R.string.feature_parking_title),
                    text = stringResource(R.string.feature_parking_text),
                    checked = true
                )
                HorizontalDivider()
                FeatureRow(
                    title = stringResource(R.string.feature_waste_schedule_title),
                    text = stringResource(R.string.feature_waste_schedule_text),
                    checked = selectedUserType == UserType.CITIZEN
                )
                HorizontalDivider()
                FeatureRow(
                    title = stringResource(R.string.feature_transit_title),
                    text = stringResource(R.string.feature_transit_text),
                    checked = true
                )
            }

            Text(
                stringResource(R.string.onboarding_user_type_features_footer),
                style = MaterialTheme.typography.bodySmall,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
                modifier = Modifier.padding(16.dp)
            )
        }
    ) {
        Button(onClick = onContinue, modifier = Modifier.fillMaxWidth()) {
            Text(text = stringResource(R.string.onboarding_user_type_cta))
        }
    }
}

@Composable
private fun UserTypeOption(label: String, selected: Boolean, onSelect: () -> Unit) {
    ListItem(
        headlineContent = { Text(label) },
        leadingContent = { RadioButton(selected = selected, onClick = null) },
        modifier = Modifier.selectable(selected = selected, onClick = onSelect, role = Role.RadioButton),
    )
}

@Composable
fun FeatureRow(title: String, text: String, checked: Boolean = false, standalone: Boolean = false) {
    ListItem(
        headlineContent = { Text(title) },
        supportingContent = { Text(text) },
        trailingContent = {
            if (checked && !standalone) {
                Icon(
                    Icons.Filled.CheckCircle,
                    contentDescription = null,
                    tint = MaterialTheme.colorScheme.primary,
                )
            }
        },
        colors = ListItemDefaults.colors(containerColor = MaterialTheme.colorScheme.surface),
        modifier = Modifier.alpha(if (standalone || checked) 1f else 0.38f),
    )
}

@Preview
@Composable
private fun OnboardingUserTypePreview() {
    MeinMoersTheme {
        var userType by remember { mutableStateOf(UserType.CITIZEN) }
        OnboardingUserTypeContent(
            selectedUserType = userType,
            onContinue = {},
            onUpdateUserType = { userType = it }
        )
    }
}
