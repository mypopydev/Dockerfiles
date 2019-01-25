# Build DLDT-Inference Engine
ARG DLDT_VER=2018_R4
ARG DLDT_REPO=https://github.com/opencv/dldt.git
RUN git clone -b ${DLDT_VER} ${DLDT_REPO}; \
    cd dldt; \
    git submodule init; \
    git submodule update --recursive; \
    cd inference-engine; \
    mkdir build; \
    cd build; \
    cmake -DBUILD_SHARED_LIBS=ifelse(index(BUILD_LINKAGE,static),-1,ON,OFF) -DCMAKE_INSTALL_PREFIX=/usr -DLIB_INSTALL_PATH=/usr/ifelse(index(DOCKER_IMAGE,ubuntu),-1,lib64,lib/x86_64-linux-gnu) -DENABLE_MKL_DNN=ON -DENABLE_CLDNN=ifelse(index(DOCKER_IMAGE,xeon-),-1,ON,OFF) -DENABLE_SAMPLE_CORE=OFF  ..; \
    make -j16; \
    rm -rf ../bin/intel64/Release/lib/libgtest*; \
    rm -rf ../bin/intel64/Release/lib/libgmock*; \
    rm -rf ../bin/intel64/Release/lib/libmock*; \
    rm -rf ../bin/intel64/Release/lib/libtest*; \
    for p in /usr /home/build/usr; do \
        mkdir -p $p/include/dldt; \
        cp -r ../include/* $p/include/dldt; \
        libdir="$p/ifelse(index(DOCKER_IMAGE,ubuntu),-1,lib64,lib/x86_64-linux-gnu)"; \
        cp -r ../bin/intel64/Release/lib/* "$libdir"; \
        mkdir -p "$libdir/pkgconfig"; \
        pc="$libdir/pkgconfig/dldt.pc"; \
        echo "prefix=/usr" > "$pc"; \
        echo "libdir=/usr/ifelse(index(DOCKER_IMAGE,ubuntu),-1,lib64,lib/x86_64-linux-gnu)" >> "$pc"; \
        echo "includedir=/usr/include/dldt" >> "$pc"; \
        echo "" >> "$pc"; \
        echo "Name: DLDT" >> "$pc"; \
        echo "Description: Intel Deep Learning Deployment Toolkit" >> "$pc"; \
        echo "Version: 4.0" >> "$pc"; \
        echo "" >> "$pc"; \
        echo "Libs: -L\${libdir} -linference_engine" >> "$pc"; \
        echo "Cflags: -I\${includedir}" >> "$pc"; \
    done;
