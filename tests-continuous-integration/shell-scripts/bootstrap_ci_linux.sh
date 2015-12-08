#!/bin/bash

set -u

dohelp ()
{
    echo ""
    echo "WARNING: DO NOT CALL THIS SCRIPT DIRECTLY. IT IS USED"
    echo "BY VAGRANT TO PROVISION VMs."
    echo ""
    echo "Usage: $0 [options]"
    echo -e "Options"
    echo -e "\t-h           This Documentation."
    echo -e "\t-l [distro]  Linux Distribution."
    echo -e "\t               o ubuntu"
    echo -e "\t               o centos"
    echo -e "\t               o debian"
    echo -e "\t               o fedora"
    echo -e "\t               o sl (scientific linux)"
    echo -e "\t-p [type]    Parallel Processing Type"
    echo -e "\t               o openmpi"
    echo -e "\t               o mpich"
    echo -e "\t               o pnet"
    echo -e "\t-n [name]    Set hostname with hostnamectl"
    echo -e "\t               Used when Vagrant doesn't set hostname properly."
    echo -e "\t-a [ver]     Alternate HDF5 Version"
    echo -e "\t-d           Use a local Dashboard instead of remote."
    echo -e "\t-c           Enable Night Test Cron Job"
    echo ""
}

if [ $# -eq 0 ]; then
    dohelp
    exit 1
fi

LINTYPE=""
PARTYPE=""
ISPAR=""
DOCRON=""
CIFILE="CI.cmake"
FCIFILE="FCI.cmake"
LOCALDASH=""
HNAME=""
####
# Parse options, validate
# arguments.
####

while getopts "l:p:ca:dn:" o; do
    case "${o}" in
        l)
            LINTYPE=${OPTARG}
            ;;
        p)
            PARTYPE=${OPTARG}
            ISPAR="TRUE"
            CIFILE="PARCI.cmake"
            if [ "$PARTYPE" = "pnet" ]; then
                # This will need to be changed
                # once I figure out how to change it.
                #CIFILE="CI.cmake"
                X="x"
            fi
            ;;
        c)
            DOCRON="TRUE"
            ;;
        a)
            HDF5VER=${OPTARG}
            ;;
        d)
            LOCALDASH="TRUE"
            ;;
        n)
            HNAME=${OPTARG}
            ;;
        *)
            dohelp
            exit 0
    esac
done

# Validate linux types, do any distro-specific config
case ${LINTYPE} in
    ubuntu)
        ;;
    centos)
        ;;
    sl)
        ;;
    debian)
        ;;
    fedora)
        sed -i 's/^Defaults    requiretty/# Defaults requiretty/g' /etc/sudoers
        ;;
    *)
        echo "Error: Unknown linux type."
        dohelp
        exit 1
esac

if [ "x$ISPAR" = "xTRUE" ]; then
    case ${PARTYPE} in
        mpich)
            ;;
        openmpi)
            ;;
        pnet)
            ;;
        *)
            echo "Error: Unknown parallel API type."
            dohelp
            exit 1
    esac
fi

#####
# Set up package list, based on underlying linux type.
#####

###
# Ubuntu, Debian Linux
###
if [ "$LINTYPE" = "ubuntu" ] || [ "$LINTYPE" = "debian" ]; then
    USE_APT="TRUE"
    PKG_CMD=`which apt-get`
    PKG_UPDATE="$PKG_CMD update"
    GRP_LIST=""

    PKG_LIST="ubuntu-dev-tools m4 git libjpeg-dev libcurl4-openssl-dev wget htop libtool bison flex autoconf curl g++ midori emacs valgrind gfortran zlib1g-dev zip"

    if [ "x$ISPAR" = "xTRUE" ]; then
        case ${PARTYPE} in
            mpich)
                PKG_LIST="$PKG_LIST mpich libmpich-dev"
                ;;
            openmpi)
                PKG_LIST="$PKG_LIST libopenmpi-dev openmpi-bin"
                ;;
            *)
                ;;
        esac
    fi

    $PKG_CMD update

    ##
    # For some OS's, we can't currently
    # do a 'yes-to-everything' upgrade. Looking at you,
    # ubuntu 15.04.  So, we must do this by hand and
    # export a new image.  In this event, we create a
    # file lock and, where present, don't perform an
    # upgrade.
    #
    ##
    if [ ! -e "/vagrant/lock.upgrade" ]; then
        $PKG_CMD -y upgrade
    fi

    $PKG_CMD -y install $PKG_LIST

fi

###
# Fedora (which has migrated to dnf)
###

if [ "$LINTYPE" = "fedora" ]; then

    PKG_UPDATE=""
    USE_PROFILED="TRUE"
    PKG_CMD=""
    ##
    # Install dnf if it's not available.
    ##
    if [ ! -f /usr/bin/dnf ]; then
        yum -y update
        yum -y install dnf
    fi

    ##
    # Fall back to yum if dnf didn't install.
    ##
    if [ -f /usr/bin/dnf ]; then
        PKG_CMD=`which dnf`
    elif [ -f /usr/bin/yum ]; then
        PKG_CMD=`which yum`
    fi

    PKG_LIST="m4 git libjpeg-turbo-devel libcurl-devel wget nano libtool bison flex autoconf curl zlib-devel zip gcc-gfortran gcc-c++ gcc byacc crontabs"
    if [ "x$ISPAR" = "xTRUE" ]; then
        case ${PARTYPE} in
            mpich)
                PKG_LIST="$PKG_LIST mpich2-devel"
                ;;
            openmpi)
                PKG_LIST="$PKG_LIST openmpi-devel"
                ;;
            *)
                ;;
        esac
    fi

    $PKG_CMD -y update
    $PKG_CMD -y install $PKG_LIST

fi

###
# Centos
###
USE_PROFILED=""
if [ "$LINTYPE" = "centos" ] || [ "$LINTYPE" = "sl" ]; then
    PKG_UPDATE=""
    USE_PROFILED="TRUE"
    PKG_CMD=`which yum`
    GRP_LIST="yum -y groupinstall Development tools"
    YM_FORTRAN="gfortran"

    PKG_LIST="m4 git libjpeg-turbo-devel libcurl-devel wget nano libtool bison flex autoconf curl zlib-devel zip $YM_FORTRAN"
    if [ "x$ISPAR" = "xTRUE" ]; then
        case ${PARTYPE} in
            mpich)
                PKG_LIST="$PKG_LIST mpich2-devel"
                ;;
            openmpi)
                PKG_LIST="$PKG_LIST openmpi-devel"
                ;;
            *)
                ;;
        esac
    fi

    $PKG_CMD -y update
    $PKG_CMD -y install $PKG_LIST
    bash -c "$GRP_LIST"
fi

###
# Centos systems require an entry in
# /etc/profile.d/ to set ld_library_path.
###
if [ "x$USE_PROFILED" = "xTRUE" ]; then

    PDFILE="/etc/profile.d/ldlibpath.sh"
    if [ ! -f "$PDFILE" ]; then
        echo '# ld_library_path init script' > $PDFILE
        echo 'export LD_LIBRARY_PATH=/usr/lib:$LD_LIBRARY_PATH' >> $PDFILE
        echo 'export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH' >> $PDFILE
    fi

fi

#####
# Enable Cron to run automatically.
#####

CRONLOCKFILE="/home/vagrant/.cronlock"

if [ ! -f "$CRONLOCKFILE" ]; then
    if [ `which update-rc.d | wc -w` -gt 0 ]; then
        update-rc.d crond defaults
    elif [ `which chkconfig | wc -w` -gt 0 ]; then
        chkconfig crond on
    fi
fi


#####
# If the option was passed, set
# the hostname explicitely using
# hostnamectl.  This is here in case
# Vagrant has problems setting the hostname.
#
# See https://github.com/mitchellh/vagrant/issues/2745.
#####
if [ "x$HNAME" != "x" ]; then
    hostnamectl set-hostname $HNAME
fi

#####
# Set the proper timezone.
#####

if [ -f "/usr/sbin/dpkg-reconfigure" ]; then
    echo "US/Mountain" | tee /etc/timezone
    dpkg-reconfigure --frontend noninteractive tzdata
elif [ -f /usr/share/zoneinfo/America/Denver ]; then
    mv /etc/localtime /etc/localtime.bak
    ln -s /usr/share/zoneinfo/America/Denver /etc/localtime
fi

#####
# Install ctest as a script.
# It is installed into /etc/init.d/ctest
#
# If we are doing local CI, use the local scripts.
#####

CTEST_INIT="/home/vagrant/ctest_service.sh"
if [ "x$LOCALDASH" = "xTRUE" ]; then
    if [ "x$ISPAR" = "xTRUE" ]; then
        cp /vagrant/local.ctest_service.sh.parallel $CTEST_INIT
    else
        cp /vagrant/local.ctest_service.sh.serial $CTEST_INIT
    fi
else
    if [ "x$ISPAR" = "xTRUE" ]; then
        cp /vagrant/ctest_service.sh.parallel $CTEST_INIT
    else
        cp /vagrant/ctest_service.sh.serial $CTEST_INIT
    fi
fi


chmod 755 $CTEST_INIT


####
# End installation of ctest as a script.
# Note: We can't start it yet, ctest and hdf libraries
# haven't been installed yet.
####

if [ "x$DOCRON" = "xTRUE" ]; then
    if [ ! -f $CRONLOCKFILE ]; then

       ### Set the LD_LIBRARY_PATH
        sudo -i -u vagrant echo "" > /home/vagrant/crontab.in
        sudo -i -u vagrant echo 'CRON_TZ="America/Denver"' >> /home/vagrant/crontab.in
        sudo -i -u vagrant echo 'LD_LIBRARY_PATH=/usr/lib:/usr/local/lib:/home/vagrant/local2' >> /home/vagrant/crontab.in
        sudo -i -u vagrant echo "" >> /home/vagrant/crontab.in

        ### Install a crontab for running nightly tests.
        sudo -i -u vagrant echo "@reboot $CTEST_INIT" >> /home/vagrant/crontab.in
         # If it's a parallel build, we have to pass 'par' to the nightly test script.
        if [ "x$ISPAR" = "xTRUE" ]; then
            sudo -i -u vagrant echo '01 3 * * * cd /home/vagrant/ctest_scripts && /home/vagrant/ctest_scripts/run_nightly_test.sh -p -l netcdf-c > nightly_log_c.txt' >> /home/vagrant/crontab.in
            sudo -i -u vagrant echo '01 4  * * * cd /home/vagrant/ctest_scripts && /home/vagrant/ctest_scripts/run_nightly_test.sh -p -l netcdf-fortran > nightly_log_fortran.txt' >> /home/vagrant/crontab.in
            sudo -i -u vagrant echo '01 5 * * * cd /home/vagrant/ctest_scripts && /home/vagrant/ctest_scripts/run_nightly_test.sh -p -l netcdf-cxx4 > nightly_log_cxx4.txt' >> /home/vagrant/crontab.in
        else
            sudo -i -u vagrant echo '01 3 * * * cd /home/vagrant/ctest_scripts && /home/vagrant/ctest_scripts/run_nightly_test.sh -l netcdf-c > nightly_log_c.txt' >> /home/vagrant/crontab.in
            sudo -i -u vagrant echo '01 4 * * * cd /home/vagrant/ctest_scripts && /home/vagrant/ctest_scripts/run_nightly_test.sh -l netcdf-fortran > nightly_log_fortran.txt' >> /home/vagrant/crontab.in
            sudo -i -u vagrant echo '01 5 * * * cd /home/vagrant/ctest_scripts && /home/vagrant/ctest_scripts/run_nightly_test.sh -l netcdf-cxx4 > nightly_log_cxx4.txt' >> /home/vagrant/crontab.in
        fi
        sudo -i -u vagrant crontab < /home/vagrant/crontab.in
        mv /home/vagrant/crontab.in $CRONLOCKFILE

        # Restart crontab, see if that fixes the issue
        # with jobs running at the wrong time.
        /etc/init.d/cron restart
    fi

fi
#end check for cron

## Install several packages from source.
# * cmake
# * hdf4
# * hdf5

CMAKE_VER="cmake-3.2.1"
HDF4_VER="hdf-4.2.11"

HDF5VER="1.8.15"
HDF5_VER="hdf5-$HDF5VER"
PNET_VER="parallel-netcdf-1.6.1"
# Install cmake from source
if [ ! -f /usr/local/bin/cmake ]; then
    CMAKE_FILE="$CMAKE_VER".tar.gz
    if [ ! -f "/vagrant/$CMAKE_FILE" ]; then
	    wget http://www.cmake.org/files/v3.2/$CMAKE_FILE
	    cp "$CMAKE_FILE" /vagrant
    else
	    cp "/vagrant/$CMAKE_FILE" .
    fi

    tar -zxf $CMAKE_FILE
    pushd $CMAKE_VER
    ./configure --prefix=/usr/local
    make install -j 2
    popd
    rm -rf $CMAKE_VER
fi

# Install hdf4 from source.
if [ ! -f /usr/lib/libhdf4.settings ]; then
    HDF4_FILE="$HDF4_VER".tar.bz2
    if [ ! -f "/vagrant/$HDF4_FILE" ]; then
	wget http://www.hdfgroup.org/ftp/HDF/HDF_Current/src/$HDF4_FILE
	cp "$HDF4_FILE" /vagrant
    else
	cp "/vagrant/$HDF4_FILE" .
    fi

    tar -jxf $HDF4_FILE
    pushd $HDF4_VER
    ./configure --disable-static --enable-shared --disable-netcdf --disable-fortran --prefix=/usr
    sudo make install -j 2
    popd
    rm -rf $HDF4_VER
fi

# Install hdf5 from source
if [ ! -f /usr/lib/libhdf5.settings ]; then
    HDF5_FILE="$HDF5_VER".tar.bz2
    if [ ! -f "/vagrant/$HDF5_FILE" ]; then
	    wget http://www.hdfgroup.org/ftp/HDF5/releases/$HDF5_VER/src/$HDF5_FILE
	    cp "$HDF5_FILE" /vagrant
    else
	    cp "/vagrant/$HDF5_FILE" .
    fi

    tar -jxf $HDF5_FILE
    pushd $HDF5_VER


    if [ "x$ISPAR" = "xTRUE" ]; then
        CFLAGS="-Wno-format-security" CC=`which mpicc` ./configure --enable-shared --disable-static --disable-fortran --enable-hl --disable-fortran --enable-parallel --prefix=/usr
    else
        ./configure --disable-static --enable-shared --disable-fortran --enable-hl --disable-fortran --prefix=/usr
    fi

    make install -j 2
    popd
    rm -rf $HDF5_VER
fi
if [ "x$ISPAR" = "xTRUE" ]; then
    if [ ! -f /usr/lib/libpnetcdf.a ]; then
        PNET_FILE="$PNET_VER.tar.bz2"
        if [ ! -f "/vagrant/$PNET_FILE" ]; then
            wget http://cucis.ece.northwestern.edu/projects/PnetCDF/Release/$PNET_FILE
            cp "$PNET_FILE" /vagrant
        else
            cp "/vagrant/$PNET_FILE" .
        fi

        tar -jxf $PNET_FILE
        pushd $PNET_VER
        CPPFLAGS="-fPIC" CC=`which mpicc` ./configure --prefix=/usr
        make -k install
        popd
        rm -rf $PNET_VER
    fi
fi

##
# In order to do netcdf-fortran testing, we need to
# install netcdf-c in an out-of-the-way place.
##
if [ ! -f /home/vagrant/local2/lib/libnetcdf.settings ]; then
    if [ ! -d /home/vagrant/netcdf-c ]; then
        git clone git://github.com/Unidata/netcdf-c
    fi
    pushd netcdf-c
    autoreconf -if
    #mkdir build
    #cd build

    if [ "x$ISPAR" = "xTRUE" ]; then
        #/usr/local/bin/cmake .. -DCMAKE_INSTALL_PREFIX=/home/vagrant/local2 -DENABLE_TESTS=OFF -DENABLE_PARALLEL=ON -DCMAKE_C_COMPILER=`which mpicc` -DCMAKE_C_FLAGS="-O2"
        CC=mpicc CFLAGS="-O2" ./configure --prefix=/home/vagrant/local2
    else
        #/usr/local/bin/cmake .. -DCMAKE_INSTALL_PREFIX=/home/vagrant/local2 -DENABLE_TESTS=OFF -DCMAKE_C_FLAGS="-O2"
        ./configure --prefix=/home/vagrant/local2
    fi
    make -j 2
    make install
    popd
    rm -rf netcdf-c/
fi

# End netcdf install

chown -R vagrant:vagrant /home/vagrant
sudo -i -u vagrant $CTEST_INIT
