# Make target for TravisCI to run beaker tests in docker
beaker:
	bundle config
	rm .bundle/config
	bundle config
	bundle install
	curl -sLo - http://j.mp/install-travis-docker | UML_DOCKERCOMPOSE=0 UML_FIG=0 sh -e
	./run 'bundle exec rake beaker'

minor_release:
	github_changelog_generator --future-release $$(bundle exec rake module:version:next)
	bundle exec rake module:release
