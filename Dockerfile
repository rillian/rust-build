FROM          centos-gcc:build.clean
MAINTAINER    Ralph Giles <giles@mozilla.com>

# Update and install base tools.
RUN yum upgrade -y
RUN yum install -y file
RUN yum clean all

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

# Invoke our build scripts by default, but allow other commands.
USER ${USER}
CMD bin/checkout-sources.sh && bin/build.sh
