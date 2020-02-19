# Build-only image
FROM ubuntu:18.04 AS build
USER root
WORKDIR /opt/shellCheck

# Install OS deps
RUN apt-get update && apt-get install -y ghc cabal-install

# Install Haskell deps
# (This is a separate copy/run so that source changes don't require rebuilding)
COPY shellcheck/ShellCheck.cabal ./
RUN cabal update && cabal install --dependencies-only --ghc-options="-optlo-Os -split-sections"

# Copy source and build it
COPY shellcheck/LICENSE shellcheck/shellcheck.hs ./
COPY shellcheck/src src
RUN cabal build Paths_ShellCheck && \
  ghc -optl-static -optl-pthread -isrc -idist/build/autogen --make shellcheck -split-sections -optc-Wl,--gc-sections -optlo-Os && \
  strip --strip-all shellcheck

RUN mkdir -p /out/bin && \
  cp shellcheck  /out/bin/

# build ace
FROM node:8 AS ace
WORKDIR /opt/ace
COPY ace/ ./
RUN npm install
RUN node Makefile.dryice.js full

# Resulting ShellCheck.web image
FROM php:7.4-apache
LABEL maintainer="Stefan Rinkes <stefan.rinkes@gmail.com>"
WORKDIR /var/www/html
COPY shellcheck.net ./
COPY --from=build /out /
COPY --from=ace /opt/ace/build/src ./libace
RUN a2enmod rewrite
