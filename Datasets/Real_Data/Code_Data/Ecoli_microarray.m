function [] = Ecoli_microarray()
% Process Ecoli_microarray dataset 

dataPath = '../Original_Data/Ecoli_microarray/';
savePath = '../Processed_Data/';

% load logexpr.csv
A = importdata([dataPath,'logexpr.csv']);
logexpr = sparse(A.data);

% load regDB.csv
B = importdata([dataPath,'regDB.csv']);
regDB = sparse(B.data);

save([savePath,'Ecoli_microarray.mat'],'logexpr','regDB','-v7.3');

end
