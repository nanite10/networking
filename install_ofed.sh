#!/bin/bash

yum makecache
kernel_version=`uname -r`
yum install rsync perl createrepo kernel-headers-$kernel_version python-devel pciutils lsof kernel-devel-$kernel_version redhat-rpm-config rpm-build gcc gtk2 atk cairo tcl tcsh tk -y
if ! [ -e /tmp/mlnx_ofed/mlnxofedinstall ]; then echo "ERROR: Could not find OFED installer /tmp/mlnx_ofed/mlnxofedinstall"; exit 1; fi
/tmp/mlnx_ofed/mlnxofedinstall --without-32bit --skip-distro-check --add-kernel-support --kmp --enable-mlnx_tune --enable-affinity --enable-opensm --all --upstream-libs --force
