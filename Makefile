install:
	brew install carthage
	carthage bootstrap

test:
	set -o pipefail && xcodebuild clean test -scheme TrashCanKit -sdk iphonesimulator9.0 | xcpretty -c -r junit --output $(CIRCLE_TEST_REPORTS)/xcode/results.xml
