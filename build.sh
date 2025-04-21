#!/bin/bash

sudo mkdir build
sudo cd build
sudo cmake -DCMAKE_INSTALL_PREFIX:PATH=`pwd`/install -DTRITON_BUILD_ONNXRUNTIME_VERSION=1.19.2 -DTRITON_BUILD_CONTAINER_VERSION=24.09 -DTRITON_ENABLE_GPU=OFF -DTRITON_ENABLE_TENSORRT=OFF -DTRITON_ENABLE_METRICS_CPU=ON -DTRITON_ENABLE_ONNXRUNTIME_METRICS=ON -DTRITON_ENABLE_ONNXRUNTIME_TENSORRT=OFF -DTRITON_BUILD_TARGET_PLATFORM=linux -DCMAKE_SYSTEM_PROCESSOR=x86_64 ..

sudo make install

# Step 1: start a container with the tritonserver image
docker run --rm -it -v "$(pwd)":/tmp/model_repo -v /var/run/docker.sock:/var/run/docker.sock --platform=linux/amd64 --entrypoint /bin/bash --user root tritonserver_buildbase rockylinux:8

apt install rapidjson-dev
apt install cmake
apt install git
apt install -y libssl-dev libcurl4-openssl-dev apt-utils
apt install -y docker.io

# rockylinux
yum -y update
yum -y install epel-release
sudo dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo
sudo dnf install -y docker-ce docker-ce-cli containerd.io


# pip install flatbuffers

# test triton complied result
docker run --rm -it -v "$(pwd)":/tmp/model_repo --entrypoint /bin/bash --user root tritonserver_buildbase

docker run --rm -it -v "$(pwd)":/tmp/model_repo --entrypoint /bin/bash --user root centos9_triton

docker run --rm -it -v "$(pwd)":/tmp/model_repo -p 8000:8000 -p 8001:8001 -p 8002:8002 --entrypoint /bin/bash --user root tritonserver

/tmp/model_repo/tritonserver/bin/tritonserver --model-repository=/tmp/model_repo/Triton_test --allow-metrics=true

/opt/tritonserver/bin/tritonserver --model-repository=/tmp/model_repo/Triton_test --allow-metrics=true

docker run --rm -it --entrypoint /bin/bash --user root nvcr.io/nvidia/tritonserver:24.09-py3-min


apt-get update \
      && apt-get install -y --no-install-recommends \
            python3 \
            libarchive-dev \
            python3-pip \
            libpython3-dev \
      && pip3 install --upgrade pip \
      && pip3 install --upgrade \
            wheel \
            setuptools \
            "numpy<2" \
            virtualenv \

# Test
curl -v localhost:8000/v2/health/ready


curl -v http://127.0.0.1:8002/metrics

# dependency to use new triton
#libb64.so.0d
#libnuma.so.1
#libstdc++.so.6: version `GLIBCXX_3.4.30'  # yum reinstall libstdc++ -y