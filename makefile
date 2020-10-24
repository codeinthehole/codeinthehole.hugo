run:
	@echo "Running local Hugo server"
	hugo server --buildDrafts --watch

deploy:
	./deploy.sh
