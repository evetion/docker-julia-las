FROM julia:0.5.2
MAINTAINER 'Maarten Pronk' <docker@evetion.nl>

# Install required development packages
RUN apt-get update && apt-get install -y \
    libtiff-dev libgeotiff-dev libgdal-dev libboost-system-dev libboost-thread-dev libboost-serialization-dev \
    libboost-filesystem-dev libboost-program-options-dev libboost-regex-dev libboost-iostreams-dev \
    git cmake build-essential wget automake autoconf autogen apt-utils libtool \
    gdal-bin libgdal-dev && rm -rf /var/lib/apt/lists/*

# Compile laszip & liblas
WORKDIR /opt
RUN git clone https://github.com/LASzip/LASzip.git \
    && cd LASzip && git checkout tags/v2.2.0 && ./autogen.sh && ./configure --includedir=/usr/local/include/laszip \
    && make -j$(nproc) && make install && ldconfig
WORKDIR /opt
RUN git clone git://github.com/libLAS/libLAS.git \
    && cd libLAS && git checkout tags/1.8.1 && mkdir /opt/libLAS/makedir && cd /opt/libLAS/makedir \
    && cmake -DWITH_LASZIP=TRUE -G "Unix Makefiles" ../ && make -j$(nproc) && make install && ldconfig

# Remove development packages
RUN apt-get purge -y \
    libtiff-dev libgeotiff-dev libgdal-dev libboost-system-dev libboost-thread-dev libboost-serialization-dev \
    libboost-filesystem-dev libboost-program-options-dev libboost-regex-dev libboost-iostreams-dev \
    git cmake build-essential wget automake autoconf autogen apt-utils libtool \
    libgdal-dev

# Install required Julia packages
COPY docker_install.jl install.jl
RUN julia install.jl

# Run Julia
ENTRYPOINT ["julia"]
CMD ["--help"]
