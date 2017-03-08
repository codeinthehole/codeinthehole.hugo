run:
	hugo server --buildDrafts --watch

build:
	hugo

migrate:
	./convert_all.sh
