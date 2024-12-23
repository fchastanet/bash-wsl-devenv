#!/usr/bin/env bash

helpDescription() {
  echo "Upgrade ubuntu apt softwares"
}

helpVariables() {
  echo "${__HELP_EXAMPLE}UPGRADE_UBUNTU_VERSION${__HELP_NORMAL}"
  echo "  possible values:"
  echo "  - 0             => no upgrade at all"
  echo "  - lts (default) => UPGRADE to latest ubuntu lts version"
  echo "  - dev           => UPGRADE to latest ubuntu dev version"
}

listVariables() {
  echo "UPGRADE_UBUNTU_VERSION"
}

defaultVariables() {
  export UPGRADE_UBUNTU_VERSION="lts"
}

checkVariables() {
  if ! Assert::varExistsAndNotEmpty "UPGRADE_UBUNTU_VERSION"; then
    return 1
  elif ! Array::contains "${UPGRADE_UBUNTU_VERSION}" "lts" "dev"; then
    Log::displayError "UPGRADE_UBUNTU_VERSION values expects to be lts or dev"
    return 1
  fi
}

# jscpd:ignore-start
fortunes() { :; }
dependencies() { :; }
breakOnConfigFailure() { :; }
breakOnTestFailure() { :; }
testInstall() { :; }
configure() { :; }
testConfigure() { :; }
# jscpd:ignore-end

install() {
  Linux::Apt::update
  Log::displayInfo "Apt upgrade"
  Retry::default sudo apt-get upgrade -y
  Log::displayInfo "Dist Apt upgrade"
  Retry::default sudo apt-get dist-upgrade -y
  Log::displayInfo "Apt autoremove"
  Retry::default sudo apt-get autoremove -y

  # add do-release-upgrade
  SKIP_APT_GET_UPDATE=1 Linux::Apt::installIfNecessary --no-install-recommends ubuntu-release-upgrader-core

  Log::displayInfo "configure to upgrade to the latest LTS development release"
  sudo sed -i -r 's/^Prompt=.*$/Prompt=lts/g' /etc/update-manager/release-upgrades
  if sudo do-release-upgrade -c; then
    if [[ "${UPGRADE_UBUNTU_VERSION}" = "lts" ]]; then
      Log::displayInfo "Upgrading to latest lts ubuntu - please be patient, it can take a long time"
      Retry::default sudo do-release-upgrade -f DistUpgradeViewNonInteractive --allow-third-party
      Log::displayHelp "Please restart wsl - 'wsl --shutdown'"
    else
      Log::displayHelp "An lts ubuntu upgrade is available, update UPGRADE_UBUNTU_VERSION=lts in .env file if you want to upgrade next time (use with caution)"
    fi
  fi

  Log::displayInfo "configure to upgrade to the latest non-LTS development release"
  sudo sed -i -r 's/^Prompt=.*$/Prompt=normal/g' /etc/update-manager/release-upgrades
  if sudo do-release-upgrade -c; then
    if [[ "${UPGRADE_UBUNTU_VERSION}" = "dev" ]]; then
      Log::displayInfo "Upgrading to latest non-lts ubuntu - please be patient, it can take a long time"
      Retry::default sudo do-release-upgrade -f DistUpgradeViewNonInteractive --allow-third-party
      Log::displayHelp "Please restart wsl - 'wsl --shutdown'"
    else
      Log::displayHelp "A non-lts ubuntu upgrade is available, update UPGRADE_UBUNTU_VERSION=dev in .env file if you want to upgrade next time (use with caution)"
    fi
  fi

  Log::displayInfo "restore to lts development release"
  sudo sed -i -E 's/^Prompt=.*$/Prompt=lts/g' /etc/update-manager/release-upgrades
}
