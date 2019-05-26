# !/bin/sh
#cd /home/xiaofan/maxsatz/
#cd /algs/GCECommunityFinder/
#build:  cd ./algs/GCECommunityFinder/build; make

dir="./dataPairs/"
filelist=`ls $dir`
outputpath="./result/GCE/"

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
	./algs/GCECommunityFinder/build/GCECommunityFinder $dir$filename/graph.pairs 3 0.6 1.0 0.75 2> ParaResult.txt | tee GCE.gen
	#./algs/GCECommunityFinder/build/GCECommunityFinder $dir$filename/graph.pairs 2> ParaResult.txt | tee GCE.gen
	mv ./GCE.gen $outputpath$filename
	mv ./ParaResult.txt $outputpath$filename
	mv ./GCE_time.txt $outputpath$filename
done 
