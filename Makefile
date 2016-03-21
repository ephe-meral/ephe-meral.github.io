build:
	hugo

server:
	hugo server -w

deploy: build
	cd public; \
	git add -A; \
	date | git commit -F-; \
	git push

clean:
	cd public; \
	rm -rf ./*
