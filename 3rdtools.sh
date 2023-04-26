#!/bin/bash

me=`basename "$0"`
rootdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
sourceroot="${rootdir}/.downloads"

function clean_exec {
  cmd=$*
  eval $cmd
  retcode=$?
  if [ $retcode -ne 0 ]; then
    echo "'${cmd}' exec failed with code $retcode, abort install process!"
    exit 255
  fi
}

function show_help {
  echo "usage: ${me} <install|distclean>"
}

function install {
  # create temporary dir to hold source code
  mkdir -p ${sourceroot}
  pushd ${sourceroot}
  ## mpich
  if [ ! -f mpich-3.2.1.tar.gz ]; then
    clean_exec wget -O mpich-3.2.1.tar.gz http://www.mpich.org/static/downloads/3.2.1/mpich-3.2.1.tar.gz
  fi
  clean_exec rm -rf mpich-3.2.1
  clean_exec tar vxzf mpich-3.2.1.tar.gz

  pushd mpich-3.2.1
  clean_exec ./configure --with-pic --enable-static --disable-shared --disable-fortran --disable-mpi-fortran --enable-mpi-thread-mutliple --prefix=${rootdir}/3rd/mpich-3.2.1
  clean_exec make -j$(nproc)
  clean_exec make install
  popd

  pushd ${rootdir}/3rd
  clean_exec ln -nsf mpich-3.2.1 mpich
  popd

  popd
  echo "build 3rd done, you can remove .downloads now."
}

function distclean {
  pushd ${rootdir}/3rd

  clean_exec rm mpich mpich-3.2.1 -rf 
  popd

  rm ${sourceroot} -rf

  echo "distclean 3rd done!"
}

if [ x$1 != x ]; then
  if [ $1 = "install" ]; then
    install; exit 0
  elif [ $1 = "distclean" ]; then
    distclean; exit 0
  else
    show_help; exit 1
  fi
else
  show_help; exit 1
fi