function [] = LOSP(TruncateMode) 
% Local Spectral Method

% TruncateMode: 1: truncation by truth size, 2: truncation by local minimal conductance

if nargin < 1 
    TruncateMode = 2;
end

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

% grab subgraph from each seed set
[sample,~] = SampleGraph(seed,graph);
subgraph = graph(sample,sample);
[~,ind] = intersect(sample,seed);

if TruncateMode == 1
    % bound detected community by truth community size
    [Jaccard,F05,F1,F2,P,R,Size,Cond,detectedComm] = IterativeWorkTruth(graph,subgraph,ind,sample,comm{commId});
end

if TruncateMode == 2
    % bound detected community by local minimal conductance
    [Jaccard,F05,F1,F2,P,R,Size,Cond,detectedComm] = IterativeWorkConduct(graph,subgraph,ind,sample,comm{commId});
end

% printing out result
fprintf('The detected community is')
disp(detectedComm')
fprintf('The F1 score and Jaccard index between detected community and ground truth community are %.3f and %.3f\n',F1,Jaccard)

% save out result
savePathandName = '../../Results/zachary/result_LOSP.txt';
dlmwrite(savePathandName,'The detected community is','delimiter','');
dlmwrite(savePathandName,detectedComm','-append','delimiter','\t','precision','%.0f');
dlmwrite(savePathandName,['The F1 score and Jaccard index between detected community and ground truth community are ' num2str(F1,'%.3f') ' and ' num2str(Jaccard,'%.3f')],'-append','delimiter','');

end
