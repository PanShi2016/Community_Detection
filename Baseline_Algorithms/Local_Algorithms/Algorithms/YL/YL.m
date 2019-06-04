function [] = YL(dataSetName) 
% YL: Yand & Leskovec paper (ICDM 2012 & KIS 2015) 

graphPath = '../../../../test_data/zachary';
communityPath = '../../../../test_data/zachary.txt';

% load graph
graph = loadGraph(graphPath);

% load truth communities
comm = loadCommunities(communityPath);

% choose a community from truth communities randomly
commId = randi(length(comm));

% choose 3 nodes from selected community randomly
seedId = randperm(length(comm{commId}),3);
seed = comm{commId}(seedId);

% detect community by YL
seed_vec = zeros(length(graph),1);
seed_vec(seed) = 1;
[set,l] = optimize_cluster(graph,seed_vec,'method','sort');
set = find(set);

% compute F1 score and Jaccard index
jointSet = intersect(set,comm{commId});
unionSet = union(set,comm{commId});
jointLen = length(jointSet);
unionLen = length(unionSet);

F1 = 2*jointLen/(length(set)+length(comm{commId}));
Jaccard = jointLen/unionLen;

% printing out result
fprintf('The detected community is')
disp(set')
fprintf('The F1 score and Jaccard index between detected community and ground truth community are %.3f and %.3f\n',F1,Jaccard)

% save out result
savePathandName = '../../Results/zachary/result_YL.txt';
dlmwrite(savePathandName,'The detected community is','delimiter','');
dlmwrite(savePathandName,set','-append','delimiter','\t','precision','%.0f');
dlmwrite(savePathandName,['The F1 score and Jaccard index between detected community and ground truth community are ' num2str(F1,'%.3f') ' and ' num2str(Jaccard,'%.3f')],'-append','delimiter','');

end
