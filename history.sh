cd ~

# install basic tools
sudo apt-get update
sudo apt-get install nano
sudo apt-get install lynx
sudo apt-get install apache2

# create web-root folder
nano .bashrc
mv workspace/ web/

# setup apache module
sudo a2enmod cgid
sudo a2enmod rewrite 
sudo apache2ctl restart
sudo apache2ctl status

# download and install fpc
wget ftp://freepascal.stack.nl/pub/fpc/dist/3.0.0/x86_64-linux/fpc-3.0.0.x86_64-linux.tar
tar xf fpc-3.0.0.x86_64-linux.tar
cd fpc-3.0.0.x86_64-linux
sudo ./install.sh
cd ..
rm -rf fpc-3.0.0.x86_64-linux
rm fpc-3.0.0.x86_64-linux.tar
fpc -v

# setup nano
sudo nano /etc/nanorc 
sudo mv conf.nanorc /usr/share/nano/
sudo nano /etc/nanorc 

# edit apache config
sudo nano /etc/apache2/apache2.conf 
sudo nano /etc/apache2/sites-available/000-default.conf 
sudo nano /etc/apache2/conf-available/serve-cgi-bin.conf
sudo apache2ctl restart

# check disk space
df -h
clear
exit

# test pas script
touch pas.sh
fpc test.pas -otest.cgi
pas test.pas 

# create cgi log file
touch cgi.log 
sudo chown cabox:www-data cgi.log 
sudo chmod 664 cgi.log 
tail -f cgi.log 
> cgi.log 

# test shared mem program
fpc -XXs -CX -O3 sharedMem.pas 
./sharedMem w "this is a data"
./sharedMem r
./sharedMem d

# test shared mem unit
rm *.ppu *.o
fpc -XXs -CX -O3 -vq shmtest.pas 
./shmtest w "this is data"
./shmtest r
./shmtest l
./shmtest u "this is new data"
./shmtest d

# create ipcm cleaner script
touch cleanshm.sh
chmod +x cleanshm.sh

# test ipcm cleaner script
> cgi.log 
sudo ipcs -m
sudo ./cleanshm.sh 
sudo ./cleanshm.sh cabox
tail -f cgi.log 

# create vps backup into a zip file
cp .bash_history history.sh
zip backup-[date]-[time].zip * -r -x web/*.cgi

# test a cgi program
> cgi.log 
pas test9.pas 
sudo ipcs -m
sudo ./cleanshm.sh 
tail cgi.log 
