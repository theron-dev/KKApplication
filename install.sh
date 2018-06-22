#!/bin/sh

HOME=`pwd`

cmd() {
    echo "\033[0;1m$1\033[m"
    $1
}

clone(){
    
    PROJ=$1
    TAG=$2

    if [ -d $PROJ ] ; then
        cmd "cd $PROJ"
        cmd "git checkout $TAG"
        cmd "git pull"
        cmd "cd .."
    else
        cmd "git clone https://github.com/hailongz/$PROJ.git"
        cmd "cd $PROJ"
        cmd "git checkout $TAG"
        cmd "cd .."
    fi

}

build() {

    PROJ=$1
    DIR=$2

    if [ ! $DIR ]; then
        DIR=$PROJ
    fi

    SRCROOT=$HOME/${DIR}/${PROJ}

    cmd "cd $SRCROOT"
    
    FMK_NAME=${PROJ}

    INSTALL_DIR=${SRCROOT}/../${FMK_NAME}.framework

    WRK_DIR=build

    DEVICE_DIR=${WRK_DIR}/Release-iphoneos/${FMK_NAME}.framework

    SIMULATOR_DIR=${WRK_DIR}/Release-iphonesimulator/${FMK_NAME}.framework

    xcodebuild -configuration "Release" -target "${FMK_NAME}" -sdk iphoneos clean build

    xcodebuild -configuration "Release" -target "${FMK_NAME}" -sdk iphonesimulator clean build

    if [ -d "${INSTALL_DIR}" ]

    then

    rm -rf "${INSTALL_DIR}"

    fi

    mkdir -p "${INSTALL_DIR}"

    cp -R "${DEVICE_DIR}/" "${INSTALL_DIR}/"

    lipo -create "${DEVICE_DIR}/${FMK_NAME}" "${SIMULATOR_DIR}/${FMK_NAME}" -output "${INSTALL_DIR}/${FMK_NAME}"

    rm -r "${WRK_DIR}"

    cmd "cd $HOME"

}

framework() {
    
    PROJ=$1
    OUT=$2
    DIR=$3

    if [ ! $DIR ]; then
        DIR=$PROJ
    fi

    if [ ! -d $OUT ]; then
        cmd "mkdir $OUT"
    fi

    rm -rf $OUT/${PROJ}.framework
    cp -r ${DIR}/${PROJ}.framework $OUT/${PROJ}.framework

}

clone KKApplication master
clone KKView master
clone KKHttp master
clone KKObserver master
clone KKWebSocket master
clone KKStorage master
clone kk-game master

build KKHttp
framework KKHttp bin
framework KKHttp KKView/libs
framework KKHttp KKApplication/libs
framework KKHttp kk-game/lib

build KKObserver
framework KKObserver bin
framework KKObserver KKView/libs
framework KKObserver KKApplication/libs
framework KKObserver kk-game/lib

build KKView
framework KKView bin
framework KKView KKApplication/libs
framework KKView kk-game/lib

build KKWebSocket
framework KKWebSocket bin
framework KKWebSocket KKApplication/libs
framework KKWebSocket kk-game/lib

build KKStorage
framework KKStorage bin

build KKApplication
framework KKApplication bin
framework KKApplication kk-game/lib

build KKGame kk-game 
framework KKGame bin kk-game
