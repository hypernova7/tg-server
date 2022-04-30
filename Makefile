.PHONY: update
update:
	git submodule -q update --init --recursive

.PHONY: publish
publish:
	heroku container:push web -a $(appname)
	heroku container:release web -a $(appname)

.PHONY: release
release: update publish