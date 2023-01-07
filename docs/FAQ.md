# Dev-env - FAQ

- [1. VirtualBox - (optional) Install Vcxsrv](#1-virtualbox---optional-install-vcxsrv)
- [2. VirtualBox - fix ssh](#2-virtualbox---fix-ssh)

## 1. VirtualBox - (optional) Install Vcxsrv

only useful if using virtualbox, install X client

- [VcxSrv](https://sourceforge.net/projects/vcxsrv/)

Then create a file config.xlaunch that you will have to launch every time you
want to use X11 with this content

```xml
<?xml version="1.0" encoding="UTF-8"?>
<XLaunch
    WindowMode="MultiWindow"
    ClientMode="NoClient"
    LocalClient="False"
    Display="-1"
    LocalProgram="xcalc"
    RemoteProgram="xterm"
    RemotePassword=""
    PrivateKey=""
    RemoteHost=""
    RemoteUser=""
    XDMCPHost=""
    XDMCPBroadcast="False"
    XDMCPIndirect="False"
    Clipboard="True"
    ClipboardPrimary="False"
    ExtraParams=""
    Wgl="True"
    DisableAC="True"
    XDMCPTerminate="False"
/>
```

## 2. VirtualBox - fix ssh

service ssh does not work, only work on manual sshd launch sudo /usr/bin/sshd -d
-p 2222

Out of the box, sshd doesn’t work because the installer doesn’t create the host
keys correctly. The easiest way to fix that, is to remove ssh and install it
again.

```bash
sudo apt-get remove --purge openssh-server
sudo apt-get install openssh-server
sudo service ssh --full-restart
```
