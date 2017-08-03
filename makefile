run:
	hugo server --buildDrafts --watch

css:
	lessc static/less/styles.less > static/css/styles.css

deploy:
	./deploy.sh
