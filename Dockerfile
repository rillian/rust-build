FROM          debian:latest
MAINTAINER    Ralph Giles <giles@mozilla.com>

# Update and install base tools.
RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install -y \
  ca-certificates sudo curl python xz-utils \
  make git binutils gcc g++
RUN apt-get clean

# Install tooltool directly from github.
RUN mkdir /builds
ADD https://raw.githubusercontent.com/mozilla/build-tooltool/master/tooltool.py /builds/tooltool.py
RUN chmod +rx /builds/tooltool.py

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

# Set a default command useful for debugging.
USER ${USER}
CMD ["/bin/bash", "--login"]
