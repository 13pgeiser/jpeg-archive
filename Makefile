CC = gcc
CFLAGS += -std=c99 -Wall -O3
LDFLAGS += -lm

UNAME_S := $(shell uname -s)
UNAME_P := $(shell uname -p)

ifeq ($(UNAME_S),Linux)
	# Linux (e.g. Ubuntu)
	ifeq ($(UNAME_P),x86_64)
		LIBJPEG = /usr/lib/x86_64-linux-gnu/libjpeg.a
	else
		LIBJPEG = /usr/lib/i386-linux-gnu/libjpeg.a
	endif
else
	ifeq ($(UNAME_S),Darwin)
		# Mac OS X
		LIBJPEG = /usr/local/opt/jpeg-turbo/lib/libjpeg.a
	else
		# Windows
		LIBJPEG = libjpeg.a
	endif
endif

LIBIQA=src/iqa/build/release/libiqa.a

all: jpeg-recompress jpeg-compare jpeg-hash

$(LIBIQA):
	cd src/iqa; RELEASE=1 make

jpeg-recompress: jpeg-recompress.c src/util.o src/edit.o src/commander.o $(LIBIQA)
	$(CC) $(CFLAGS) -o $@ $^ $(LIBJPEG) $(LDFLAGS)

jpeg-compare: jpeg-compare.c src/util.o src/hash.o src/commander.o $(LIBIQA)
	$(CC) $(CFLAGS) -o $@ $^ $(LIBJPEG) $(LDFLAGS)

jpeg-hash: jpeg-hash.c src/util.o src/hash.o src/commander.o
	$(CC) $(CFLAGS) -o $@ $^ $(LIBJPEG) $(LDFLAGS)

%.o: %.c %.h
	$(CC) $(CFLAGS) -c -o $@ $<

install:
	cp jpeg-recompress /usr/local/bin/
	cp jpeg-compare /usr/local/bin/
	cp jpeg-hash /usr/local/bin/

clean:
	rm -rf jpeg-recompress jpeg-compare jpeg-hash src/*.o src/iqa/build
