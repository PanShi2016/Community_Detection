function [] = TM_ESTIMATION()
% Process TM-ESTIMATION dataset

dataPath = '../Original_Data/TM-ESTIMATION/';
savePath = '../Processed_Data/';

% load SAND_TM_Estimation_Data.mat
A = load([dataPath,'SAND_TM_Estimation_Data.mat']);

save([savePath,'TM_ESTIMATION'],'A','-v7.3');

end
