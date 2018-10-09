MAIN_FILE = src/App.elm
OUTPUT_FILE = index.html

production:
	elm make --optimize $(MAIN_FILE) --output=$(OUTPUT_FILE)
