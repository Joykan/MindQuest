#!/bin/bash
# Vercel build script for Flutter Web
set -e

echo "Generating secrets.dart..."
mkdir -p lib/core/constants
cat <<EOF > lib/core/constants/secrets.dart
class Secrets {
  static const supabaseUrl = '${SUPABASE_URL}';
  static const supabaseAnonKey = '${SUPABASE_ANON_KEY}';
  static const geminiApiKey = '${GEMINI_API_KEY}';
}
EOF

if [ ! -d "flutter" ]; then
  echo "Cloning Flutter stable..."
  git clone --depth 1 https://github.com/flutter/flutter.git -b stable
fi

echo "Building Flutter Web..."
./flutter/bin/flutter build web --release

echo "Preparing Vercel default output directory..."
mkdir -p public
cp -R build/web/* public/
