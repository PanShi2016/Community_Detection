function F1 = GetF1score(detectedComm,truthComm)
% compute F1 score

row1 = length(detectedComm);
row2 = length(truthComm);

F1Mat = zeros(row1,row2);

% compute F1 score of the best matching detected community to each truth community
for i = 1 : row2
    for j = 1 : row1
        jointset = intersect(detectedComm{j},truthComm{i});
        F1Mat(j,i) = 2*length(jointset)/(length(detectedComm{j})+length(truthComm{i}));
    end
end
truthF1 = sum(max(F1Mat))/row2;

% compute F1 score of the best matching truth community to each detected community
for i = 1 : row1
    for j = 1 : row2
        jointset = intersect(detectedComm{i},truthComm{j});
        F1Mat(i,j) = 2*length(jointset)/(length(detectedComm{i})+length(truthComm{j}));
    end
end
detectedF1 = sum(max(F1Mat'))/row1;

% compute average F1 score
F1 = (truthF1+detectedF1)/2;

end
