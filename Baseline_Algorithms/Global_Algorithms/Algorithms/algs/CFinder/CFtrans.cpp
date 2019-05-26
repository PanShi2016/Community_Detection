#include <fstream>
#include <iostream>
#include <vector>
#include <string>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>

using namespace std;

string split(string str)
{
	char a[100000];
	sprintf(a, "%s", str.c_str());
	vector<string> vs;
	for(char *p = strtok(a, ":"); p; p=strtok(NULL, ":"))
		vs.push_back(p);
	return vs[1];
}

int main (int argc, char const *argv[])
{
	//printf("%f", pow(2, -3));

    ifstream inFile;
    inFile.open (argv[1]);
    if (!inFile) {
        cout << "ERROR: unable to open input file" << endl;
        exit(1); // terminate with error
    }
    string line, tmp;
	vector<string> vs;
	int i = 0;
	while(getline(inFile, line))
	{
		i++;
		if(i > 8)
		{
			vs.push_back(split(line));
		}	
	}
   
    inFile.close(); inFile.clear();

	ofstream outfile;
	outfile.open(argv[2], ios::out);
	for(int i = 0; i < vs.size(); ++i)
		outfile<<vs[i].c_str()<<endl;
	outfile.close();
	return 0;
}
