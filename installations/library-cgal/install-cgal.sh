#!/bin/sh
#
# Installed packages:
# 	-) boost:
#		* libicu-devel.x86_64
#	-) cgal:
#		* cmake.x86_64  (xmlrpc-c.x86_64, xmlrpc-c-client.x86_64) 
#		* lapack-devel.x86_64
#
DIR=/vosoft/plgrid/lib/cgal
LOGS=$DIR/logs/
CFLAGS=""
LFLAGS=""
BOOSTINCLUDES=""
LD_LIBRARY_PATH="."

mkdir --mode=700 $LOGS
cd $DIR/download

# zlib
#ZLIBDIR=$DIR/zlib-1.2.7
#if [ ! -e "$ZLIBDIR" ]
#then
#	tar jxvfp zlib-1.2.7.tar.bz2
#	cd zlib-1.2.7
#	( CC=/usr/bin/gcc44 CXX=/usr/bin/g++44 ./configure --prefix=$ZLIBDIR --64 ) 2>&1 | tee $LOGS/configure-zlib.log
#	( CC=/usr/bin/gcc44 CXX=/usr/bin/g++44 make ) 2>&1 | tee $LOGS/make-zlib.log 
#	CC=/usr/bin/gcc44 CXX=/usr/bin/g++44 make install
#	cd -
#fi
#
#CFLAGS="$CFLAGS -I $ZLIBDIR/include"
#LFLAGS="$LFLAGS -L $ZLIBDIR/lib"
#BOOSTINCLUDES="$BOOSTINCLUDES include=$ZLIBDIR/include"
#export LD_LIBRARY_PATH=$ZLIBDIR/lib:$LD_LIBRARY_PATH


# gmp
GMPDIR=$DIR/gmp-5.0.5
if [ ! -e "$GMPDIR" ]
then
	tar jxvfp gmp-5.0.5.tar.bz2
	cd gmp-5.0.5
	( CC=/usr/bin/gcc44 CXX=/usr/bin/g++44 ./configure --prefix=$GMPDIR ) 2>&1 | tee $LOGS/configure-gmp.log
	( CC=/usr/bin/gcc44 CXX=/usr/bin/g++44 make ) 2>&1 | tee $LOGS/make-gmp.log
	CC=/usr/bin/gcc44 CXX=/usr/bin/g++44 make install
	cd -
fi

CFLAGS="$CFLAGS -I $GMPDIR/include"
LFLAGS="$LFLAGS -L $GMPDIR/lib"
BOOSTINCLUDES="$BOOSTINCLUDES include=$GMPDIR/include"
export LD_LIBRARY_PATH=$GMPDIR/lib:$LD_LIBRARY_PATH


# mpfr
export OBJECT_MODE=64
MPFRDIR=$DIR/mpfr-3.1.1
if [ ! -e "$MPFRDIR" ]
then
	tar jxvfp mpfr-3.1.1.tar.bz2
	cd mpfr-3.1.1
	( CC=/usr/bin/gcc44 ./configure --with-gmp=$GMPDIR --prefix=$MPFRDIR ) 2>&1 | tee $LOGS/configure-mpfr.log
	( CC=/usr/bin/gcc44 make ) 2>&1 | tee $LOGS/make-mpfr.log
	CC=/usr/bin/gcc44 make install
	cd -
fi

CFLAGS="$CFLAGS -I $MPFRDIR/include"
LFLAGS="$LFLAGS -L $MPFRDIR/lib"
BOOSTINCLUDES="$BOOSTINCLUDES include=$MPFRDIR/include"
export LD_LIBRARY_PATH=$MPFRDIR/lib:$LD_LIBRARY_PATH


# python
source /etc/profile.d/modules.sh
module load python/2.7.2
#
# if there will be needed some installation use those steps:
#
#$ wget http://www.python.org/ftp/python/2.7.3/Python-2.7.3.tar.bz2
#$ tar jxfp Python-2.7.3.tar.bz2
#$ cd Python-2.7.3
#$ ./configure --prefix=/opt/apps/lib-cgal/python-2.7.3
#$ make && make install
#

PYTHONHOME=/vosoft/plgrid/python/python-2.7.2
CFLAGS="$CFLAGS -I $PYTHONHOME/include"
LFLAGS="$LFLAGS -L $PYTHONHOME/lib"
BOOSTINCLUDES="$BOOSTINCLUDES include=$PYTHONHOME/include"
export LD_LIBRARY_PATH=$PYTHONHOME/lib:$LD_LIBRARY_PATH


# openmpi
module load openmpi/1.6.1
OMPIDIR=/vosoft/plgrid/openmpi/openmpi-1.6.1

CFLAGS="$CFLAGS -I $OMPIDIR/include"
LFLAGS="$LFLAGS -L $OMPIDIR/lib"
BOOSTINCLUDES="$BOOSTINCLUDES include=$OMPIDIR/include"
export LD_LIBRARY_PATH=$OMPIDIR/lib:$LD_LIBRARY_PATH


# boost
BOOST_ROOT=$DIR/boost-1.52.0
#export C_INCLUDE_PATH=...
#export LIBRARY_PATH=...
if [ ! -e "$BOOST_ROOT" ]
then
	tar jxvfp boost_1_52_0.tar.bz2
	cd boost_1_52_0
	# http://stackoverflow.com/questions/5346454/building-boost-with-different-gcc-version:
	echo "using gcc : 4.4 : /usr/bin/g++44 ;" >> ./tools/build/v2/user-config.jam
	echo "using mpi ;" >> ./tools/build/v2/user-config.jam
	#
	( ./bootstrap.sh --with-python=$PYTHONHOME/bin/python2.7 --prefix=$BOOST_ROOT ) 2>&1 | tee $LOGS/bootstrap-boost.log
	#( ./b2 -q -d+2 toolset=gcc-4.4 install ) 2>&1 | tee $LOGS/b2-boost.log
	( ./b2 -q toolset=gcc-4.4 $BOOSTINCLUDES linkflags="$LFLAGS" install ) 2>&1 | tee $LOGS/b2-boost.log
	cd -
fi

CFLAGS="$CFLAGS -I $BOOST_ROOT/include"
LFLAGS="$LFLAGS -L $BOOST_ROOT/lib"
export LD_LIBRARY_PATH=$BOOST_ROOT/lib:$LD_LIBRARY_PATH


# cgal 4.1: https://gforge.inria.fr/frs/download.php/31641/CGAL-4.1.tar.gz
CGAL_DIR=$DIR/cgal-4.1
if [ ! -e "$CGAL_DIR" ]
then
        tar zxvfp CGAL-4.1.tar.gz
        cd CGAL-4.1
	# set env. variables for gmp and mpfr:
	#export GMP_INC_DIR=$GMPDIR/include
	#export GMP_LIB_DIR=$GMPDIR/lib
	#export MPFR_INC_DIR=$MPFRDIR/include
	#export MPFR_LIB_DIR=$MPFRDIR/lib
	#
	( cmake -DCMAKE_INSTALL_PREFIX=$CGAL_DIR \
		-DWITH_examples=ON -DWITH_demos=OFF \
		-DWITH_CGAL_Core=ON -DWITH_CGAL_ImageIO=ON -DWITH_CGAL_Qt3=OFF -DWITH_CGAL_Qt4=OFF \
		-DCGAL_CXX_FLAGS="$CFLAGS" -DCGAL_MODULE_LINKER_FLAGS="$LFLAGS" \
		-DCGAL_SHARED_LINKER_FLAGS="$LFLAGS" -DCGAL_EXE_LINKER_FLAGS="$LFLAGS" \
		-DCMAKE_BUILD_TYPE=Release \
		-DCMAKE_C_COMPILER="/usr/bin/gcc44" -DCMAKE_CXX_COMPILER="/usr/bin/g++44" \
		-DBOOST_ROOT=$BOOST_ROOT \
		-DWITH_GMP=TRUE \
		-DGMP_INCLUDE_DIR=$GMPDIR/include -DMPFR_INCLUDE_DIR=$MPFRDIR/include \
		-DGMP_LIBRARIES=$GMPDIR/lib/libgmp.so -DMPFR_LIBRARIES=$MPFRDIR/lib/libmpfr.so \
	  . \
	) 2>&1 | tee $LOGS/cmake-cgal.log
#		-DCGAL_DONT_OVERRIDE_CMAKE_FLAGS=TRUE \
	#
	( make ) 2>&1 | tee $LOGS/make-cgal.log
	make install
        cd -
fi

CFLAGS="$CFLAGS -I $CGAL_DIR/include"
LFLAGS="$LFLAGS -L $CGAL_DIR/lib"
export LD_LIBRARY_PATH=$CGAL_DIR/lib:$LD_LIBRARY_PATH


# done
echo "[ DONE ]"
echo "CFLAGS = '$CFLAGS'" | tee $LOGS/cflags.log
echo "LFLAGS = '$LFLAGS'" | tee $LOGS/lflags.log
export LD_RUN_PATH=$LD_LIBRARY_PATH

