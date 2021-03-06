function prepare_system() {
echo -e "Prepare the system to install ${GREEN}$COIN_NAME${NC} seednode."
apt-get update >/dev/null 2>&1
DEBIAN_FRONTEND=noninteractive apt-get update > /dev/null 2>&1
DEBIAN_FRONTEND=noninteractive apt-get -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" -y -qq upgrade >/dev/null 2>&1
apt install -y software-properties-common >/dev/null 2>&1
echo -e "${GREEN}Adding bitcoin PPA repository"
apt-add-repository -y ppa:bitcoin/bitcoin >/dev/null 2>&1
echo -e "Installing required packages, it may take some time to finish.${NC}"
apt-get update >/dev/null 2>&1
apt-get install -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" make software-properties-common \
build-essential libtool autoconf libssl-dev libboost-dev libboost-chrono-dev libboost-filesystem-dev libboost-program-options-dev \
libboost-system-dev libboost-test-dev libboost-thread-dev sudo automake git wget curl libdb4.8-dev bsdmainutils libdb4.8++-dev \
libminiupnpc-dev libgmp3-dev ufw pkg-config libevent-dev  libdb5.3++ unzip libzmq5 >/dev/null 2>&1
if [ "$?" -gt "0" ];
  then
    echo -e "${RED}Not all required packages were installed properly. Try to install them manually by running the following commands:${NC}\n"
    echo "apt-get update"
    echo "apt -y install software-properties-common"
    echo "apt-add-repository -y ppa:bitcoin/bitcoin"
    echo "apt-get update"
    echo "apt install -y make build-essential libtool software-properties-common autoconf libssl-dev libboost-dev libboost-chrono-dev libboost-filesystem-dev \
libboost-program-options-dev libboost-system-dev libboost-test-dev libboost-thread-dev sudo automake git curl libdb4.8-dev \
bsdmainutils libdb4.8++-dev libminiupnpc-dev libgmp3-dev ufw pkg-config libevent-dev libdb5.3++ unzip libzmq5"
 exit 1
fi
clear
}

function create_swap() {
 echo -e "Checking if swap space is needed."
 PHYMEM=$(free -g|awk '/^Mem:/{print $2}')
 SWAP=$(free -g|awk '/^Swap:/{print $2}')
 if [ "$PHYMEM" -lt "2" ] && [ -n "$SWAP" ]
  then
    echo -e "${GREEN}Server is running with less than 2G of RAM without SWAP, creating 2G swap file.${NC}"
    SWAPFILE=$(mktemp)
    dd if=/dev/zero of=$SWAPFILE bs=1024 count=2M
    chmod 600 $SWAPFILE
    mkswap $SWAPFILE
    swapon -a $SWAPFILE
 else
  echo -e "${GREEN}Server running with at least 2G of RAM, no swap needed.${NC}"
 fi
 clear
}

prepare_system
create_swap
chmod -R 775 *
NODEIP=$(curl -s4 api.ipify.org)
bash autogen.sh
chmod -R 775 *
pubip=dig +short myip.opendns.com @resolver1.opendns.com
endmessage="Setup Has finished successfully and seednode is up at $NODEIP" 
# git clone https://github.com/akshaynexus/hivenet
# cd hivenet 
chmod -R 775 *
./configure --enable-tests=no --with-gui=no
make clean
make install
if [ -d '/root/.hive' ] ; then
#Things to do
cd /root/.hive
rm -rf *
touch hive.conf
echo "rpcuser=user" >> hive.conf
echo "rpcpassword=pass123" >> hive.conf
echo "server=1" >> hive.conf
echo "daemon=1" >> hive.conf
echo "listen=1" >> hive.conf
echo "rpcallowip=127.0.0.1" >> hive.conf
echo "Finished setting up config,now starting daemon"
hived
echo $endmessage
else 
mkdir /root/.hive
cd /root/.hive
touch hive.conf
echo "rpcuser=user" >> hive.conf
echo "rpcpassword=pass123" >> hive.conf
echo "server=1" >> hive.conf
echo "daemon=1" >> hive.conf
echo "listen=1" >> hive.conf
echo "rpcallowip=127.0.0.1" >> hive.conf
echo "Finished setting up config,now starting daemon"
hived
echo $endmessage
fi