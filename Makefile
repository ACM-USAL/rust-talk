.PHONY: all
all: slides.html

.PHONY: clean
clean:
	rm slides.html

%.html: %.md
	pandoc -s --from markdown --to revealjs $< -o $@ -A extra.html
