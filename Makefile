.PHONY: update
update:
	git submodule foreach git pull origin master

.PHONY: publish
publish:
	heroku container:push web -a $(appname)
	heroku container:release web -a $(appname)

.PHONY: release
release: update publish