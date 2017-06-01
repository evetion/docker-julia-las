FROM julia:0.5.2
MAINTAINER 'Maarten Pronk' <docker@evetion.nl>

# Install required development packages
RUN apt-get update && apt-get install libtiff-dev libgeotiff-dev libgdal-dev \
libboost-system-dev libboost-thread-dev libboost-filesystem-dev libboost-program-options-dev libboost-regex-dev libboost-iostreams-dev \
git cmake build-essential wget \
gdal-bin libgeos-dev libgdal-dev libboost-serialization-dev automake autoconf autogen apt-utils libtool -y --no-install-recommends ca-certificates

# Compile laszip & liblas
RUN cd /opt && git clone https://github.com/LASzip/LASzip.git && cd LASzip && git checkout tags/v2.2.0 && ./autogen.sh && ./configure --includedir=/usr/local/include/laszip && make -j$(nproc) && make install && ldconfig
RUN cd /opt && git clone git://github.com/libLAS/libLAS.git && cd libLAS && git checkout tags/1.8.1 && mkdir /opt/libLAS/makedir && cd /opt/libLAS/makedir && cmake -DWITH_LASZIP=TRUE -G "Unix Makefiles" ../ && make -j$(nproc) && make install && ldconfig

# Remove development packages
RUN apt-get purge libtiff-dev libgeotiff-dev libgdal-dev \
libboost-system-dev libboost-thread-dev libboost-filesystem-dev libboost-program-options-dev libboost-regex-dev libboost-iostreams-dev \
cmake build-essential \
gdal-bin libgeos-dev libgdal-dev libboost-serialization-dev automake autoconf autogen libtool -y

# Install required Julia packages
ADD docker_install.jl install.jl
RUN julia install.jl
