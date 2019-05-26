function NMI = GetCoverNMI(truthComm,detectedComm)
% NMI: Normalized Mutual Information for cover
% NMI is a measure of similarity between truth communities and detected communities
% The value of NMI falls in range [0,1], higher the NMI value, better the community detection algorithm

truthNum = length(truthComm);
detectedNum = length(detectedComm);

% Convert cell array to numeric array
truthMat = cell2mat(truthComm);
detectedMat = cell2mat(detectedComm);
N = length(union(truthMat,detectedMat));

% calculate conditional entropy
Hxy = zeros(truthNum,detectedNum);
Hyx = zeros(detectedNum,truthNum);
Hx = zeros(truthNum,1);
Hy = zeros(detectedNum,1);
H_X = 0;
H_Y = 0;

for i = 1 : truthNum
    px1 = length(truthComm{i})/N;
    px0 = 1 - px1;
    for j = 1 : detectedNum
        p11 = length(intersect(truthComm{i},detectedComm{j}))/N;
        p10 = length(truthComm{i})/N - p11;
        p01 = length(detectedComm{j})/N - p11;
        p00 = 1 -  length(union(truthComm{i},detectedComm{j}))/N;
        py1 = length(detectedComm{j})/N;
        py0 = 1 - py1;
        if (GetEntropy(p11)+GetEntropy(p00)) <= (GetEntropy(p10)+GetEntropy(p01))
            Hxy(i,j) = GetEntropy(px1) + GetEntropy(px0);
        else
            Hxy(i,j) = GetEntropy(p11) + GetEntropy(p10) + GetEntropy(p01) + GetEntropy(p00) - (GetEntropy(py1) + GetEntropy(py0));
        end
    end
    [Hx(i),I] = min(Hxy(i,:));
    if Hx(i) == 0
        H_X = H_X + 0;
    else
        H_X = H_X + Hx(i)/(truthNum*(GetEntropy(px1)+GetEntropy(px0)));
    end
end

for i = 1 : detectedNum
    py1 = length(detectedComm{i})/N;
    py0 = 1 - py1;
    for j = 1 : truthNum
        p11 = length(intersect(detectedComm{i},truthComm{j}))/N;
        p10 = length(detectedComm{i})/N - p11;
        p01 = length(truthComm{j})/N - p11;
        p00 = 1 -  length(union(detectedComm{i},truthComm{j}))/N;
        px1 = length(truthComm{j})/N;
        px0 = 1 - px1;
        if (GetEntropy(p11)+GetEntropy(p00)) <= (GetEntropy(p10)+GetEntropy(p01))
            Hyx(i,j) = GetEntropy(py1) + GetEntropy(py0);
        else
            Hyx(i,j) = GetEntropy(p11) + GetEntropy(p10) + GetEntropy(p01) + GetEntropy(p00) - (GetEntropy(px1) + GetEntropy(px0));
        end
    end
    [Hy(i),I] = min(Hyx(i,:));
    if Hy(i) == 0
        H_Y = H_Y + 0;
    else
        H_Y = H_Y + Hy(i)/(detectedNum*(GetEntropy(py1)+GetEntropy(py0)));
    end
end

% compute NMI
NMI = 1 - 0.5*(H_X + H_Y);

end

function h = GetEntropy(p)
if p <= 0
    h = 0;
else
    h = -p*log(p);
end

end
