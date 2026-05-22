#! /bin/bash

# A noddy script to automate production of universal binaries on OS X.

# This is seriously ugly, but so is pretty much any sort of
# compilation on OS X; all the framework nonsense is too far removed
# from traditional Unixes for command-line tools to work easily, but
# Xcode is an abomination before God and men -- so bad, indeed, that
# even this hacky mess is preferable to trying to set up and maintain
# an Xcode project to do this stuff.

restart=true
if [ "$1" == "continue" ]
then
    shift
    restart=false
fi

if $restart
then
    rm -f shioriscr.ppc shioriscr.intel shioriscr
    make distclean &>/dev/null
fi

if [ ! -f shioriscr.ppc ]
then
    export LDFLAGS="-Wl,-syslibroot,/Developer/SDKs/MacOSX10.3.9.sdk"
    export CC="gcc -arch ppc -isysroot /Developer/SDKs/MacOSX10.3.9.sdk -Wl,-framework,OpenGL"
    export CXX="g++ -arch ppc -isysroot /Developer/SDKs/MacOSX10.3.9.sdk -Wl,-framework,OpenGL"
    $restart && ./configure --with-internal-libs
    restart=true
    make \
     SDLOTHERCONFIG='--host=powerpc-apple-darwin --without-x --disable-video-x11' \
	OTHERCONFIG='--host=powerpc-apple-darwin' \
	"$@" \
        2> >(grep -E -v 'linker input file unused|ranlib.*no symbols$' >&2) \
        || exit
    mv shioriscr shioriscr.ppc
    make distclean &>/dev/null
fi

if [ ! -f shioriscr.intel ]
then
    export LDFLAGS="-Wl,-syslibroot,/Developer/SDKs/MacOSX10.4u.sdk"
    export CC="gcc -arch i386 -isysroot /Developer/SDKs/MacOSX10.4u.sdk -Wl,-framework,OpenGL"
    export CXX="g++ -arch i386 -isysroot /Developer/SDKs/MacOSX10.4u.sdk -Wl,-framework,OpenGL"
    $restart && ./configure --with-internal-libs
    make \
     SDLOTHERCONFIG='--host=i386-apple-darwin --without-x --disable-video-x11' \
	OTHERCONFIG='--host=i386-apple-darwin' \
	"$@" \
        2> >(grep -E -v 'linker input file unused|ranlib.*no symbols$' >&2) \
        || exit
    mv shioriscr shioriscr.intel
fi

lipo -create \
     -arch ppc shioriscr.ppc \
     -arch i386 shioriscr.intel \
     -output shioriscr
