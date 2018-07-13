#!/bin/bash -ex

PINBA_ENGINE_COMMIT=99ca84d4b6ad77301533e3eb19dea1282f60d456

echo "deb-src http://repo.mysql.com/apt/debian/ stretch mysql-5.7" >> /etc/apt/sources.list.d/mysql.list

apt-get update

apt-get install -y \
    libjudydebian1 \
    libprotobuf10 \
    libprotobuf-lite10 \
    libevent-2.0-5 \
    libevent-core-2.0-5 \
    libevent-extra-2.0-5 \
    libevent-openssl-2.0-5 \
    libevent-pthreads-2.0-5

apt-get install -y aptitude

aptitude build-dep -y mysql-server --add-user-tag 'mysql-depends'

DEPENDENCY_PACKAGES="cmake dpkg-dev libncurses5-dev lsb-release wget libjudy-dev libprotobuf-dev libevent-dev automake make libtool libtool-bin g++"
apt-get install -y $DEPENDENCY_PACKAGES

mkdir mysql-source
pushd mysql-source
apt-get source -y mysql-server
pushd `find . -maxdepth 1 -type d | grep "mysql-community" | head -n1`

MYSQL_SOURCE_PATH="`pwd`"

touch testsuite-stamp
cmake . -DWITH_BOOST=/mysql-source/boost -DDOWNLOAD_BOOST=1 -DBUILD_CONFIG=mysql_release
make -j8

#pushd include
#
#make
#
#popd

popd
popd

mkdir pinba-engine
pushd pinba-engine

wget --progress=dot:mega https://github.com/tony2001/pinba_engine/archive/${PINBA_ENGINE_COMMIT}.tar.gz -O pinba-engine.tar.gz
tar xzf pinba-engine.tar.gz

pushd pinba_engine-${PINBA_ENGINE_COMMIT}

patch -p1 < /opt/mysql-5.7.patch

./buildconf.sh
./configure \
--with-mysql=${MYSQL_SOURCE_PATH} \
--libdir=/usr/lib/mysql/plugin

make install

popd
popd

rm -rf /mysql-source
rm -rf /pinba-engine

aptitude purge -y '?user-tag(mysql-depends)'

apt-get purge -y aptitude

apt-get purge -y $DEPENDENCY_PACKAGES
apt-get clean

apt-get autoremove -y

rm -rf /var/lib/apt/lists/*
