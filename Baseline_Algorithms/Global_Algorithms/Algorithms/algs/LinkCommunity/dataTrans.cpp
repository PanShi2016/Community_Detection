#include <fstream>
#include <iostream>
#include <set>
#include <vector>
#include <algorithm> // for swap
using namespace std;

int main (int argc, char const *argv[])
{
	//printf("%f", pow(2, -3));

	ifstream inFile;
    inFile.open (argv[1]);
    if (!inFile) {
        cout << "ERROR: unable to open input file" << endl;
        exit(1); // terminate with error
    }
    	ofstream outfile;
	outfile.open(argv[2], ios::out);

    int ni, nj, wij, index = 0;
	int tempV; //inFile >> tempV;
    while (inFile >> ni >> nj){
		ni--; nj--;
           outfile<<ni<<"\t"<<nj<<endl;
    }
    inFile.close(); inFile.clear();
	outfile.close();
	return 0;
}
