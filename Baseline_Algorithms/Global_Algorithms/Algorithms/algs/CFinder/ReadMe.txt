在Linux下执行./CFinder_commandline -h 可以看到如下说明：

When using ./CFinder_commandline you must specify at least the 
 input file using the switch -i. 
 Example:

   ./CFinder_commandline -i my_links.dat 

   In this example CFinder will try to read the links of the 
   graph from 'my_links.dat' and will create a directory named
   'my_links.dat_files' to store the results of the community
   finding.

 If you run the ./CFinder_commandline not from the same directory,
 where the licence.txt file is, you must specify the location 
 of the licence file with the switch -l.
 Example:

   ./CFinder_commandline -i my_links.dat -l /tmp/licence.txt

   In this example CFinder will use the licence file from the
   /tmp/ directory.

 Optionally you can specify an output directory for ./CFinder_commandline
 using the switch -o.
 Example:

   ./CFinder_commandline -i my_links.dat -o my_dir

   In this example CFinder will write the results to 'my_dir'.

 Optionally you can set upper or/and lower weight thresholds
 for the links using the -w and -W switches.
 Examples:

   ./CFinder_commandline -i my_links.dat -w 0.15
   ./CFinder_commandline -i my_links.dat -W 1.35
   ./CFinder_commandline -i my_links.dat -w 0.15 -W 1.35

   -In the 1st example ./CFinder_commandline will ignore the links
    weaker than 0.15, and the results will be written into a
    directory named 'my_links.dat_files_0.150_w by default.
   -In the 2nd example ./CFinder_commandline will ignore the links
    stronger than 1.35, and the results will be written into a
    directory named 'my_links.dat_files_w_1.350 by default.
   -In the 3rd example ./CFinder_commandline will ignore links
    weaker than 0.15 or stronger than 1.35, and the results 
    will be written into a directory named
    'my_links.dat_files_0.150_w_1.350 by default.

 Optionally you can set the number of digits to be taken into
 account when creating the output directory name using the switch -d.
 The default value is 3 digits.
 Examples:

   ./CFinder_commandline -i my_links.dat -w 0.15327 -d 2
   ./CFinder_commandline -i my_links.dat -w 0.15327 -d 4

   -In the 1st example the output directory will be 
    'my_links.dat_files_0.15_w'.
   -In the 2nd example the output directory will be 
    'my_links.dat_files_0.1533_w'.

 Optionally you can set the maximal allowed time in seconds for 
 searching for the cliques of a node using the switch -t.
 Example:

   ./CFinder_commandline -i my_links.dat -t 2.75

    In this example the maximal allowed time per node is 
    2.75 secs.

 Optionally you can set the cliques (and the communities) 
 to be directed using the switch -D.

 Optionally you can explicitly declare the usage of the undirected
 search algorithm using the switch -U.
 (Has no effect except that it cannot be set together with -D).

 Optionally you can set a lower link weight intensity
 threshold for the k-cliques using the switch -I.
 Example:

   ./CFinder_commandline -i my_links.dat -I 0.35

    In this example the lower link weight intensity for the 
    k-cliques is 0.35.
 Note that when -I is active, the -D and the -t switches 
 cannot be active as well.

 Optionally you can specify the k-clique size using the 
 switch -k. (Otherwise the communities are extracted at every
 possible k-clique size). This switch can be useful when using
 a link weight intensity threshold, since in such case the
 intensities have to be calculated in every single k-cliques,
 and the extraction of the communities becomes very slow.

 Example:

   ./CFinder_commandline -i my_links.dat -I 0.35 -k 4

    In this example the lower link weight intensity for the 
    k-cliques is 0.35, and the communities are extracted at a
    k-clique size k=4
