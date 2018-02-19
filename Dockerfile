FROM ubuntu:17.10
MAINTAINER Rafal Pronko


RUN apt-get update
RUN apt-get -y upgrade
RUN apt-get -y install software-properties-common python-software-properties
RUN add-apt-repository main
RUN add-apt-repository universe
RUN add-apt-repository restricted
RUN add-apt-repository multiverse
RUN echo "deb http://security.ubuntu.com/ubuntu xenial-security main" | tee -a /etc/apt/sources.list

RUN apt-get update
RUN apt-get upgrade


RUN apt-get -y install build-essential cmake git pkg-config \
               libjpeg8-dev libtiff5-dev libjasper-dev \
               libavcodec-dev libavformat-dev libswscale-dev libv4l-dev \
               libgtk2.0-dev \
               libatlas-base-dev gfortran \
               curl \
               wget \
               vim \
               htop \
               libmysqlclient-dev \
               build-essential \
               libgoogle-glog-dev \
               libprotobuf-dev \
               protobuf-compiler \
               libsqlite3-dev \
               sqlite3



RUN apt-get -y install python3.6 python3.6-dev

RUN apt-get -y install default-jre

RUN apt-get clean
RUN apt-get -y install scala
RUN wget http://mirrors.kernel.org/ubuntu/pool/main/libp/libpng/libpng12-0_1.2.54-1ubuntu1_amd64.deb
RUN dpkg -i libpng12-0_1.2.54-1ubuntu1_amd64.deb
RUN apt-get -y install libhdf5-serial-dev
RUN apt-get -y install python3-pip

# Install Tini
RUN curl -L https://github.com/krallin/tini/releases/download/v0.6.0/tini > tini && \
    echo "d5ed732199c36a1189320e6c4859f0169e950692f451c03e7854243b95f4234b *tini" | sha256sum -c - && \
    mv tini /usr/local/bin/tini && \
    chmod +x /usr/local/bin/tini


RUN add-apt-repository ppa:webupd8team/java
RUN apt-get update
RUN \
  echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
  add-apt-repository -y ppa:webupd8team/java && \
  apt-get update && \
  apt-get install -y oracle-java8-installer && \
  rm -rf /var/lib/apt/lists/* && \
  rm -rf /var/cache/oracle-jdk8-installer

RUN wget http://apache.uib.no/spark/spark-2.2.1/spark-2.2.1-bin-hadoop2.7.tgz
RUN tar xvf spark-2.2.1-bin-hadoop2.7.tgz
RUN rm spark-2.2.1-bin-hadoop2.7.tgz
RUN mv spark-2.2.1-bin-hadoop2.7 /opt/spark-2.2.1
RUN ln -s /opt/spark-2.2.1 /opt/spark
ENV SPARK_HOME=/opt/spark
ENV PATH=$SPARK_HOME/bin:$PATH


# Add a notebook profile.
RUN mkdir -p -m 700 /root/.jupyter/ && \
    echo "c.NotebookApp.ip = '*'" >> /root/.jupyter/jupyter_notebook_config.py

VOLUME /notebooks
WORKDIR /notebooks


RUN pip3 --no-cache-dir install ipykernel
RUN python3 -m ipykernel.kernelspec
RUN rm -rf /root/.cache

ADD requirments.txt /notebooks
RUN pip3 install --upgrade pip setuptools
RUN pip3 install -r requirments.txt
RUN pip3 install pyspark
# RUN pip3 install ipywidgets jupyter nbextension enable --py widgetsnbextension

# RUN python3 -m spacy download en

ENV PYSPARK_DRIVER_PYTHON=jupyter
ENV PYSPARK_DRIVER_PYTHON_OPTS='notebook --no-browser --allow-root'

EXPOSE 8888
ENV JAVA_HOME /usr/lib/jvm/java-8-oracle
ENTRYPOINT ["tini", "--"]
CMD ["pyspark"]
