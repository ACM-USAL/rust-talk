.PHONY: all
all: slides.html

%.html: %.md
	pandoc -s --from markdown --to revealjs $< -o $@
