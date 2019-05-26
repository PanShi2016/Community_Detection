double clusterJaccsFile(int argc, char const *argv[], double maxDm, double counti){
    //************* make sure args are present:
    if (argc != 5){
        cout << "ERROR: something wrong with the inputs" << endl;
        cout << "usage:\n    " << argv[0] << " network.pairs network.jaccs network.clusters network.cluster_stats threshold" << endl;
        exit(1);
    }
    float threshold = counti;
    if (threshold < 0.0 || threshold > 1.0){
        cout << "ERROR: specified threshold not in [0,1]" << endl;
        exit(1);
    }
    //************* got the args
    
    //************* start load edgelist
    ifstream inFile;
    inFile.open( argv[1] );
    if (!inFile) {
        cout << "ERROR: unable to open input file" << endl;
        exit(1); // terminate with error
    }
    // index should be iterator not integer????
    map< int,           set<pair<int,int> > > index2cluster; // O(log n) access too slow?
    map< pair<int,int>, map< int,set<pair<int,int> > >::iterator > edge2iter;

    int ni, nj, wij, index = 0;
    while (inFile >> ni >> nj){ // scan edgelist to populate 
    //while (inFile >> ni >> nj >> wij){ // scan edgelist to populate WEIGHTED
        if (ni >= nj) swap(ni,nj); // undirected!
        
        index2cluster[ index ].insert( make_pair(ni,nj) );         // build cluster index to set of edge-pairs map
        edge2iter[ make_pair(ni,nj) ] = index2cluster.find(index); // build edge pair to cluster iter map ******????
        index++;
    }
    inFile.close(); inFile.clear();
    //************* end load edgelist
    
    //************* loop over jaccards file and do the clustering
    ifstream jaccFile;  jaccFile.open( argv[2] );
    if (!jaccFile) {
        cout << "ERROR: unable to open jaccards file" << endl;
        exit(1); // terminate with error
    }
    int i0,i1,j0,j1; double jacc;
    int idx_i, idx_j;
    map< int, set<pair<int,int> > >::iterator iter_i,iter_j;
    set<pair<int,int> >::iterator iterS;
    while ( jaccFile >> i0 >> i1 >> j0 >> j1 >> jacc ) {
        if ( jacc >= threshold ) {
            if (i0 >= i1) swap(i0,i1); // undirected!
            if (j0 >= j1) swap(j0,j1); // undirected!
            
            iter_i = edge2iter[ make_pair(i0,i1) ];
            iter_j = edge2iter[ make_pair(j0,j1) ];
            if ( iter_i != iter_j ) {
                // always merge smaller cluster into bigger:
                if ( (*iter_j).second.size() > (*iter_i).second.size() ){ // !!!!!!
                    swap(iter_i, iter_j);
                }
                
                // merge cluster j into i and update index for all elements in j:
                for (iterS = iter_j->second.begin(); iterS != iter_j->second.end(); iterS++){
                    iter_i->second.insert( *iterS );
                    edge2iter[ *iterS ] = iter_i;
                }
                
                // delete cluster j:
                index2cluster.erase(iter_j);
            } 
        } // done merging clusters i and j
    }
    //************* done looping over jaccards file
    
    
    //************* write the clusters to file:
    jaccFile.close();
    cout << "There were " << index2cluster.size() << " clusters at threshold " << threshold << "." << endl;
    
    // all done clustering, write to file (and calculated partition density):
    //FILE * clustersFile     = fopen( argv[3], "w" );
    //FILE * clusterStatsFile = fopen( argv[4], "w" );
    
    set<int> clusterNodes;
	map<int, set<int> > tmpNodes;
	int iNode = 0;
    int mc, nc;
    int M = 0, Mns = 0;
    double wSum = 0.0;
    
    set< pair<int,int> >::iterator S;
    map< int,set<pair<int,int> > >::iterator it;
    
    for ( it = index2cluster.begin(); it != index2cluster.end(); it++ ) {
        clusterNodes.clear();
        for (S = it->second.begin(); S != it->second.end(); S++ ){
            //fprintf( clustersFile, "%i %i ", S->first+1, S->second+1 ); // this leaves a trailing space...!
 
            clusterNodes.insert(S->first);
            clusterNodes.insert(S->second);
        }
        set<int>::iterator itNode;
        for(itNode = clusterNodes.begin(); itNode != clusterNodes.end();itNode++)
			tmpNodes[iNode].insert(*itNode);
		iNode++;
            //fprintf( clustersFile, "%i ", *itNode + 1);
        mc =   it->second.size();
        nc = clusterNodes.size();
        M += mc;
        if (nc != 2) {
            Mns  += mc;
            wSum += mc * (mc - (nc-1.0)) / ((nc-2.0)*(nc-1.0));
        }
        
        //fprintf( clustersFile, "\n" );
        //fprintf( clusterStatsFile, "%i %i\n", mc, nc );
    }
    //fclose(clustersFile);
    //fclose(clusterStatsFile);
    //*************
	//cout<<"the d:"<<2.0 * wSum / M<<" tmpd:"<<maxDm<<endl;
	//cout<<maxDm<<" "<<2.0 * wSum / M<<endl;
	if(maxDm < (2.0 * wSum / M))
	{
		//cout<<"hre111111"<<endl;
		//getchar();
		
		FILE * clustersFile1     = fopen( argv[3], "w" );
		map<int, set<int> >::iterator itn = tmpNodes.begin();
		for(; itn != tmpNodes.end(); ++itn)
		{
			for( set<int>::iterator itNode = itn->second.begin(); itNode != itn->second.end(); itNode++)
				fprintf( clustersFile1, "%i ", *itNode);
			fprintf( clustersFile1, "\n" );
		}
		fclose(clustersFile1);
		FILE * outfile     = fopen( "LC_output.txt", "w" );
		fprintf( outfile, "There were %i clusters at threshold %f.\n", index2cluster.size(), threshold);
		fprintf( outfile, "The partition density is:\n");
		fprintf( outfile, "D = %f\n", 2.0 * wSum / M);
		fprintf( outfile, "not counting one-edge clusters:\n");
		fprintf( outfile, "D = %f\n", 2.0 * wSum / Mns);
		fclose(outfile);
	}

    return (2.0 * wSum / M);
}
