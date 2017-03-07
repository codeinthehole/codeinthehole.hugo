run:
	hugo server --theme=hugo-zen --buildDrafts --watch

build:
	hugo --theme=hugo-zen

migrate:
	./convert_all.sh
