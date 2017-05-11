# pisah nama dan akhiran berkas
ext=".pas"
fname=$(basename "$1")
bname=$(basename $fname $ext)
cgipath="web/"

# kompilasi program
echo "Compiling:" fpc -XXs -CX -O3 -S2achi "$1" -o$bname.cgi "..."
fpc -XXs -CX -O3 -S2achi "$1" -o$bname.cgi

# uji hasil kompilasi
if [ -f $bname.o ]; then
  # salin program ke foldernya
  echo "Deploying:" mv $bname.cgi $cgipath "..."
  mv $bname.cgi $cgipath
  # hapus berkas sampah
  echo "Cleaning:" rm $bname.o "..."
  #rm $bname.o
  rm *.o *.ppu
  echo "Done."
else
  # kompilasi gagal
  echo "Error!"
  return 1
fi 