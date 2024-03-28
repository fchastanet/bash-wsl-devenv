#!/usr/bin/env bash

# @description Install debian package (with .deb extension)
# @arg $1 debFile:String
Linux::installDeb() {
  sudo dpkg -i "$1"
  sudo rm -f "$1"
}
