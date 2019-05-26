function comm = loadCommunities(filename)
% comm: a cell, each element is a vector of the vtxId in one community
% fileformat: each row is a community

fin = fopen(filename,'r');
cid = 1; % community Id

while 1
    s = fgets(fin); % get one row for vertices in one community
    if (s == -1)
        break;   
    end
    id = sscanf(s,'%f');
    comm{cid} = id'; % vtxId
    cid = cid + 1;
end

fclose(fin);

end
