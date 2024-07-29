FROM osgeo/grass-gis:releasebranch_8_3-debian as grass

RUN [[ -d /usr/local/grass83/raster ]] || mkdir /usr/local/grass83/raster && \
    cd /usr/local/grass83/raster && \
    git clone --branch=1.2.0 https://github.com/qjhart/r.iheliosat.git && \
    cd r.iheliosat && make

#RUN mkdir /usr/local/grass83/general && cd /usr/local/grass83/general && \
#    git clone --branch=master https://github.com/CSTARS/spatial-cimis.git

WORKDIR /grassdb

#RUN rm -rf /usr/local/grass83/raster
