# Virtualization - My First Container

## Table of Contents
- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Steps](#steps)
  - [Step 1: Isolated Filesystem Setup](#step-1-isolated-filesystem-setup)
  - [Step 2: Isolated Filesystem Environment](#step-2-isolated-filesystem-environment)
  - [Step 3: PID Namespace](#step-3-pid-namespace)
- [Automation](#automation)
- [Technologies Used](#technologies-used)
- [Contributing](#contributing)
- [License](#license)

## Overview

This project guides you through the creation of your first container using Linux virtualization techniques. You will learn how to create an isolated environment, simulate a container, and understand how containers work internally using namespaces and other Linux tools. 

The container environment is set up using **unshare** commands, and the project helps you create an isolated filesystem and a PID namespace for your container.

## Prerequisites

- Basic understanding of Linux commands and the terminal.
- Working on **Ubuntu** or any Linux distribution (or WSL2 on Windows).
- Installed packages: `lxc`, `debootstrap`, `lxc-templates`.

## Steps

### Step 1: Isolated Filesystem Setup

1. Create an isolated filesystem with basic Unix directories.
   - Create a directory on your machine for the root filesystem:
     ```bash
     mkdir /tmp/rootfs
     ```
   - If you are running on a Debian-based Linux, run the `debootstrap` command:
     ```bash
     debootstrap stable /tmp/rootfs
     ```
   - If you're not on a Debian-based system, install the `lxc` and `lxc-templates` packages and run:
     ```bash
     lxc-create -t <linux-distribution> -n containerName
     ```
     Copy the root filesystem from `/var/lib/lxc/containerName/rootfs` to `/tmp/rootfs`.

2. Compare the contents of `/tmp/rootfs` with the `/` directory on your host machine:
   ```bash
   ls -la /tmp/rootfs
   ls -la /
