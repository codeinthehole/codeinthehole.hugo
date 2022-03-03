run:
	@echo "Running local Hugo server"
	hugo server --buildDrafts --watch

deploy:
	./deploy.sh

lint: markdownlint prettier

markdownlint:
	markdownlint .

prettier:
	prettier --check content/ README.md
