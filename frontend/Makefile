.PHONY: all clean watch

all: index.js new.js newtag.js detail.js edit.js html css

index.js: src/Index.elm src/Common.elm
	elm make src/Index.elm --output=dist/index.js

new.js: src/New.elm src/Common.elm
	elm make src/New.elm --output=dist/new/index.js

newtag.js: src/NewTag.elm src/Common.elm
	elm make src/NewTag.elm --output=dist/tag/index.js

detail.js: src/Detail.elm src/Common.elm
	elm make src/Detail.elm --output=dist/detail/index.js

edit.js: src/Edit.elm src/Common.elm
	elm make src/Edit.elm --output=dist/edit/index.js

html: index.html
	mkdir -p dist/new
	mkdir -p dist/tag
	mkdir -p dist/detail
	mkdir -p dist/edit
	cp index.html dist/
	cp index.html dist/new/
	cp index.html dist/tag/
	cp index.html dist/detail/
	cp index.html dist/edit/

css: style.css
	cp style.css dist/

clean:
	rm -rf dist

watch:
	while true; do \
		$(MAKE) all; \
		inotifywait -qre close_write src/ *.css *.html; \
	done
