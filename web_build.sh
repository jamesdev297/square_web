flutter build web --release --base-href='/square_build/' --web-renderer html --dart-define=ZONE=local
cp -r build/web/* ../square_build