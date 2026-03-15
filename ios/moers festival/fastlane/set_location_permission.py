import subprocess
import json

bundle_id = input("Enter bundle identifier: ")

# Run the xcrun command and parse its JSON output
xcrun_output = subprocess.check_output(['xcrun', 'simctl', 'list', 'devices', '--json', 'iOS'])
simulator_json = json.loads(xcrun_output)

# print(simulator_json['devices'])

# {'com.apple.CoreSimulator.SimRuntime.watchOS-9-4': [], 'com.apple.CoreSimulator.SimRuntime.iOS-16-4': [{'lastBootedAt': '2023-05-02T20:30:09Z', 'dataPath': '/Users/lennart/Library/Developer/CoreSimulator/Devices/66AD133F-B765-40AD-BDA0-B5A7704ECC20/data', 'dataPathSize': 461934592, 'logPath': '/Users/lennart/Library/Logs/CoreSimulator/66AD133F-B765-40AD-BDA0-B5A7704ECC20', 'udid': '66AD133F-B765-40AD-BDA0-B5A7704ECC20', 'isAvailable': True, 'logPathSize': 122880, 'deviceTypeIdentifier': 'com.apple.CoreSimulator.SimDeviceType.iPhone-8', 'state': 'Booted', 'name': 'iPhone 8'

# Filter all iOS devices in an array (but do not hardcode the iOS version)
# com.apple.CoreSimulator.SimRuntime.iOS
devices = [device for runtime, devices in simulator_json['devices'].items() if runtime.startswith('com.apple.CoreSimulator.SimRuntime.iOS') for device in devices]

for device in devices:
    if device['state'] != 'Booted':
        print("Booting device " + device['name'] + "...")
        subprocess.call(['xcrun', 'simctl', 'boot', device['udid']])
        # wait some time for the device to boot
        subprocess.call(['sleep', '10'])

    else:
        print("Device " + device['name'] + " is already booted.")

    # Run xcrun simctl privacy booted grant location-always <bundle_id> on all devices
    subprocess.call(['xcrun', 'simctl', 'privacy', device['udid'], 'grant', 'location-always', bundle_id])
    print("Granted location permission to " + bundle_id + " on " + device['name'])

    # Add the root certificate to the keychain
    subprocess.call(['xcrun', 'simctl', 'keychain', device['udid'], "add-root-cert", "~/.config/valet/CA/LaravelValetCASelfSigned.pem"])
    print("Added root certificate to keychain on " + device['name'])

    # Shutdown all booted devices
    subprocess.call(['xcrun', 'simctl', 'shutdown', device['udid']])
    print("Shut down " + device['name'])

# Print the UDIDs of non-booted devices
print("Finished!")