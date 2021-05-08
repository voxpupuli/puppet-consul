# Make target for TravisCI to run beaker tests in docker
beaker:
	bundle config
	rm .bundle/config
	bundle config
	bundle install
	curl -sLo - http://j.mp/install-travis-docker | UML_DOCKERCOMPOSE=0 UML_FIG=0 sh -e
	./run 'bundle exec rake beaker'

release:
	@echo "Run: github_changelog_generator --future-release $$(bundle exec rake module:version:next) --user solarkennedy --project puppet-consul"
	@echo "Update the version number in the module’s metadata.json file and commit the change to the module repository."
	@echo "Tag the module repo with the desired version number. For more information about how to do this, see Git docs on basic tagging."
	@echo "Push the commit and tag to your Git repository."
	@echo "Travis CI will build and publish the module."
	@echo "Docs: https://puppet.com/docs/puppet/5.4/modules_publishing.html#publish-to-the-forge-automatically-with-travis-ci"
