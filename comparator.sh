#!/bin/bash

#Quick bash script to compare the contents of two directories. 

DEFAULTSRC='.'
DEFAULTDST='.'
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput bold)$(tput setaf 4)
WHITE=$(tput bold)
RESET=$(tput sgr0)

while getopts "vfrh" opt; do
  case "$opt" in
    f)
      forward=true
      ;;
    r)
      reverse=true
      ;;
    v)
      verbose=$((verbose+1))
      ;;
    h)
      echo "Usage: comparator [-vfr] [source] [destination]"
      echo ""
      echo "Compare recursivee contents of source and destination directories"
      echo ""
      echo " -v   verbose output, up to 3 v's accepted for more output"
      echo " -f   forward only"
      echo " -r   reverse only"
      echo ""
      echo "If no source or destination is given, defaults are used"
      exit 0
      ;;
  esac
done
shift $((OPTIND-1))

src=$1
dst=$2

if [ -z $1 ]; then
  src=$DEFAULTSRC
fi
if [ -z $2]; then
  dst=$DEFAULTDST
fi

compare() {
  a=$1
  b=$2
  csa=0
  cdf=0
  cno=0
  for f in `find $a -type f | sed "s $a/  "`
  do
    if [[ $verbose -gt 1 ]]; then
      echo "${WHITE}Comparing $f and $b/$f$RESET"
    fi
    if [ -e $b/$f ]
    then
      amd5=$(openssl md5 $a/$f | awk '{print $2}')
      bmd5=$(openssl md5 $b/$f | awk '{print $2}')
      if [[ $verbose -gt 2 ]]; then
        echo "$WHITE$a/$f => $amd5$RESET"
        echo "$WHITE$b/$f => $bmd5$RESET"
      fi
      if [[ $amd5 == $bmd5 ]]
      then
        if [[ $verbose -gt 0 ]]; then
          echo "$GREEN[SAME] $f$RESET"
        fi
        csa=$((csa+1))
      else
        echo "$YELLOW[DIFF] $f$RESET"
        cdf=$((cdf+1))
      fi
    else
      echo "$RED[NOPE] $f$RESET"
      cno=$((cno+1))
    fi
  done
  echo "${WHITE}SAME: $csa$RESET"
  echo "${WHITE}DIFF: $cdf$RESET"
  echo "${WHITE}NOPE: $cno$RESET"
}

if [ ! $reverse ]; then
  echo "$BLUE=FORWARD======================================================$RESET"
  echo "${WHITE}Finding files from $src in $dst$RESET"
  compare $src $dst
fi
if [ ! $forward ]; then
  echo "$BLUE=REVERSE======================================================$RESET"
  echo "${WHITE}Finding files from $dst in $src$RESET"
  compare $dst $src
fi
