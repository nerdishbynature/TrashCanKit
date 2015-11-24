install:
	brew install carthage
	carthage bootstrap

test:
	set -o pipefail && xcodebuild clean test -scheme TrashCanKit -sdk iphonesimulator -destination name="iPhone 6" | xcpretty -c
