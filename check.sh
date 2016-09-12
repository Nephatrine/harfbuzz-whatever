#!/bin/bash

export LC_ALL=C

srcdir=src
incdir=include
stat=0

HBHEADERS=`cd "$inccdir"; find . -maxdepth 1 -name 'hb*.h'`
HBSOURCES=`cd "$srcdir"; find . -maxdepth 1 -name 'hb-*.cc' -or -name 'hb-*.hh' -or -name 'hb-*.h'`

for x in $HBHEADERS; do
	test -f $incdir/$x && x=$incdir/$x

	if ! grep -q HB_BEGIN_DECLS "$x" || ! grep -q HB_END_DECLS "$x"; then
		echo "Ouch, file $x does not have HB_BEGIN_DECLS / HB_END_DECLS, but it should"
		stat=1
	fi

	fh=`grep '#.*\<include\>' "$x" /dev/null | head -n 1 | grep -v '"hb-common[.]h"' | grep -v '"hb[.]h"' | grep -v 'hb-common[.]h:' | grep -v 'hb[.]h:' | grep .`
	if test "x$fh" != "x"; then
		echo "Ouch, file $x needs to include hb.h or hb-common.h first instead of $fh."
		stat=1
	fi

	if grep '#.*\<include\>.*<.*hb' "$x"; then
		echo "Ouch, file $x includes <hb.*.h>."
	fi

	xx=`echo "$x" | sed 's@.*/@@'`
	tag=`echo "$xx" | tr 'a-z.-' 'A-Z_'`
	lines=`grep -w "$tag" "$x" | wc -l | sed 's/[   ]*//g'`

	if test "x$lines" != x3; then
		echo "Ouch, file $x does not have correct preprocessor guards"
		stat=1
	fi
done

for x in $HBSOURCES; do
	test -f $srcdir/$x && x=$srcdir/$x

	if grep -q HB_BEGIN_DECLS "$x" || grep -q HB_END_DECLS "$x"; then
		echo "Ouch, file $x has HB_BEGIN_DECLS / HB_END_DECLS, but it shouldn't"
		stat=1
	fi

	fh=`grep '#.*\<include\>' "$x" /dev/null | grep -v 'include _' | head -n 1 | grep -v '"hb-.*private[.]hh"' | grep -v 'hb-private[.]hh:' | grep .`
	if test "x$fh" != "x"; then
		echo "Ouch, file $x needs to include hb-private.hh first instead of $fh."
		stat=1
	fi

	if grep '#.*\<include\>.*<.*hb' "$x"; then
		echo "Ouch, file $x includes <hb.*.h>."
	fi

	echo "$x" | grep -q '[^h]$' && continue;
	xx=`echo "$x" | sed 's@.*/@@'`
	tag=`echo "$xx" | tr 'a-z.-' 'A-Z_'`
	lines=`grep -w "$tag" "$x" | wc -l | sed 's/[   ]*//g'`

	if test "x$lines" != x3; then
		echo "Ouch, file $x does not have correct preprocessor guards"
		stat=1
	fi
done

OBJS=`find . -name '*.o'`
if test "x`echo $OBJS`" = "x$OBJS" 2>/dev/null >/dev/null; then
	echo "check-static-inits.sh: object files not found; skipping test"
fi

for obj in $OBJS; do
	if objdump -t "$obj" | grep '[.][cd]tors' | grep -v '\<00*\>'; then
		echo "Ouch, $obj has static initializers/finalizers"
		stat=1
	fi
	if objdump -t "$obj" | grep '__cxa_'; then
		echo "Ouch, $obj has lazy static C++ constructors/destructors or other such stuff"
		stat=1
	fi
done

LIBS=`find . -name '*.so'`
if test "x`echo $LIBS`" = "x$LIBS" 2>/dev/null >/dev/null; then
	echo "check-symbols.sh: object files not found; skipping test"
fi

for so in $LIBS; do
	EXPORTED_SYMBOLS="`nm "$so" | grep ' [BCDGINRSTVW] ' | grep -v ' _fini\>\| _init\>\| _fdata\>\| _ftext\>\| _fbss\>\| __bss_start\>\| __bss_start__\>\| __bss_end__\>\| _edata\>\| _end\>\| _bss_end__\>\| __end__\>\| __gcov_flush\>\| llvm_' | cut -d' ' -f3`"
	
	if echo "$EXPORTED_SYMBOLS" | grep -v "^hb_"; then
		echo "Ouch, $so has internal symbols exposed"
		echo "$EXPORTED_SYMBOLS" | grep -v "^hb_"
		stat=1
	fi

	if ldd $so | grep 'libstdc[+][+]\|libc[+][+]'; then
		echo "Ouch, $so linked to libstdc++ or libc++"
		stat=1
	fi
done

exit $stat

