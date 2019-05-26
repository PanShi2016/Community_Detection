#! /usr/bin/env bash

#编译(只需一次)
g++ -o ./code/run ./code/run.cpp

g++ -o ./algs/LinkCommunity/calcAndWrite_Jaccards  ./algs/LinkCommunity/calcAndWrite_Jaccards.cpp
g++ -o ./algs/LinkCommunity/callCluster  ./algs/LinkCommunity/callCluster.cpp

cd ./algs/GCECommunityFinder/build
make
cd ../../..

g++ -o ./algs/CFinder/CFinderWinLinux/CFtrans ./algs/CFinder/CFtrans.cpp
chmod +x algs/CFinder/CFinderWinLinux/CFinder_commandline
chmod +x algs/CFinder/CFinderWinLinux/CFinder_commandline64

cd ./algs/OSLOM2
sh ./compile_all.sh
cd ../..

g++ -o ./algs/BIGCLAM/dataTran ./algs/BIGCLAM/dataTran.cpp
