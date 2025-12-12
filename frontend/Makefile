.PHONY: all clean watch

all: index.js new.js newtag.js html css

index.js: src/Index.elm src/Common.elm
	elm make src/Index.elm --output=dist/index.js

new.js: src/New.elm src/Common.elm
	elm make src/New.elm --output=dist/new/index.js

newtag.js: src/NewTag.elm src/Common.elm
	elm make src/NewTag.elm --output=dist/tag/index.js

html: index.html new.html
	mkdir -p dist/new
	mkdir -p dist/tag
	cp index.html dist/
	cp index.html dist/new/
	cp index.html dist/tag/

css: style.css
	cp style.css dist/

clean:
	rm -rf dist

watch:
	while true; do \
		$(MAKE) all; \
		inotifywait -qre close_write src/ *.css *.html; \
	done
