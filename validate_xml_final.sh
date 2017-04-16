#!/bin/bash

SCRIPTPATH=$( cd $(dirname $0) ; pwd -P )

DPATH="$SCRIPTPATH/article-xml/*.xml"
for f in $DPATH
do
  if [ -f $f -a -r $f ]; then
    echo ":start $f:"
    echo ""
    java -jar Saxon-HE-9.6.0-4.jar "$f" "$SCRIPTPATH/reference-schematron/eLife-elem-citation-driver-final-compiled.xsl" 2>&1 | sed -e 's/&gt;/>/g' | sed -e 's/&lt;/</g' | sed -e 's/<?xml.*//g'
    echo ""
    echo ":finish $f:"
  else
    echo "Error: Cannot read $f"
  fi
done
