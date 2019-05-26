function [] = getResults()
% get results for baseline algorithms

dataName = 'zachary';

dataPath = '../../../test_data/';

algorithms = {'BigClam','LC','GCE','OSLOM','DEMON','CFinder','NISE'};

detectedPath = ['../Results/',dataName];
dataPathandName = [dataPath,dataName];
truthPathandName = [dataPath,dataName,'.txt'];

graph = loadGraph(dataPathandName);
truthComm = loadCommunities(truthPathandName);
Alltime = importdata([detectedPath,'/','Total_Time.txt']);

dlmwrite(['../Results/',dataName,'/results.txt'],'Algorithms, F1, NMI, Conductance, CommNum, CommSize, Time','delimiter','');

for i = 1 : length(algorithms)
    detectedPathandName = [detectedPath,'/',algorithms{i},'.gen'];
    detectedComm = loadCommunities(detectedPathandName);
    F1 = GetF1score(detectedComm,truthComm);
    NMI = GetCoverNMI(truthComm,detectedComm);
    time = Alltime.data(i);
    AllCond = [];
    AllSize = [];
    for j = 1 : length(detectedComm)
        Cond = getConductance(graph,detectedComm{j});
        Cond = full(Cond);
        Size = length(detectedComm{j});
        AllCond = [AllCond,full(Cond)];
        AllSize = [AllSize,Size];
    end
    dlmwrite(['../Results/',dataName,'/results.txt'],[algorithms{i},'   ',num2str(F1,'%.3f'),'   ',num2str(NMI,'%.3f'),'   ',num2str(mean(AllCond),'%.3f'),'   ',num2str(j),'   ',num2str(mean(AllSize),'%.3f'),'   ',num2str(time,'%.3f')],'-append','delimiter','');
end

end
