
post = default.zh.md
message = git commit
Year_month = $(shell date +"%Y/%m")


new:
	hugo new posts/$(Year_month)/$(post)

pre:
	hugo server -D

commit:
	git add -A
	git commit -m message
pub:
	git pull
	git push