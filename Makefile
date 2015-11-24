install:
	brew update
	brew install python
	brew install carthage
	pip install codecov
	carthage bootstrap

test:
	set -o pipefail && xcodebuild clean test -scheme TrashCanKit -sdk iphonesimulator -destination name="iPhone 6" ONLY_ACTIVE_ARCHS=YES -enableCodeCoverage YES | xcpretty -c

post_coverage:
	bundle exec slather coverage --input-format profdata -x --ignore "../**/*/Xcode*" --ignore "Carthage/**" --output-directory slather-report --scheme TrashCanKit TrashCanKit.xcodeproj
	codecov -f slather-report/cobertura.xml
