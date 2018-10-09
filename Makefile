MAIN_FILE = src/App.elm
OUTPUT_FILE = elm.js

production:
	elm make --optimize $(MAIN_FILE) --output=$(OUTPUT_FILE)
