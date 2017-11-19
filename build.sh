#!/bin/bash
# Build Script By Tkkg1994 and djb77
# Modified by GhaithCraft/ XDA Developers

# ---------
# VARIABLES
# ---------
ARCH=arm64
BUILD_CROSS_COMPILE=/home/ghaith/android/Toolchains/gcc-linaro-7.1.1-2017.08-i686_aarch64-linux-gnu/bin/aarch64-linux-gnu-
BUILD_JOB_NUMBER=`grep processor /proc/cpuinfo|wc -l`
RDIR=$(pwd)
OUTDIR=$RDIR/arch/$ARCH/boot
DTSDIR=$RDIR/arch/$ARCH/boot/dts
DTBDIR=$OUTDIR/dtb
DTCTOOL=$RDIR/scripts/dtc/dtc
INCDIR=$RDIR/include
PAGE_SIZE=2048
DTB_PADDING=0
ZIPLOC=zip
RAMDISKLOC=ramdisk

# ---------
# FUNCTIONS
# ---------
FUNC_CLEAN()
{
make -j$BUILD_JOB_NUMBER ARCH=$ARCH \
	CROSS_COMPILE=$BUILD_CROSS_COMPILE clean
make -j$BUILD_JOB_NUMBER ARCH=$ARCH \
	CROSS_COMPILE=$BUILD_CROSS_COMPILE mrproper
rm -rf $RDIR/arch/arm64/boot/dtb
rm -f $RDIR/arch/$ARCH/boot/dts/*.dtb
rm -f $RDIR/arch/$ARCH/boot/boot.img-dtb
rm -f $RDIR/arch/$ARCH/boot/boot.img-zImage
rm -f $RDIR/alphabet/boot.img
rm -f $RDIR/alphabet/*.zip
rm -f $RDIR/alphabet/$RAMDISKLOC/A720x/image-new.img
rm -f $RDIR/alphabet/$RAMDISKLOC/A720x/ramdisk-new.cpio.gz
rm -f $RDIR/alphabet/$RAMDISKLOC/A720x/split_img/boot.img-dtb
rm -f $RDIR/alphabet/$RAMDISKLOC/A720x/split_img/boot.img-zImage
rm -f $RDIR/alphabet/$RAMDISKLOC/A720x/image-new.img
rm -f $RDIR/alphabet/$ZIPLOC/A720x/*.zip
rm -f $RDIR/alphabet/$ZIPLOC/A720x/*.img
rm -f $RDIR/alphabet/$RAMDISKLOC/A520x/image-new.img
rm -f $RDIR/alphabet/$RAMDISKLOC/A520x/ramdisk-new.cpio.gz
rm -f $RDIR/alphabet/$RAMDISKLOC/A520x/split_img/boot.img-dtb
rm -f $RDIR/alphabet/$RAMDISKLOC/A520x/split_img/boot.img-zImage
rm -f $RDIR/alphabet/$RAMDISKLOC/A520x/image-new.img
rm -f $RDIR/alphabet/$ZIPLOC/A520x/*.zip
rm -f $RDIR/alphabet/$ZIPLOC/A520x/*.img
}

FUNC_BUILD_DTB()
{
[ -f "$DTCTOOL" ] || {
	echo "You need to run ./build.sh first!"
	exit 1
}
case $MODEL in
a5y17lte)
	DTSFILES="exynos7880-a5y17lte_eur_open_00 exynos7880-a5y17lte_eur_open_01
		exynos7880-a5y17lte_eur_open_02 exynos7880-a5y17lte_eur_open_03
		exynos7880-a5y17lte_eur_open_05 exynos7880-a5y17lte_eur_open_07
		exynos7880-a5y17lte_eur_open_08"
	;;
a7y17lte)
	DTSFILES="exynos7880-a7y17lte_eur_open_00 exynos7880-a7y17lte_eur_open_01
		exynos7880-a7y17lte_eur_open_02 exynos7880-a7y17lte_eur_open_03
		exynos7880-a7y17lte_eur_open_04 exynos7880-a7y17lte_eur_open_06"
	;;
*)
	echo "Unknown device: $MODEL"
	exit 1
	;;
esac
mkdir -p $OUTDIR $DTBDIR
cd $DTBDIR || {
	echo "Unable to cd to $DTBDIR!"
	exit 1
}
rm -f ./*
echo "Processing dts files."
for dts in $DTSFILES; do
	echo "=> Processing: ${dts}.dts"
	${CROSS_COMPILE}cpp -nostdinc -undef -x assembler-with-cpp -I "$INCDIR" "$DTSDIR/${dts}.dts" > "${dts}.dts"
	echo "=> Generating: ${dts}.dtb"
	$DTCTOOL -p $DTB_PADDING -i "$DTSDIR" -O dtb -o "${dts}.dtb" "${dts}.dts"
done
echo "Generating dtb.img."
$RDIR/scripts/dtbTool/dtbTool -o "$OUTDIR/dtb.img" -d "$DTBDIR/" -s $PAGE_SIZE
echo "Done."
}

FUNC_BUILD_ZIMAGE()
{
echo ""
make -j$BUILD_JOB_NUMBER ARCH=$ARCH \
	CROSS_COMPILE=$BUILD_CROSS_COMPILE \
	$KERNEL_DEFCONFIG
make -j$BUILD_JOB_NUMBER ARCH=$ARCH \
	CROSS_COMPILE=$BUILD_CROSS_COMPILE
echo ""
}

FUNC_BUILD_RAMDISK()
{
mv $RDIR/arch/$ARCH/boot/Image $RDIR/arch/$ARCH/boot/boot.img-zImage
mv $RDIR/arch/$ARCH/boot/dtb.img $RDIR/arch/$ARCH/boot/boot.img-dtb
case $MODEL in
on7xelte)
	rm -f $RDIR/alphabet/ramdisk/A720x/split_img/boot.img-zImage
	rm -f $RDIR/alphabet/ramdisk/A720x/split_img/boot.img-dtb
	mv -f $RDIR/arch/$ARCH/boot/boot.img-zImage $RDIR/alphabet/ramdisk/A720x/split_img/boot.img-zImage
	mv -f $RDIR/arch/$ARCH/boot/boot.img-dtb $RDIR/alphabet/ramdisk/A720x/split_img/boot.img-dtb
	cd $RDIR/alphabet/ramdisk/A720x
	./repackimg.sh
	echo SEANDROIDENFORCE >> image-new.img
	;;
j7xelte)
	rm -f $RDIR/alphabet/ramdisk/A520x/split_img/boot.img-zImage
	rm -f $RDIR/alphabet/ramdisk/A520x/split_img/boot.img-dtb
	mv -f $RDIR/arch/$ARCH/boot/boot.img-zImage $RDIR/alphabet/ramdisk/A520x/split_img/boot.img-zImage
	mv -f $RDIR/arch/$ARCH/boot/boot.img-dtb $RDIR/alphabet/ramdisk/A520x/split_img/boot.img-dtb
	cd $RDIR/alphabet/ramdisk/A520x
	./repackimg.sh
	echo SEANDROIDENFORCE >> image-new.img
	;;
*)
	echo "Unknown device: $MODEL"
	exit 1
	;;
esac
}

FUNC_BUILD_BOOTIMG()
{
	(
	FUNC_BUILD_ZIMAGE
	FUNC_BUILD_DTB
	FUNC_BUILD_RAMDISK
	) 2>&1	 | tee -a alphabet/build.log
}
FUNC_BUILD_ZIP()
{
echo ""
echo "Building Zip File"
cd $ZIP_FILE_DIR
zip -gq $ZIP_NAME -r * -x "*~"
chmod a+r $ZIP_NAME
mv -f $ZIP_FILE_TARGET $RDIR/alphabet/$ZIP_NAME
cd $RDIR
}


OPTION_1()
{
MODEL=a7y17lte
KERNEL_DEFCONFIG=Alphabet_Kernel_a7y17lte_defconfig
VERSION_NUMBER=$(<alphabet/A720x)
FUNC_BUILD_BOOTIMG
mv -f $RDIR/alphabet/ramdisk/A720x/image-new.img $RDIR/alphabet/$ZIPLOC/A720x/boot.img
ZIP_FILE_DIR=$RDIR/alphabet/$ZIPLOC/A720x
ZIP_NAME=alphabet.A720x.v$VERSION_NUMBER.zip
ZIP_FILE_TARGET=$ZIP_FILE_DIR/$ZIP_NAME
FUNC_BUILD_ZIP
echo ""
echo "Build Successful"
echo ""
}

OPTION_2()
{
MODEL=a5y17lte
KERNEL_DEFCONFIG=Alphabet_Kernel_a5y17lte_defconfig
VERSION_NUMBER=$(<alphabet/A520x)
FUNC_BUILD_BOOTIMG
mv -f $RDIR/alphabet/ramdisk/A520x/image-new.img $RDIR/alphabet/$ZIPLOC/A520x/boot.img
ZIP_FILE_DIR=$RDIR/alphabet/$ZIPLOC/A520x
ZIP_NAME=alphabet.A520x.v$VERSION_NUMBER.zip
ZIP_FILE_TARGET=$ZIP_FILE_DIR/$ZIP_NAME
FUNC_BUILD_ZIP
echo ""
echo "Build Successful"
echo ""
}

OPTION_0()
{
echo "Cleaning Workspace"
FUNC_CLEAN
}

if [ $1 == 0 ]; then
	OPTION_0
fi
if [ $1 == 1 ]; then
	OPTION_1
fi
if [ $1 == 2 ]; then
	OPTION_2
fi

# Program Start
rm -rf alphabet/build.log
clear
echo "Alphabet Build file"
echo ""
echo "0) Clean Workspace"
echo ""
echo "1) Build alphabet_Kernel for A7 2017"
echo ""
echo "2) Build alphabet_Kernel for A5 2017"
echo ""
read -p "Please select an option: " prompt
echo ""
if [ $prompt == "0" ]; then
	OPTION_0
	echo ""
	echo ""
	echo ""
	echo ""
	. build.sh
elif [ $prompt == "1" ]; then
	OPTION_1
	echo ""
	echo ""
	echo ""
	echo ""
elif [ $prompt == "2" ]; then
	OPTION_2
	echo ""
	echo ""
	echo ""
	echo ""
fi
