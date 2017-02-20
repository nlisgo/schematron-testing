#!/bin/bash

SCRIPTPATH=$( cd $(dirname $0) ; pwd -P )

if [ ! -d $SCRIPTPATH/elife-article-xml ]; then
  cd $SCRIPTPATH
  git clone https://github.com/elifesciences/elife-article-xml.git
fi

if [ ! -d $SCRIPTPATH/niso-jats ]; then
  cd $SCRIPTPATH
  git clone https://github.com/ncbi/niso-jats.git
fi

if [ ! -d $SCRIPTPATH/reference-schematron ]; then
  cd $SCRIPTPATH
  git clone https://github.com/elifesciences/reference-schematron.git
  cd $SCRIPTPATH/reference-schematron
  ln -s ../eLife-elem-citation-driver-final-compiled.xsl ./
fi
