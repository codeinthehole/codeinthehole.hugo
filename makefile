run:
	@echo "Running local Hugo server"
	hugo server --buildDrafts --watch

css:
	@echo "Building CSS"
	lessc static/less/styles.less > static/css/styles.css

deploy:
	./deploy.sh
