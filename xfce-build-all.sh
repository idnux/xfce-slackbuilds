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
#  Modified 2017 by Ali Ahmadi.

# Set to 1 if you'd like to install/upgrade package as they are built.
# This is recommended.
INST=1

# This is where all the compilation and final results will be placed
TMP=${TMP:-/tmp/idnux}
OUTPUT=${OUTPUT:-/tmp}

# This is the original directory where you started this script
XFCEROOT=$(pwd)

# Check for duplicate sources (default: OFF)
CHECKDUPLICATE=0

# Loop for all packages
for dir in \
  xfce/xfce4-dev-tools \
  xfce/libxfce4util \
  xfce/xfconf \
  xfce/libxfce4ui \
  xfce/exo \
  xfce/garcon \
  deps/libwnck3 \
  deps/glade \
  deps/gtksourceview3 \
  xfce/xfce4-panel \
  xfce/Thunar \
  xfce/thunar-volman \
  xfce/tumbler \
  xfce/xfce4-settings \
  xfce/xfce4-session \
  xfce/xfdesktop \
  xfce/xfwm4 \
  xfce/xfce4-appfinder \
  deps/upower \
  xfce/xfce4-power-manager \
  xfce/gtk-xfce-engine \
  apps/mousepad \
  apps/orage \
  apps/parole \
  apps/ristretto \
  apps/xfce4-notifyd \
  apps/xfce4-screensaver \
  apps/xfce4-screenshooter \
  apps/xfce4-taskmanager \
  apps/xfce4-terminal \
  apps/xfce4-dict \
  apps/xfce4-volumed-pulse \
  deps/libisofs \
  deps/libburn \
  apps/xfburn \
  deps/python-distutils-extra \
  deps/pyxdg \
  deps/ptyprocess \
  deps/pexpect \
  apps/catfish \
  apps/xfce4-panel-profiles \
  panel-plugins/xfce4-battery-plugin \
  panel-plugins/xfce4-calculator-plugin \
  panel-plugins/xfce4-clipman-plugin \
  panel-plugins/xfce4-cpufreq-plugin \
  panel-plugins/xfce4-cpugraph-plugin \
  panel-plugins/xfce4-datetime-plugin \
  panel-plugins/xfce4-diskperf-plugin \
  panel-plugins/xfce4-fsguard-plugin \
  panel-plugins/xfce4-genmon-plugin \
  panel-plugins/xfce4-mount-plugin \
  panel-plugins/xfce4-netload-plugin \
  panel-plugins/xfce4-places-plugin \
  panel-plugins/xfce4-pulseaudio-plugin \
  panel-plugins/xfce4-sensors-plugin \
  panel-plugins/xfce4-smartbookmark-plugin \
  panel-plugins/xfce4-systemload-plugin \
  panel-plugins/xfce4-timer-plugin \
  panel-plugins/xfce4-weather-plugin \
  panel-plugins/xfce4-whiskermenu-plugin \
  panel-plugins/xfce4-xkb-plugin \
  deps/libunique \
  panel-plugins/xfce4-notes-plugin \
  thunar-plugins/thunar-archive-plugin \
  thunar-plugins/thunar-media-tags-plugin \
  thunar-plugins/thunar-vcs-plugin \
  ; do
  # Get the package name
  package=$(echo $dir | cut -f2- -d /)

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
