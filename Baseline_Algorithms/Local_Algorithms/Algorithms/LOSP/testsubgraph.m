function [Jaccard,F05,F1,F2,precision,recall] = testsubgraph(I,groundTruthComm)
% I: corresponding nodes with higher weight
% Precision = intersect / detected
% Recall = intersect / truth
% F1 = 2(Presision*Recall)/ (Presision+Recall), will get the same value if Precision = Recall

detectedSize = length(I);
truthSize  = length(groundTruthComm);

intersectSize = length(intersect(I,groundTruthComm));
unionSize = length(union(I,groundTruthComm));
Jaccard = intersectSize/unionSize;

precision = intersectSize / detectedSize;
recall = intersectSize / truthSize;

if(precision == 0 && recall == 0)
    F05 = 0;
    F1 = 0;
    F2 = 0;
else
    F05 = (5*precision*recall)/ (precision+4*recall);
    F1 = (2*precision*recall)/ (precision+recall);
    F2 = (5*precision*recall)/ (4*precision+recall);
end

end
