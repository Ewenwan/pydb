#!/bin/sh
#$Id: autogen.sh,v 1.4 2008/11/16 17:10:05 rockyb Exp $
# Run this to generate all the initial makefiles, etc.

srcdir=$(dirname $0)

aclocal
automake --add-missing --gnu
autoconf

conf_flags="--enable-maintainer-mode" # --enable-compile-warnings #--enable-iso-c

if test x$NOCONFIGURE = x; then
  echo Running $srcdir/configure $conf_flags "$@" ...
  $srcdir/configure $conf_flags "$@" \
  && echo Now type \`make\' to compile $PKG_NAME
else
  echo Skipping configure process.
fi
