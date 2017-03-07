run:
	hugo server --theme=hugo-zen --buildDrafts --watch

migrate:
	./convert_all.sh
