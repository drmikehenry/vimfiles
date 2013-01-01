SOURCES := $(wildcard *.snippets.py)
SNIPPETS := $(patsubst %.py,%, $(SOURCES))

.PHONY: all
all: $(SNIPPETS)

%.snippets: %.snippets.py
	./$< > $@
