Main_folder=Sources_2_5

source_folder=$Main_folder/OSLOM_files
visual_folder=$Main_folder/visualSources

echo ""
echo "Compiling louvain  method ..."
cd $Main_folder/louvain/
g++ script_to_compile.cpp
./a.out
g++ -o louvain_script order.cpp -O3
cd ../..
mv $Main_folder/louvain/louvain_script .
mv $Main_folder/louvain/community .
mv $Main_folder/louvain/convert .
mv $Main_folder/louvain/hierarchy .
