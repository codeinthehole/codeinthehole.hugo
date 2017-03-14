run:
	hugo server --buildDrafts --watch

site:
	hugo

css:
	lessc static/less/styles.less > static/css/styles.css

tree:
	-rm -rf public
	tree
