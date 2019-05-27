include config/build.config

KERNEL		= ${KMAJ}.${KMIN}
KERNELSOURCE	= ${KERNEL}
SCSTKERNEL	= ${KERNEL}
RC		=
REL		= .${KREV}
KVERSION	= ${KERNELSOURCE}${REL}
KPATCH		= patch-${KVERSION}.xz
KCONFIG		= config.${KERNEL}
OURVERSION	= nlytiq

PARALLEL	:= $(shell lscpu -p | wc -l)

KERNELP		= ${KERNELSOURCE}${RC}

#####
# CVE processing if needed
cves =  $(shell find source/ -type f | grep -i cve | grep patch$ )


all:	rpm deb
	touch all

rpm:	configured
	cd linux-${KERNELP} ; make -j${PARALLEL} rpm-pkg
	touch rpm

deb:	configured
	cd linux-${KERNELP} ; make -j${PARALLEL} deb-pkg
	tar -zcf linux-source-${KVERSION}.tar.gz linux-${KERNELP}
	touch deb

configured:  kpatched
	cat config/${KCONFIG} | \
		sed 's/^CONFIG_LOCALVERSION=""/CONFIG_LOCALVERSION=".${OURVERSION}"/'  \
		>  linux-${KERNELP}/.config
	cd linux-${KERNELP} ; patch -p1 < \
		../functional_patches/nlytiq_performance_p1.patch
	cd linux-${KERNELP} ; patch -p1 < \
		../functional_patches/nlytiq_performance_p3.patch
	touch linux-${KERNELP}/tools/objtool/sync-check.sh
	chmod u+x linux-${KERNELP}/tools/objtool/sync-check.sh
	cd linux-${KERNELP} ; make oldconfig
	touch configured

kpatched: linux-${KERNELP}
ifneq ($(REL),".0")
	cd linux-${KERNELP} ; xzcat ../source/${KPATCH} | patch -p1
endif
# deal with any cve-*.patch files in ../source
	cd linux-${KERNELP} ;	   \
	for cvepatch in $(cves) ; do    \
	    patch -p1 < ../$$cvepatch ; \
	done

	touch kpatched

linux-${KERNELP}:
	tar -xJf source/linux-${KERNELP}.tar.xz
	touch untarred-kernel

clean:
	rm -rf rpm deb all kpatched configured mkspeced untarred-kernel ubuntu-package
	rm -rf linux-${KERNELP} linux-source-${KVERSION}.tar.gz
	rm -f *.deb *.dsc *Custom.tar.gz *.changes perf-*gz linux*.tar.gz *diff.gz *buildinfo
