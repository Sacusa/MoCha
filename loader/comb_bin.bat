call promgen -w -p bin -c FF -o download -s 16384 -u 0 controller.bit -data_file up 0f0000 %1 -spi
del "download.cfi"
del "download.prm"