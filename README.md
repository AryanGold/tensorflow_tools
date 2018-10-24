## Build-ed TensorFlow v1.8.0 Graph Transform Tools

Build-ed TensorFlow v1.8.0 tools like "transform_graph" and "summarize_graph", details about tools:
https://github.com/tensorflow/tensorflow/blob/master/tensorflow/tools/graph_transforms/README.md
Such tools convenient for freeze and optimize TF models for inference.
Tools build-ed as static and contain all necessary itself and run without dependency.
Base container: 'scratch'  
Tools path in container: /tensorflow_tools/*  
Build-ed for: Linux x64  

Sample usage in Docker multi-stage mode, assume that your model store in host by path /usr/model/model.pb then for show Graph summaries like input/output nodes:
Dockerfile:
_________________________________________
FROM aryangold/tensorflow_tools:1.8.0 as tensorflow_tools  
FROM ubuntu:16.04  

RUN mkdir -p /work  
WORKDIR /work

COPY --from=tensorflow_tools /tensorflow_tools/* /work/tensorflow_tools/

CMD /work/tensorflow_tools/summarize_graph --in_graph=/model/model.pb
_________________________________________

> docker build -t tf_tools:latest --rm -f Dockerfile .

> docker run --rm -it -v /usr/model:/model tf_tools:latest
