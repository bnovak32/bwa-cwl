FROM bnovak32/alpine-samtools:1.18

RUN apk add --update git make gcc musl-dev \
 && git clone https://github.com/lh3/bwa.git \
 && cd bwa && make clean all && cp bwa /usr/local/bin \
 && apk del gcc musl-dev git make \
 && cd / && rm -r bwa

