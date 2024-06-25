echo "Flutter iOS Fix"
echo "Cleaning Flutter dependencies"
flutter clean
echo "Removing iOS Pods"
rm -rf ios/Pods
echo "Removing iOS Podfile.lock"
rm ios/Podfile.lock
echo "Removing iOS Podfile"
# pod deintegrate
#echo "Removing Flutter Pods"
# pod cache clean
#echo "Installing Flutter dependencies"
# pod setup
echo "Installing Flutter dependencies and podfile"
flutter pub get
cd ios/
pod install
cd ..