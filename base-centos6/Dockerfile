FROM          centos:6
MAINTAINER    Ralph Giles <giles@mozilla.com>

# Update and install base tools.
RUN yum upgrade -y
RUN yum install -y make tar xz bzip2 git binutils gcc g++ m4
RUN yum clean all

# Create user for doing the build.
ENV USER worker
ENV HOME /home/${USER}

RUN useradd -d ${HOME} -m ${USER}

# Set up the user's tree
WORKDIR ${HOME}

# Add build scripts.
#
# These are the entry points from the taskcluster worker,
# and operate on environment variables
ADD             checkout-sources.sh build.sh bin/
RUN             chmod +x bin/*

ADD             SHA256SUMS.txt workspace/
# Invoke our build scripts by default, but allow other commands.
#USER ${USER}
CMD bin/checkout-sources.sh && bin/build.sh
