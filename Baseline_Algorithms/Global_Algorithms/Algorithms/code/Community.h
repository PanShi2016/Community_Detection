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
using namespace std;

#define lowbit(x) ((x)&(-(x)))
#define sqr(x) ((x)*(x))
#define PB push_back
#define MP make_pair

class Community{
private:
	vector<int> cid;
	void calcid(){
		id.clear();
		for (int i=1;i<cid.size();i++){
			for (;cid[i]>=id.size();){
				vector<int> t;t.clear();
				id.PB(t);
			}
			id[cid[i]].PB(i);
		}
		NC=id.size()-1;
	}
public:
	vector<vector<int> > id;
	vector<int> leftover;
	int NC,N;
	bool isPartition;

	bool testPartition(){
		set<int> t;
		t.clear();
		for (int i=1;i<=NC;i++)
			for (int z=0;z<id[i].size();z++){
				if (t.find(id[i][z])!=t.end()) return false;
				t.insert(id[i][z]);
			}
		return true;
	}

	Community(){}
	void load(string filename){
		if (filename.substr(filename.size()-3)=="par")
			loadPartition(filename);
		else loadGeneral(filename);
	}
	void save(string filename){
		if (filename.substr(filename.size()-3)=="par")
			savePartition(filename);	
		else saveGeneral(filename);
	}
	void loadPartition(string filename){
		FILE* fin=fopen(filename.c_str(),"r");
		cid.clear();cid.PB(0);
		for (int i;fscanf(fin,"%d",&i)==1;)
			cid.PB(i);
		fclose(fin);
		N=cid.size()-1;
		isPartition=true;
		
		reId();
		leftover.clear();
		calcid();
	}
	void savePartition(string filename){
		FILE* fout=fopen(filename.c_str(),"w");
		for (int i=1;i<cid.size();i++)
			fprintf(fout,"%d\n",cid[i]);
		fclose(fout);
	}
	void loadGeneral(string filename){
		FILE* fin=fopen(filename.c_str(),"r");
		map<int,int> tcid;
		tcid.clear();
		char s[1000000];
		vector<int> cur;cur.clear();
		id.clear();
		id.PB(cur);
		isPartition=true;
		int curid=0;
		N=0;
		for (;fgets(s,1000000,fin);){
			curid++;
			cur.clear();
			for (char* p=strtok(s,"\t \n\r");p;p=strtok(NULL,"\t \n\r")){
				int i=atoi(p);
				cur.PB(i);
				N=max(N,i);
				if (tcid.find(i)!=tcid.end()) isPartition=false;
				tcid[i]=curid;
			}
			if (cur.size()>0) id.PB(cur);
		}
		fclose(fin);
		if (isPartition){
			cid.clear();
			cid.PB(0);
			for (int i=1;i<=N;i++)
				cid.PB(tcid[i]);
		}
		leftover.clear();
		NC=id.size()-1;
	}
	void attach(vector<int> t){
		id.PB(t);
		NC++;
	}
	void pop(){
		id.pop_back();
		NC--;
	}
	void saveGeneral(string filename){
		//if (!testPartition()) cout<<"ERR"<<" "<<filename<<endl;
		FILE* fout=fopen(filename.c_str(),"w");
		attach(leftover);
		for (int i=1;i<=NC;i++)if (id[i].size()){
			for (int j=0;j<id[i].size();j++)
				fprintf(fout,"%d\t",id[i][j]);
			fprintf(fout,"\n");
		}
		pop();
		//for (int i=0;i<leftover.size();i++) fprintf(fout,"%d\n",leftover[i]);
		fclose(fout);	
	}
	void saveSucheta(FILE* fout,vector<int> rid){
		/*calcid();
		for (int i=1;i<id.size();i++){
			for (int j=0;j<id[i].size();j++)
				fprintf(fout,"%d\t",rid[id[i][j]]);
			if (id[i].size())fprintf(fout,"\n");
		}*/
	}
	void loadModularity(string filename){
		FILE* fin=fopen(filename.c_str(),"r");
		cid.clear();
		for (int i,j,k=0;fscanf(fin,"%d%d",&i,&j)==2;){
			k+=(i==0);
			if (k==2) break;
			cid.PB(j);
		}
		N=cid.size()-1;
		for (int layer=1;;layer++){
			map<int,int> rid;rid.clear();
			for (int i,j;fscanf(fin,"%d%d",&i,&j)==2;){
				if (i==0) break;
				rid[i]=j;
			}
			if (rid.size()==0) break;
			for (int i=0;i<cid.size();i++)
				cid[i]=rid[cid[i]];
		}
		fclose(fin);
		leftover.clear();
		reId();
		calcid();
	}
	void loadInfomap(string filename){
		FILE* fin=fopen(filename.c_str(),"r");
		cid.clear();cid.PB(0);
		fscanf(fin,"%*s%*d");
		for (int i;fscanf(fin,"%d",&i)==1;)
			cid.PB(i);
		fclose(fin);
		N=cid.size()-1;
		isPartition=true;
		
		reId();
		leftover.clear();
		calcid();
	}
	void loadOSLOM(string filename){
		FILE* fin=fopen(filename.c_str(),"r");
		map<int,int> tcid;
		tcid.clear();
		char s[1000000];
		vector<int> cur;cur.clear();
		id.clear();
		id.PB(cur);
		isPartition=true;
		int curid=0;
		N=0;
		int linenumber=0;
		for (;fgets(s,1000000,fin);){
			linenumber++;
			if (linenumber%2) continue;
			curid++;
			cur.clear();
			for (char* p=strtok(s,"\t \n\r");p;p=strtok(NULL,"\t \n\r")){
				int i=atoi(p);
				cur.PB(i);
				N=max(N,i);
				if (tcid.find(i)!=tcid.end()) isPartition=false;
				tcid[i]=curid;
			}
			if (cur.size()>0) id.PB(cur);
		}
		fclose(fin);
		if (isPartition){
			cid.clear();
			cid.PB(0);
			for (int i=1;i<=N;i++)
				cid.PB(tcid[i]);
		}
		leftover.clear();
		NC=id.size()-1;
	}
	void reId(){
		map<int,int> rid;
		rid.clear();
		for (int i=1,j=1;i<=N;i++){
			if (rid.find(cid[i])==rid.end())
				rid[cid[i]]=j++;
			cid[i]=rid[cid[i]];
		}
	}
	void removeSmallComms(int Thres){
		for (int i=1;i<=NC;i++)
			if (id[i].size()<Thres){
				for (int z=0;z<id[i].size();z++)
					leftover.PB(id[i][z]);
				id[i].clear();
			}
	}
	vector<int> getPartitionID(){
		vector<int> res;res.clear();
		//if (!isPartition) return res;
		res.resize(N+1);
		for (int i=0;i<=N;i++) res[i]=-1;
		for (int i=1;i<=NC;i++)
			for (int j=0;j<id[i].size();j++)
				res[id[i][j]]=i;
		//int cur=NC;
		//for (int i=0;i<=N;i++) if (res[i]==-1) res[i]=++NC;
		return res;
	}
	void loadLinkCommunity(string filename){
		FILE* fin=fopen(filename.c_str(),"r");
		map<int,int> tcid;
		tcid.clear();
		char s[1000000];
		vector<int> cur;cur.clear();
		id.clear();
		id.PB(cur);
		isPartition=true;
		int curid=0;
		N=0;
		for (;fgets(s,1000000,fin);){
			curid++;
			cur.clear();
			set<int> tmp;tmp.clear();
			for (char* p=strtok(s,"\t \n\r,");p;p=strtok(NULL,"\t \n\r,")){
				int i=atoi(p);
				if (tmp.find(i)!=tmp.end()) continue;
				tmp.insert(i);
				cur.PB(i);
				N=max(N,i);
				if (tcid.find(i)!=tcid.end()) isPartition=false;
				tcid[i]=curid;
			}
			if (cur.size()>0) id.PB(cur);
		}
		fclose(fin);
		if (isPartition){
			cid.clear();
			cid.PB(0);
			for (int i=1;i<=N;i++)
				cid.PB(tcid[i]);
		}
		leftover.clear();
		NC=id.size()-1;
	}
	void sub(map<int,int> rid){
		for (int i=1;i<=NC;i++)
			for (int j=0;j<id[i].size();){
				if (rid.find(id[i][j])==rid.end()){
					swap(id[i][j],id[i][id[i].size()-1]);
					id[i].pop_back();
				}
				else{
					id[i][j]=rid[id[i][j]];
					j++;
				}
			}
		N=rid.size();
	}
	void loadWalkTrap(string filename){
		FILE* fin=fopen(filename.c_str(),"r");
		map<int,int> tcid;
		tcid.clear();
		char s[1000000];
		vector<int> cur;cur.clear();
		id.clear();
		id.PB(cur);
		isPartition=true;
		int curid=0;
		N=0;
		bool st=false;
		fgets(s,1000000,fin);
		if (sscanf(s,"Partition 0 (%d communities)",&N)!=1){
			cout<<s<<endl;
			for(;;);
		}
		N--;
		for (;fgets(s,1000000,fin);){
			if (s[0]=='M') {
				st=true;
				continue;
			}
			if (!st) continue;
			curid++;
			cur.clear();
			int k=0;
			for (char* p=strtok(s,"{},\t \n\r");p;p=strtok(NULL,"\t \n\r{},")){
				k++;
				if (k>3){
					int i=atoi(p);
					if (i==0) continue;
					cur.PB(i);
					N=max(N,i);
					if (tcid.find(i)!=tcid.end()) isPartition=false;
					tcid[i]=curid;
				}
			}
			if (cur.size()>0) id.PB(cur);
		}
		for (int i=1;i<=N;i++) if (tcid.find(i)==tcid.end()){
			curid++;
			cur.clear();
			cur.PB(i);
			tcid[i]=curid;
			id.PB(cur);
		}
		fclose(fin);
		if (isPartition){
			cid.clear();
			cid.PB(0);
			for (int i=1;i<=N;i++)
				cid.PB(tcid[i]);
		}
		leftover.clear();
		NC=id.size()-1;
	}

};