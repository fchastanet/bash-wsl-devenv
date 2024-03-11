#!/bin/bash

# @description deduce wsl host ip
# @env HOST_IP exported env containing the IP
Engine::Config::loadHostIp() {
  HOST_IP="$(/sbin/ip route | awk '/default/ { print $3 }')"

  export HOST_IP
}
