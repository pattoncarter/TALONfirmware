#!/bin/bash

set -e

source bin/version.sh

# COUNTRIES="US EU CN JP"
COUNTRIES=US

SRCMAP=.pio/build/esp32/output.map
SRCBIN=.pio/build/esp32/firmware.bin
OUTDIR=release/latest

# We keep all old builds (and their map files in the archive dir)
ARCHIVEDIR=release/archive 

rm -f $OUTDIR/firmware*

for COUNTRY in $COUNTRIES; do 

    HWVERSTR="1.0-$COUNTRY"
    COMMONOPTS="-DAPP_VERSION=$VERSION -DHW_VERSION_$COUNTRY -DHW_VERSION=$HWVERSTR -Wall -Wextra -Wno-missing-field-initializers -Isrc -Os -Wl,-Map,.pio/build/esp32/output.map -DAXP_DEBUG_PORT=Serial"

    export PLATFORMIO_BUILD_FLAGS="-DT_BEAM_V10 $COMMONOPTS"
    echo "Building with $PLATFORMIO_BUILD_FLAGS"
    rm -f $SRCBIN $SRCMAP
    pio run # -v
    cp $SRCBIN $OUTDIR/firmware-TBEAM-$COUNTRY-$VERSION.bin
    cp $SRCMAP $ARCHIVEDIR/firmware-TBEAM-$COUNTRY-$VERSION.map

    export PLATFORMIO_BUILD_FLAGS="-DHELTEC_LORA32 $COMMONOPTS"
    rm -f $SRCBIN $SRCMAP
    pio run # -v
    cp $SRCBIN $OUTDIR/firmware-HELTEC-$COUNTRY-$VERSION.bin
    cp $SRCMAP $ARCHIVEDIR/firmware-HELTEC-$COUNTRY-$VERSION.map
done

# keep the bins in archive also
cp $OUTDIR/firmware* $ARCHIVEDIR

zip $ARCHIVEDIR/firmware-$VERSION.zip $OUTDIR/firmware-*-$VERSION.bin

echo BUILT ALL