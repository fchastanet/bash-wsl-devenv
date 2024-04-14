#!/bin/bash

# @description get current executed shell
# @stdout the current executed shell
Linux::getCurrentExecutedShell() {
  readlink /proc/$$/exe
}
