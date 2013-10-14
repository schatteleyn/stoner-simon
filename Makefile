all: build

build: site
	./site build

site: site.hs
	ghc --make site.hs
	./site clean

new:
	@./new_post.sh

publish: build
	git add .
	git stash save
	git checkout gh-pages || git checkout --orphan gh-pages
	find . -maxdepth 1 ! -name '.' ! -name '.git*' ! -name '_site' -exec rm -rf {} +
	find _site -maxdepth 1 -exec mv {} . \;
	rmdir _site
	git add -A && git commit -m "Publish" || true
	git push -f origin gh-pages
	git checkout master
	git clean -fdx
	git stash pop || true
	git commit -m "Publish"
	git push 

preview: site
	./site preview

clean: site
	./site clean
