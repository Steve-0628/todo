.PHONY: all clean

all: index.js new.js html css

index.js: src/Index.elm src/Common.elm
	elm make src/Index.elm --output=dist/index.js

new.js: src/New.elm src/Common.elm
	elm make src/New.elm --output=dist/new.js

html: index.html new.html
	cp index.html new.html dist/

css: style.css
	cp style.css dist/

clean:
	rm -rf dist
