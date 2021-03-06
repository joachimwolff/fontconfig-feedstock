#!/bin/bash


if [[ `uname` == 'Darwin' ]];
then
    export LIBRARY_SEARCH_VAR=DYLD_FALLBACK_LIBRARY_PATH
elif [[ `uname` == 'Linux' ]];
then
    export LIBRARY_SEARCH_VAR=LD_LIBRARY_PATH
fi

sed -i.orig s:'@PREFIX@':"${PREFIX}":g src/fccfg.c

chmod +x configure

./configure --prefix "${PREFIX}" \
	    --enable-libxml2 \
	    --enable-static \
	    --disable-docs

make
eval ${LIBRARY_SEARCH_VAR}="${PREFIX}/lib" make check
eval ${LIBRARY_SEARCH_VAR}="${PREFIX}/lib" make install

# Remove computed cache with local fonts
rm -Rf "${PREFIX}/var/cache/fontconfig"

# Leave cache directory, in case it's needed
mkdir -p "${PREFIX}/var/cache/fontconfig"
touch "${PREFIX}/var/cache/fontconfig/.leave"

#Add FONTCONFIG_PATH and FONTCONFIG_FILE to the enviroment variables
ACTIVATE_DIR=$PREFIX/etc/conda/activate.d
DEACTIVATE_DIR=$PREFIX/etc/conda/deactivate.d
mkdir -p $ACTIVATE_DIR
mkdir -p $DEACTIVATE_DIR

cp $RECIPE_DIR/scripts/activate.sh $ACTIVATE_DIR/fontconfig-activate.sh
cp $RECIPE_DIR/scripts/deactivate.sh $DEACTIVATE_DIR/fontconfig-deactivate.sh