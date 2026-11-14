.PHONY: start test test-golden web analyze catalogue clean

start:
	flutter pub get
	flutter run

test:
	flutter test --exclude-tags golden

test-golden:
	flutter test --tags golden

analyze:
	flutter analyze

catalogue:
	python3 tool/scrape/barbora.py
	python3 tool/scrape/decathlon.py
	python3 tool/scrape/eurovaistine.py
	python3 tool/build_catalogue.py

web:
	flutter build web --release --pwa-strategy=none --no-web-resources-cdn

clean:
	flutter clean
