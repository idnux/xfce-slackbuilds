#!/bin/sh

# Copyright 2012, 2015, 2016  Patrick J. Volkerding, Sebeka, Minnesota, USA
# All rights reserved.
#
# Redistribution and use of this script, with or without modification, is
# permitted provided that the following conditions are met:
#
# 1. Redistributions of this script must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
#
#  THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR IMPLIED
#  WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
#  MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO
#  EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
#  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
#  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
#  OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
#  WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
#  OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
#  ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#  Modified 2017 by Ali.

# Set to 1 if you'd like to install/upgrade package as they are built.
# This is recommended.
INST=1

# This is where all the compilation and final results will be placed
TMP=${TMP:-/tmp/idn}
OUTPUT=${OUTPUT:-/tmp}

# This is the original directory where you started this script
XFCEROOT=$(pwd)

# Check for duplicate sources (default: OFF)
CHECKDUPLICATE=0

# Loop for all packages
for dir in \
  extra/apps/xarchiver \
  extra/apps/xfce-polkit \
  extra/deps/python-psutil \
  extra/deps/gnome-menus \
  extra/apps/menulibre \
  extra/apps/mugshot \
  extra/deps/gtk-engine-murrine \
  extra/theme/greybird-gtk-theme \
  extra/theme/materia-gtk-theme \
  extra/theme/moka-icon-theme \
  ; do
  # Get the package name
  package=$(echo $dir | cut -f3- -d /)

  # Change to package directory
  cd $XFCEROOT/$dir || exit 1

  # Get the version
  version=$(cat ${package}.info | grep "VERSION" | cut -d = -f 2 | sed 's/"//g')

  # Get the build
  build=$(cat ${package}.SlackBuild | grep "BUILD:" | cut -d "-" -f2 | rev | cut -c 2- | rev)

  if [ $CHECKDUPLICATE -eq 1 ]; then
    # Check for duplicate sources
    sourcefile="$(ls -l $XFCEROOT/$dir/${package}-*.tar.?z* 2>/dev/null | wc -l)"
    if [ $sourcefile -gt 1 ]; then
      echo "You have following duplicate sources:"
      ls $XFCEROOT/$dir/${package}-*.tar.?z* | cut -d " " -f1
      echo "Please delete sources other than ${package}-$version to avoid problems"
      exit 1
    fi
  fi

  # The real build starts here
  TMP=$TMP OUTPUT=$OUTPUT sh ${package}.SlackBuild || exit 1
  if [ "$INST" = "1" ]; then
    PACKAGE=$(ls $OUTPUT/${package}-${version}-*-${build}*idn.txz 2>/dev/null)
    if [ -f "$PACKAGE" ]; then
      upgradepkg --install-new --reinstall "$PACKAGE"
    else
      echo "Error:  package to upgrade "$PACKAGE" not found in $OUTPUT"
      exit 1
    fi
  fi

  # back to original directory
  cd $XFCEROOT
done
