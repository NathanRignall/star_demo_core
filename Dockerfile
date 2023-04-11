FROM ubuntu:22.04

# use wget to download the alire
RUN apt-get update && apt-get install -y wget git unzip curl build-essential

# set the working directory
WORKDIR /

# install alire
RUN wget https://github.com/reznikmm/aarch64-alire-index/releases/download/v1.2.1/alr-1.2.1-bin-aarch64-linux.zip

# unzip alire
RUN unzip alr-1.2.1-bin-aarch64-linux.zip

# add alire to the path
ENV PATH="/alr-1.2.1/bin:${PATH}"

# clone the project
RUN git clone https://github.com/reznikmm/aarch64-alire-index.git

# reset index
RUN alr index --reset-community

# add the index
RUN alr index --add file://$PWD/aarch64-alire-index --name aarch64 --before community

# select the toolchain
RUN alr toolchain --select gnat_native=12.2.1 gprbuild=22.0.1

# add the project
ADD . /project

# set the working directory
WORKDIR /project

# build the project
RUN alr build

# run the project
CMD ["./bin/star_demo_core"]