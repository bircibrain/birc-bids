FROM ubuntu:xenial
MAINTAINER <rhancock@gmail.com>
ARG DEBIAN_FRONTEND=noninteractive

ENV LANG="C.UTF-8" \
    LC_ALL="C.UTF-8"

# apt installs
## essential packages

RUN apt-get update -y && \
	apt-get upgrade -y && \
	apt-get install -yq --no-install-recommends \
	curl bzip2 tar ca-certificates git pigz unzip tcsh python file

#python

WORKDIR /tmp
ENV PATH="/usr/local/miniconda/bin:$PATH"
RUN curl -LO https://repo.anaconda.com/miniconda/Miniconda3-py38_4.10.3-Linux-x86_64.sh && \
	bash Miniconda3-py38_4.10.3-Linux-x86_64.sh -b -p /usr/local/miniconda && \
	conda config --add channels conda-forge && \
	conda install -y nibabel nipype pydicom
RUN pip install pybids

# dcm2niix
RUN curl -LO https://github.com/rordenlab/dcm2niix/releases/download/v1.0.20180622/dcm2niix_27-Jun-2018_lnx.zip  && \
	unzip dcm2niix_27-Jun-2018_lnx.zip && \
	mv dcm2niix /usr/local/bin

# dcm2bids
RUN pip install dcm2bids

# bidskit
RUN pip install bidskit

# heudiconv
RUN pip install https://github.com/nipy/heudiconv/archive/master.zip


# bids-tools
WORKDIR /usr/local
RUN git clone https://github.com/robertoostenveld/bids-tools.git
ENV PATH="$PATH:/usr/local/bids-tools/bin"

# validator
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash - && apt-get install -yq nodejs &&\
pip install bids_validator &&\
npm install -g bids-validator

# bind points
RUN mkdir /input && mkdir /output && mkdir /scripts && mkdir /scratch && \
    mkdir /data

# BIDScoin

WORKDIR /tmp
RUN curl -LO https://github.com/Donders-Institute/bidscoin/archive/refs/tags/3.6.3.zip  && \
	unzip 3.6.3.zip
COPY ./bidsmap_template.yaml /tmp/bidscoin-3.6.3/bidscoin/heuristics/
RUN cd bidscoin-3.6.3 && python setup.py install

RUN apt-get install -yq libgl1-mesa-glx

# Cleanup
#RUN apt-get clean && \
#	rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

WORKDIR /data

COPY entry_init.sh /singularity
RUN chmod 755 /singularity

RUN /usr/bin/env |sed  '/^HOME/d' | sed '/^HOSTNAME/d' | sed  '/^USER/d' | sed '/^PWD/d' > /environment && \
	chmod 755 /environment

ENTRYPOINT ["/singularity"]
