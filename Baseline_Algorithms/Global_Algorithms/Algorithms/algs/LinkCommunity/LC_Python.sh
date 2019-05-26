# !/bin/sh
#cd /home/xiaofan/maxsatz/
#cd /algs/GCECommunityFinder/
#build:  cd ./algs/GCECommunityFinder/build; make

dir="./dataPairs/"
filelist=`ls $dir`
outputpath="./result/LC/"

if [ ! -d "$outputpath" ]; then
mkdir "$outputpath"
fi

for filename in $filelist
do 	
	if [ ! -d "$outputpath$filename" ]; then
	    mkdir "$outputpath$filename"
	fi		
	echo $filename
	#touch ./GCE.time
	python ./algs/LC/link_clustering_update.py -d " "  $dir$filename/graph.pairs
	mv ./LC.gen $outputpath$filename
	mv ./LC.D $outputpath$filename
	mv ./LC.timelength $outputpath$filename
done 
