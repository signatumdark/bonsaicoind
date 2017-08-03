#!/bin/bash

set -e

date


#################################################################
# Update Ubuntu and install prerequisites for running Bonsaicoin   #
#################################################################
sudo apt-get update
#################################################################
# Build Bonsaicoin from source                                     #
#################################################################
NPROC=$(nproc)
echo "nproc: $NPROC"
#################################################################
# Install all necessary packages for building Bonsaicoin           #
#################################################################
sudo apt-get install -y qt4-qmake libqt4-dev libminiupnpc-dev libdb++-dev libdb-dev libcrypto++-dev libqrencode-dev libboost-all-dev build-essential libboost-system-dev libboost-filesystem-dev libboost-program-options-dev libboost-thread-dev libboost-filesystem-dev libboost-program-options-dev libboost-thread-dev libssl-dev libdb++-dev libssl-dev ufw git
sudo add-apt-repository -y ppa:bitcoin/bitcoin
sudo apt-get update
sudo apt-get install -y libdb4.8-dev libdb4.8++-dev

# By default, assume running within repo
repo=$(pwd)
file=$repo/src/signatumd
if [ ! -e "$file" ]; then
	# Now assume running outside and repo has been downloaded and named signatum
	if [ ! -e "$repo/signatum/build.sh" ]; then
		# if not, download the repo and name it signatum
		sudo git clone https://github.com/signatumd/source signatum
	fi
	repo=$repo/signatum
	file=$repo/src/signatumd
cd $repo/src/
fi
sudo make -j$NPROC -f makefile.unix
sudo cp $repo/src/signatumd /usr/bin/signatumd

################################################################
# Configure to auto start at boot                                      #
################################################################
file=$HOME/.bonsaicoin
if [ ! -e "$file" ]
then
        sudo mkdir $HOME/.bonsaicoin
fi
printf '%s\n%s\n%s\n%s\n' 'daemon=1' 'server=1' 'rpcuser=u' 'rpcpassword=p' | sudo tee $HOME/.bonsaicoin/bonsaicoin.conf
file=/etc/init.d/bonsaicoin
if [ ! -e "$file" ]
then
        printf '%s\n%s\n' '#!/bin/sh' 'sudo bonsaicoind' | sudo tee /etc/init.d/bonsaicoin
        sudo chmod +x /etc/init.d/bonsaicoin
        sudo update-rc.d bonsaicoin defaults
fi

/usr/bin/bonsaicoind
echo "Bonsaicoin has been setup successfully and is running..."


