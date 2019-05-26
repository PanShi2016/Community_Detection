#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <cmath>
#include <iostream>
#include <algorithm>
#include <string>
#include <vector>
#include <queue>
#include <set>
#include <map>
#include <sstream>
#include <cctype>
#include <fstream>
#include <sys/time.h>
#include <unistd.h>

using namespace std;

map<string,string> config;
vector<string> existAlgs;  // all available algorithms
vector<string> inputALgs;  // user should run the algorithms
string instanceName;       // instance name

#include "basic.h"
#include "Community.h"
#include "algs.h"

void loadAllAlgthm()
{
	existAlgs.push_back("LinkCommunity");
}

void loadConfig(char* filename)
{
    string tmp1 = "./config/", tmp2 = ".config";
    string basic = "General_Settings";

    FILE* fin = fopen((tmp1 + basic + tmp2).c_str(),"r");
	config.clear();
	char name[1000],value[1000];
	for (;fscanf(fin,"%s%s",name,value) == 2;)
		config[name] = value;
	fclose(fin);

	fin = fopen((tmp1 + filename + tmp2).c_str(),"r");
	for (;fscanf(fin,"%s%s",name,value) == 2;)
		config[name] = value;
	fclose(fin);
}

// run algorithms 
void runAlgorithm(string algo_name)
{
	if("LinkCommunity" == algo_name)
		LinkComm();
	else if("GCECommunityFinder" == algo_name)
		GCEComm();
	else if("DEMON" == algo_name)
		DEMONComm();
	else if("CFinder" == algo_name)
		CFinderComm();
	else if("OSLOM" == algo_name)
		OSLOMComm();
    else if("NISE" == algo_name)
        NISEComm();   
    else if("BigClam" == algo_name)
        BigClamComm();  
	else
		cout << "no such algorithm called " << algo_name << endl;
}

int main(int argc, char** argv)
{
	if (argc < 2)
    {
		puts("Argument Error");
		return 0;
	}

	loadConfig(argv[1]);

	if (argc < 3)
    {
		instanceName = "graph_single.pairs"; // argv[1];
	}

	inputALgs = split(config["BasicAlgs"]);
	existAlgs = split(config["candidates"]);

	systemCall("if [ ! -d " + config["RESULT_DIR"]+" ]; then\n mkdir "+config["RESULT_DIR"]+"\n fi");
	systemCall("if [ ! -d " + config["TMP_DIR"]+" ]; then\n mkdir "+config["TMP_DIR"]+"\n fi");
	
	ofstream otime;
    	otime.open((config["RESULT_DIR"]+"./Total_Time.txt").c_str(), ios::out|ios::app);
	otime.close();

	if(inputALgs[0] == "all")	// if BasicAlgs == all, run all alternative algorithms
	{
		for(vector<string>::iterator itr = existAlgs.begin(); itr != existAlgs.end(); ++itr)
		{
			runAlgorithm(*itr);
		}
	}
	else	// run algorithms in BasicAlgs in turn
	{
		for(vector<string>::iterator itr = inputALgs.begin(); itr != inputALgs.end(); ++itr)
		{
			runAlgorithm(*itr);
		}
	}
	return 0;
}
