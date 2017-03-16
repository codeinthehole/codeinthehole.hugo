run:
	hugo server --buildDrafts --watch

css:
	lessc static/less/styles.less > static/css/styles.css

tree:
	-rm -rf public
	tree

deploy:
	./deploy.sh
	git push
