#!/bin/bash

SCRIPTPATH=$( cd $(dirname $0) ; pwd -P )

OLD="\"JATS-archivearticle1.dtd\""
NEW="\"..\/niso-jats\/archiving\/1.1d3\/JATS-archivearticle1.dtd\""
SFILES="$SCRIPTPATH/elife-article-xml/articles/*.xml"
DPATH="$SCRIPTPATH/article-xml/"
DFILES="$SCRIPTPATH/article-xml/*.xml"
TFILE="/tmp/out.tmp.$$"
[ ! -d $DPATH ] && mkdir -p $DPATH || :
for f in $SFILES
do
  if [ -f $f -a -r $f ]; then
    cp $f $DPATH
  else
    echo "Error: Cannot read $f"
  fi
done
for f in $DFILES
do
  if [ -f $f -a -r $f ]; then
    sed "s/$OLD/$NEW/g" "$f" > $TFILE && mv $TFILE "$f"
  else
    echo "Error: Cannot read $f"
  fi
done
