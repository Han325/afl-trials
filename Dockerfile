FROM ubuntu:22.04

ENV FUZZING_ENGINE=fsanitize_fuzzer
ENV AFL_LLVM_CMPLOG=1

RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y git \
    subversion \
    clang-15 \
    llvm-15-dev \
    lld-15 \
    libtool \
    wget \
    parallel \
    gawk \
    ragel \
    libglib2.0-dev \
    libarchive-dev \
    libxml2-dev \
    libssl-dev \
    autoconf-archive \
    libdbus-1-dev \
    libbz2-dev \
    liblzma-dev \
    libgcrypt-dev \
    gnuplot \
    imagemagick \
    cmake \
    build-essential
WORKDIR /app/

RUN git clone https://github.com/AFLplusplus/AFLplusplus.git && \
    cd AFLplusplus && \
    git checkout v4.30c && \
    LLVM_CONFIG=/usr/bin/llvm-config-15 make && \
    LLVM_CONFIG=/usr/bin/llvm-config-15 make install && \
    cp /app/AFLplusplus/afl-llvm-rt-lto.o /usr/local/bin/
WORKDIR /app/
RUN git clone https://github.com/google/fuzzer-test-suite.git && \
    cd fuzzer-test-suite && \
    git checkout 6955fc97
RUN mkdir build && \
    cd build && \
    echo '#!/usr/bin/bash' > build_program.sh && \
    echo '' >> build_program.sh && \
    echo 'SUT=vorbis-2017-12-11' >> build_program.sh && \
    echo 'mkdir -p $SUT' >> build_program.sh && \
    echo 'pushd $SUT' >> build_program.sh && \
    echo 'CC=afl-clang-lto CXX=afl-clang-lto++ /app/fuzzer-test-suite/$SUT/build.sh |& tee build.log' >> build_program.sh && \
    echo 'popd' >> build_program.sh && \
    chmod 755 build_program.sh
CMD ["/bin/bash"]