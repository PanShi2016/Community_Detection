void LinkComm()
{
	struct timeval start,end;
    gettimeofday(&start,NULL);

	if(config["LinkCommunity_type"] == "c++")
	{
		systemCall(config["LinkCommunity_Dir"] + "calcAndWrite_Jaccards " + config["DATA_DIR"] + config["INSTANCE_NAME"] + " " + config["TMP_DIR"]+"graph.jaccs");
		systemCall(config["LinkCommunity_Dir"] + "callCluster " + config["DATA_DIR"] + config["INSTANCE_NAME"] + " " + config["TMP_DIR"] + "graph.jaccs LC.gen threshhold");

		gettimeofday(&end,NULL);

		double span = end.tv_sec-start.tv_sec + (end.tv_usec - start.tv_usec)/1000000.0;
    		ofstream otime;
    		otime.open((config["RESULT_DIR"]+"Total_Time.txt").c_str(), ios::out|ios::app);
    		otime <<"LinkCommunity_c++"<<"\t"<<span<<endl;
    		otime.close();
		
		systemCall("rm ./LCtime.txt");
		systemCall("mv -f ./LC*.* " + config["RESULT_DIR"]);
	}
	else
	{
		systemCall(config["LinkCommunity_Dir"]+"dataTrans "+config["DATA_DIR"]+config["INSTANCE_NAME"]+" "+config["TMP_DIR"]+config["INSTANCE_NAME"]+"_lc");
		systemCall("python "+config["LinkCommunity_Dir"]+"link_clustering_update.py -d \" \" " + config["TMP_DIR"]+config["INSTANCE_NAME"]+"_lc");
		systemCall("./code/dataTransback LC.gen LCnew.gen");
		
		gettimeofday(&end,NULL);

		double span = end.tv_sec-start.tv_sec + (end.tv_usec - start.tv_usec)/1000000.0;
    		ofstream otime;
    		otime.open((config["RESULT_DIR"]+"Total_Time.txt").c_str(), ios::out|ios::app);
    		otime <<"LinkCommunity_python"<<"\t"<<span<<endl;
    		otime.close();
		
		systemCall("mv -f ./LC.D " + config["RESULT_DIR"]);
		systemCall("mv -f ./LCnew.gen " + config["RESULT_DIR"]+"LC.gen");
		systemCall("mv -f ./LC.* " + config["RESULT_DIR"]);
	}
}

void GCEComm()  
{
	struct timeval start,end;
    	gettimeofday(&start,NULL);

	systemCall(config["GCECommunityFinder_Dir"] + " "+config["DATA_DIR"]+ config["INSTANCE_NAME"]+ " 4 0.6 1.0 0.75 2> GCEParameter.txt | tee GCE.gen");

	gettimeofday(&end,NULL);

	double span = end.tv_sec-start.tv_sec + (end.tv_usec - start.tv_usec)/1000000.0;
    	ofstream otime;
    	otime.open((config["RESULT_DIR"]+"Total_Time.txt").c_str(), ios::out|ios::app);
    	otime <<"GCECommunityFinder"<<"\t"<<span<<endl;
    	otime.close();

	systemCall("mv -f ./GCE.gen " + config["RESULT_DIR"]);
	systemCall("mv -f ./GCEParameter.txt " + config["RESULT_DIR"]);
	systemCall("rm ./GCE_time.txt");	
}

void DEMONComm()
{
	struct timeval start,end;
    	gettimeofday(&start,NULL);

	systemCall("python " + config["DEMON_Dir"] + "launch.py "+config["DATA_DIR"]+config["INSTANCE_NAME"]);
	systemCall("mv DEMON.gen "+config["RESULT_DIR"]);

	gettimeofday(&end,NULL);

	double span = end.tv_sec-start.tv_sec + (end.tv_usec - start.tv_usec)/1000000.0;
    	ofstream otime;
    	otime.open((config["RESULT_DIR"]+"Total_Time.txt").c_str(), ios::out|ios::app);
    	otime <<"DEMON"<<"\t"<<span<<endl;
    	otime.close();
	
	systemCall("rm ./Demon_time.txt");
}

void CFinderComm()
{
	systemCall("rm -r "+config["TMP_DIR"]); 
	struct timeval start,end;
    	gettimeofday(&start,NULL);
	
  	systemCall(config["CFinder_Dir"] + "CFinder_commandline64 -i "+config["DATA_DIR"]+config["INSTANCE_NAME"]+ " -l "+config["CFinder_Dir"]+"licence.txt -o "+config["TMP_DIR"]+" -k "+config["CFinder_k"]);

	gettimeofday(&end,NULL);
	double span = end.tv_sec-start.tv_sec + (end.tv_usec - start.tv_usec)/1000000.0;
    	ofstream otime;
    	otime.open((config["RESULT_DIR"]+"Total_Time.txt").c_str(), ios::out|ios::app);
    	otime <<"CFinder"<<"\t"<<span<<endl;
    	otime.close();
	systemCall(config["CFinder_Dir"] + "CFtrans "+config["TMP_DIR"]+"k="+config["CFinder_k"]+"/communities "+config["RESULT_DIR"]+"CFinder.gen");
	
	systemCall("if [ ! -d " + config["TMP_DIR"]+" ]; then\n mkdir "+config["TMP_DIR"]+"\n fi");
}

void OSLOMComm()
{
	struct timeval start,end;
    	gettimeofday(&start,NULL);
	
	systemCall("cp "+config["DATA_DIR"]+config["INSTANCE_NAME"]+ " "+config["TMP_DIR"]);
	string oslomGraphFile=config["TMP_DIR"]+config["INSTANCE_NAME"];
	string OSLOMCommunityFile=oslomGraphFile+"_oslo_files/tp";
	
  	systemCall(config["OSLOM_Dir"] + "oslom_undir -f " + oslomGraphFile+ " -uw -hr 0");

	gettimeofday(&end,NULL);

	double span = end.tv_sec-start.tv_sec + (end.tv_usec - start.tv_usec)/1000000.0;
    	ofstream otime;
    	otime.open((config["RESULT_DIR"]+"Total_Time.txt").c_str(), ios::out|ios::app);
    	otime <<"OSLOM"<<"\t"<<span<<endl;
    	otime.close();

	Community comms;
	comms.loadOSLOM(OSLOMCommunityFile);
	comms.save(config["RESULT_DIR"]+"OSLOM.gen");

	for (int i=1;;i++){
		if (!checkFileExist(OSLOMCommunityFile+int2str(i))) break;
		Community comms;
		comms.loadOSLOM(OSLOMCommunityFile+int2str(i));
		comms.save(config["RESULT_DIR"]+"OSLOM"+int2str(i)+".gen");
		}
	
	systemCall("rm -r ./time_seed.dat ./tp");
}

void NISEComm()
{
	struct timeval start,end;
    	gettimeofday(&start,NULL);
	systemCall("cp "+config["DATA_DIR"]+config["INSTANCE_NAME"]+ " "+config["TMP_DIR"]);
	string NISEGraphFile=config["TMP_DIR"]+config["INSTANCE_NAME"];
  	systemCall("matlab -nodesktop -nosplash -r \"addpath('"+config["NISE_Dir"]+"');addpath('"+config["NISE_Dir"]+"matlab_bgl');addpath('"+config["NISE_Dir"]+"GraclusSeeds/graclus1.2/matlab');"+"NISERun('"+NISEGraphFile+"','"+config["NISE_seeds"]+"',"+config["NISE_k"]+");exit\"");
	systemCall("cd ../..");
	gettimeofday(&end,NULL);
	double span = end.tv_sec-start.tv_sec + (end.tv_usec - start.tv_usec)/1000000.0;
    	ofstream otime;
    	otime.open((config["RESULT_DIR"]+"Total_Time.txt").c_str(), ios::out|ios::app);
    	otime <<"NISE"<<"\t"<<span<<endl;
    	otime.close();
	systemCall("mv NISE.gen "+config["RESULT_DIR"]+"NISE.gen");
}


void BigClamComm()
{
	struct timeval start,end;
    	gettimeofday(&start,NULL);
	systemCall("cp "+config["DATA_DIR"]+config["INSTANCE_NAME"]+ " "+config["TMP_DIR"]);
	string GraphFile=config["TMP_DIR"]+config["INSTANCE_NAME"];
	systemCall(config["BigClam_Dir"] + "dataTran " + config["TMP_DIR"]+config["INSTANCE_NAME"] + " " + config["TMP_DIR"]+"graph.txt");
	
  	systemCall(config["BigClam_Dir"] + "bigclam" + " -i:" + config["TMP_DIR"]+"graph.txt" + " -o:" + config["RESULT_DIR"] + "BigClam.gen "+ "-c:"+config["BigClam_c"] + " -mc:"+config["BigClam_min_c"] + " -xc:"+config["BigClam_max_c"] + " -nc:"+config["BigClam_nc"] + " -nt:"+config["BigClam_nt"] + " -sa:"+config["BigClam_sa"] + " -sb:"+config["BigClam_sb"]  + " | tee " + config["RESULT_DIR"] + "BigClam.log");
  	
  	systemCall("mv " + config["RESULT_DIR"] + "BigClam.gencmtyvv.txt " + config["RESULT_DIR"] + "BigClam.gen");
  	systemCall("mv " + config["RESULT_DIR"] + "BigClam.gengraph.gexf " + config["RESULT_DIR"] + "BigClam.gexf");
	
	gettimeofday(&end,NULL);
	double span = end.tv_sec-start.tv_sec + (end.tv_usec - start.tv_usec)/1000000.0;
    	ofstream otime;
    	otime.open((config["RESULT_DIR"]+"Total_Time.txt").c_str(), ios::out|ios::app);
    	otime <<"BigClam"<<"\t"<<span<<endl;
    	otime.close();
}
