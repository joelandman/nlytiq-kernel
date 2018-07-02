# nlytiq-kernel
Build environment for Nlytiq linux kernels, used as the base for HVM systems

## Use
* clone the repo onto a Debian9 or CentOS7 machine
  ```git clone https://github.com/joelandman/nlytiq-kernel```
* get into the kernel build directory
  ```cd nlytiq-kernel```
* update the build.conf to use the latest kernel patch in `$KERNEL/source`
  ```./gen_buildconf.pl```
* get into the specific kernel directory
  ```cd $KERNEL```
* make a deb (for Debian9/Ubuntu16.04++) or rpm (for Centos7/RHEL7)
  - CentOS7/RHEL7: ```make rpm```
  - Debian9/Ubuntu 16.04 or later: ```make deb```
  
