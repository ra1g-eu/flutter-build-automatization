#!/bin/bash

# Tailored to a specific app
# Select a flavor, version, and version number for each app you want to build.
# Built files are then copied to ./build_output
# If building a live version, the binaries are zipped and copied to ./build_output
# !!!!!!! Not tested on MacOS !!!!!!! 

# Define the output directory
output_dir="./build_output"

# Create the output directory if it doesn't exist
mkdir -p $output_dir

# Read user input for flavor and version
echo "Available flavors:"
for flavor_dir in config/*; do
    flavor=$(basename "$flavor_dir")
    echo "- $flavor"
done
read -p "Enter the flavor to build: " selected_flavor

echo "Available versions: (qa, uat, live)"
read -p "Enter the version to build: " selected_version

echo "App build version number: (2.15.0, 2.20.1...)"
read -p "Enter the version number: " ver

# Copy pubspec.yaml.dist to root folder
cp "config/$selected_flavor/pubspec.yaml.dist" "../pubspec.yaml"

# Run flutter clean and flutter pub get
flutter clean
flutter pub get

# lowercase to uppercase flavor
selected_flavor_uppercase=$(echo $selected_flavor | tr '[:lower:]' '[:upper:]')

# Build the selected version for the selected flavor
if [ $selected_version == "qa" ]; then
    echo "==== Building QA version for flavor: $selected_flavor"
    flutter build apk --flavor $selected_flavor --obfuscate --split-debug-info -t lib/$selected_flavor/main_qa.dart
    echo "==== Done building QA version."
    cp "build/app/outputs/flutter-apk/app-$selected_flavor-release.apk" "$output_dir/$selected_flavor_uppercase-QA-$ver.apk"
    echo "==== Copied and renamed built APK file to ./build_output/!"
        if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
            msg "*" "Copied and renamed built APK file to ./build_output/!"
        else
            osascript -e 'display notification "Copied and renamed built APK file to ./build_output/!" with title "Build Process"'
        fi
elif [ $selected_version == "uat" ]; then
    echo "==== Building UAT version for flavor: $selected_flavor"
    flutter build apk --flavor $selected_flavor --obfuscate --split-debug-info -t lib/$selected_flavor/main_uat.dart
    echo "==== Done building UAT version."
    cp "build/app/outputs/flutter-apk/app-$selected_flavor-release.apk" "$output_dir/$selected_flavor_uppercase-UAT-$ver.apk"
    echo "==== Copied and renamed built APK file to ./build_output/!"
        if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
            msg "*" "Copied and renamed built APK file to ./build_output/!"
        else
            osascript -e 'display notification "Copied and renamed built APK file to ./build_output/!" with title "Build Process"'
        fi
elif [ $selected_version == "live" ]; then
    echo "==== Building Live version (AppBundle) for flavor: $selected_flavor"
    flutter build appbundle --flavor $selected_flavor --obfuscate --split-debug-info -t lib/$selected_flavor/main_live.dart
    echo "==== Done building LIVE version."
    cp "build/app/outputs/bundle/${selected_flavor}Release/app-$selected_flavor-release.aab" "$output_dir/$selected_flavor_uppercase-LIVE-$ver.aab"
    # Zip the binaries
    cd "build/app/intermediates/merged_native_libs/${selected_flavor}Release/out/lib"
    echo "==== Zipping libraries for LIVE version."
    current_date=$(date +%d-%m-%Y)
    tar -caf "binaries_build_$current_date.zip" *
    mv "binaries_build_$current_date.zip" "../../../../../../../$output_dir"
    echo "==== Copied & renamed built AAB file, zipped binaries and moved them to ./build_output/!"
        if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
            msg "*" "Copied and renamed built AAB file, zipped binaries and moved them to ./build_output/!"
        else
            osascript -e 'display notification "Copied and renamed built AAB file, zipped binaries and moved them to ./build_output/!" with title "Build Process"'
        fi
else
    echo "==== Invalid version selected!"
    exit 1
fi
