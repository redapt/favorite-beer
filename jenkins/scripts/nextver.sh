#! /bin/bash

RE='[^0-9]*\([0-9]*\)[.]\([0-9]*\)[.]\([0-9]*\)\([0-9A-Za-z-]*\)'

step="$1"
if [ -z "$1" ]
then
  step=patch
fi

base="$2"
if [ -z "$2" ]
then
  base=$(cat VERSION 2>/dev/null| tail -n 1)
  if [ -z "$base" ]
  then
    base=0.0.0
  fi
fi

MAJOR=`echo $base | sed -e "s#$RE#\1#"`
MINOR=`echo $base | sed -e "s#$RE#\2#"`
PATCH=`echo $base | sed -e "s#$RE#\3#"`
SUFFIX=`echo $base | sed -e "s#$RE#\4#"`

case "$step" in
  major)
    let MAJOR+=1
    MINOR=0
    PATCH=0
    ;;
  major-no-suffix)
    let MAJOR+=1
    MINOR=0
    PATCH=0
    SUFFIX=""
    ;;
  minor)
    let MINOR+=1
    PATCH=0
    ;;
  minor-no-suffix)
    let MINOR+=1
    PATCH=0
    SUFFIX=""
    ;;
  patch)
    let PATCH+=1
    ;;
  patch-no-suffix)
    let PATCH+=1
    SUFFIX=""
    ;;
  current)
    ;;
  current-no-suffix)
    SUFFIX=""
    ;;
esac

echo "$MAJOR.$MINOR.$PATCH$SUFFIX"