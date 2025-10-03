FROM ghcr.io/converged-computing/google-performance-study:kripke-caliper-test

LABEL maintainer="Vanessasaurus <@vsoch>"

# Install extra buildrequires for flux-sched:
RUN sudo apt-get update
RUN sudo apt-get -qq install -y --no-install-recommends \
    hwloc libxml2-utils