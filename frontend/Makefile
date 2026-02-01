.PHONY: all clean watch

all: dist/index.html dist/edit/index.html dist/detail/index.html dist/new/index.html dist/tag/index.html dist/tag/edit/index.html dist/style.css dist/js/common.js dist/js/index.js dist/js/edit.js dist/js/detail.js dist/js/new.js dist/js/tag.js dist/js/tag_edit.js

dist/style.css: style.css
	mkdir -p dist
	cp style.css dist/

dist/js/%.js: js/%.js
	mkdir -p dist/js
	cp $< $@

dist/index.html: index.html
	mkdir -p dist
	cp index.html dist/

dist/%/index.html: %/index.html
	mkdir -p dist/$*
	cp $< $@

clean:
	rm -rf dist

watch:
	while true; do \
		$(MAKE) all; \
		inotifywait -qre close_write . --exclude dist; \
	done
