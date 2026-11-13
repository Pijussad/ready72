.PHONY: start test test-golden web analyze clean

start:
	flutter pub get
	flutter run

test:
	flutter test --exclude-tags golden

test-golden:
	flutter test --tags golden

analyze:
	flutter analyze

web:
	flutter build web --release --pwa-strategy=none --no-web-resources-cdn

clean:
	flutter clean
