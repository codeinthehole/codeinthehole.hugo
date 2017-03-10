run:
	hugo server --buildDrafts --watch

site:
	hugo

css:
	lessc themes/dmw/static/less/styles.less > themes/dmw/static/css/styles.css

tree:
	-rm -rf public
	tree
