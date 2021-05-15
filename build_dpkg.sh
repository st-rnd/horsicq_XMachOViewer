#!/bin/bash -x

RELEASE_VERSION=$(cat "release_version.txt")
ARCHITECTURE=$(uname -m)
REVISION=$(date "+%Y%m%d")
echo $RELEASE_VERSION
SOURCE_PATH=$PWD

if [[ $ARCHITECTURE == *"x86_64"* ]]; then
    ARCHITECTURE="amd64"
fi

BUILD_NAME=die_${RELEASE_VERSION}-${REVISION}_${ARCHITECTURE}

cd $SOURCE_PATH

function makeproject
{
    cd $SOURCE_PATH/$1
    
    qmake $1.pro -spec linux-g++
    make -f Makefile clean
    make -f Makefile

    rm -rf Makefile
    rm -rf Makefile.Release
    rm -rf Makefile.Debug
    rm -rf object_script.*     

    cd $SOURCE_PATH
}

rm -rf $SOURCE_PATH/build

makeproject build_libs
makeproject gui_source

cd $SOURCE_PATH/gui_source
lupdate gui_source_tr.pro
lrelease gui_source_tr.pro
cd $SOURCE_PATH

mkdir -p $SOURCE_PATH/release
rm -rf $SOURCE_PATH/release/$BUILD_NAME
mkdir -p $SOURCE_PATH/release/$BUILD_NAME
mkdir -p $SOURCE_PATH/release/$BUILD_NAME/DEBIAN
mkdir -p $SOURCE_PATH/release/$BUILD_NAME/usr
mkdir -p $SOURCE_PATH/release/$BUILD_NAME/usr/bin
mkdir -p $SOURCE_PATH/release/$BUILD_NAME/usr/lib
mkdir -p $SOURCE_PATH/release/$BUILD_NAME/usr/lib/xmachoviewer
mkdir -p $SOURCE_PATH/release/$BUILD_NAME/usr/lib/xmachoviewer/lang
mkdir -p $SOURCE_PATH/release/$BUILD_NAME/usr/lib/xmachoviewer/signatures
mkdir -p $SOURCE_PATH/release/$BUILD_NAME/usr/share
mkdir -p $SOURCE_PATH/release/$BUILD_NAME/usr/share/applications
mkdir -p $SOURCE_PATH/release/$BUILD_NAME/usr/share/icons

cp -f $SOURCE_PATH/build/release/xmachoviewer                     		$SOURCE_PATH/release/$BUILD_NAME/usr/bin/

cp -f $SOURCE_PATH/DEBIAN/control                     		            $SOURCE_PATH/release/$BUILD_NAME/DEBIAN/
cp -f $SOURCE_PATH/DEBIAN/xmachoviewer.desktop                     	    $SOURCE_PATH/release/$BUILD_NAME/usr/share/applications/
cp -f $SOURCE_PATH/LICENSE                     		                    $SOURCE_PATH/release/$BUILD_NAME/
cp -Rf $SOURCE_PATH/XStyles/qss/                                        $SOURCE_PATH/release/$BUILD_NAME/usr/lib/xmachoviewer/

cp -Rf $SOURCE_PATH/DEBIAN/hicolor/ $SOURCE_PATH/release/$BUILD_NAME/usr/share/icons/

mv $SOURCE_PATH/gui_source/translation/*.qm  $SOURCE_PATH/release/$BUILD_NAME/base/lang/

cp -f $SOURCE_PATH/signatures/crypto.db                     		$SOURCE_PATH/release/$BUILD_NAME/usr/lib/xmachoviewer/signatures/

dpkg -b $SOURCE_PATH/release/$BUILD_NAME
rm -rf $SOURCE_PATH/release/$BUILD_NAME
