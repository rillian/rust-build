all: Dockerfile checkout-sources.sh build.sh node
	docker build -t rust-build .

SHASUM ?= shasum

NODE_VERSION ?= v4.2.2
node: node-$(NODE_VERSION)-linux-x64.tar.xz SHASUMS256.txt.asc
	$(RM) -r $@
	echo SHASUM is $(SHASUM)
	gpg --verify SHASUMS256.txt.asc
	keybase verify SHASUMS256.txt.asc
	fgrep $< SHASUMS256.txt.asc > $<.sha256
	$(SHASUM) -c $<.sha256
	tar xf $<
	ln -s $(basename $(basename $<)) $@

node-$(NODE_VERSION)-linux-x64.tar.xz SHASUMS256.txt.asc :
	curl -Os https://nodejs.org/dist/$(NODE_VERSION)/$@

clean:
	rm -rf node
