# dump flutter internals
echo 'const Map<String,String> flutterInternals = ' > lib/flutter_internals.dart
flutter --version --machine >> lib/flutter_internals.dart
echo ';' >> lib/flutter_internals.dart
sed -i '' 's/\x22/\x27/g' lib/flutter_internals.dart

