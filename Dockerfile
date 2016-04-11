# Dockerfile for Hyperledger
FROM golang:1.6
MAINTAINER Baohua Yang

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update \
        && apt-get install -y libsnappy-dev zlib1g-dev libbz2-dev \
        && rm -rf /var/cache/apt

RUN cd /tmp \
 && git clone --single-branch -b v4.1 --depth 1 https://github.com/facebook/rocksdb.git \
 && cd rocksdb \
 && PORTABLE=1 make shared_lib \
 && INSTALL_PATH=/usr make install-shared

RUN mkdir -p $GOPATH/src/github.com/hyperledger \
        && cd $GOPATH/src/github.com/hyperledger \
        && git clone --single-branch -b master --depth 1 https://github.com/hyperledger/fabric.git \
        && cd $GOPATH/src/github.com/hyperledger/fabric \
        && CGO_CFLAGS=" " CGO_LDFLAGS="-lrocksdb -lstdc++ -lm -lz -lbz2 -lsnappy" go build -o peer

RUN mkdir -p /var/hyperledger/db
RUN cp $GOPATH/src/github.com/hyperledger/fabric/core.yaml $GOPATH/bin

WORKDIR "$GOPATH/src/github.com/hyperledger/fabric"

ENTRYPOINT ["./peer"]