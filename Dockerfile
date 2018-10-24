FROM ubuntu:16.04 as builder

# Install some dep packages

ENV TENSORFLOW_VERSION 1.8.0
ENV PROJECT_PACKAGES python-pip python-dev software-properties-common curl

RUN apt-get update && \
    apt-get install -y $PROJECT_PACKAGES && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN mkdir -p /builder
WORKDIR /builder

############
# Install dependencies for build Tensorflow from sources and build Tensorflow Tools for freeze and optimize models

RUN python -m   pip install six numpy wheel mock && \
        pip install keras_applications==1.0.5 --no-deps && \
        pip install keras_preprocessing==1.0.3 --no-deps

# Install Java SDK
RUN add-apt-repository -y ppa:webupd8team/java && apt-get update && \
  echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 select true" | debconf-set-selections && \
  apt-get install -y oracle-java8-installer

# Install Bazel
RUN echo "deb [arch=amd64] http://storage.googleapis.com/bazel-apt stable jdk1.8" | tee /etc/apt/sources.list.d/bazel.list &&  \
  curl https://bazel.build/bazel-release.pub.gpg | apt-key add - && \
  apt-get update && apt-get -y install bazel && \
  apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Download tensorflow sources and build Tools for freeze and optimize models
# Tools build-ed as static and contain all necessary itself and run without dependency
RUN wget -O tensorflow-$TENSORFLOW_VERSION.tar.gz https://github.com/tensorflow/tensorflow/archive/v$TENSORFLOW_VERSION.tar.gz  && \
  tar xf tensorflow-1.8.0.tar.gz && \
  cd tensorflow-$TENSORFLOW_VERSION && \
  ./configure && \
  bazel build -c opt --config=monolithic tensorflow/tools/graph_transforms:transform_graph && \
  bazel build -c opt --config=monolithic tensorflow/tools/graph_transforms:summarize_graph
############

RUN ls -alh /builder/tensorflow-$TENSORFLOW_VERSION/bazel-bin/tensorflow/tools/graph_transforms/

# Copy builded files to output folder
RUN mkdir -p /builder/out && \
    cp -r /builder/tensorflow-$TENSORFLOW_VERSION/bazel-bin/tensorflow/tools/graph_transforms/transform_graph /builder/out && \
    cp -r /builder/tensorflow-$TENSORFLOW_VERSION/bazel-bin/tensorflow/tools/graph_transforms/summarize_graph /builder/out && \
    echo $TENSORFLOW_VERSION > /builder/out/tf_version_$TENSORFLOW_VERSION

#
# Results container
#

FROM scratch

COPY --from=builder /builder/out/* /tensorflow_tools/
