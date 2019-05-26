	






#include "static_network.h"



int main(int argc, char * argv[]) {
		
	
	int sy;
	sy=system("make clean");
	sy=system("make");
	sy=system("ls > list_out");
	
	string s;
	ifstream gin("list_out");
	bool compiled=false;
	
	while(gin>>s) {
		
		if(s=="convert")
			compiled=true;
	}
	
	
		
	if(compiled)
		return 0;
	
	cout<<"error in compiling"<<endl;
        return -1;
}




