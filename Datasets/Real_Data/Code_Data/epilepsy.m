function [] = epilepsy()
% Process epilepsy dataset

dataPath = '../Original_Data/epilepsy/';
savePath = '../Processed_Data/';

% load sz1_pre.dat - sz8_pre.dat and sz1_ict.dat - sz8_ict.dat
sz1_pre = load([dataPath,'sz1_pre.dat']);
sz2_pre = load([dataPath,'sz2_pre.dat']);
sz3_pre = load([dataPath,'sz3_pre.dat']);
sz4_pre = load([dataPath,'sz4_pre.dat']);
sz5_pre = load([dataPath,'sz5_pre.dat']);
sz6_pre = load([dataPath,'sz6_pre.dat']);
sz7_pre = load([dataPath,'sz7_pre.dat']);
sz8_pre = load([dataPath,'sz8_pre.dat']);

sz1_ict = load([dataPath,'sz1_ict.dat']);
sz2_ict = load([dataPath,'sz2_ict.dat']);
sz3_ict = load([dataPath,'sz3_ict.dat']);
sz4_ict = load([dataPath,'sz4_ict.dat']);
sz5_ict = load([dataPath,'sz5_ict.dat']);
sz6_ict = load([dataPath,'sz6_ict.dat']);
sz7_ict = load([dataPath,'sz7_ict.dat']);
sz8_ict = load([dataPath,'sz8_ict.dat']);

sz1_pre = sparse(sz1_pre);
sz2_pre = sparse(sz2_pre);
sz3_pre = sparse(sz3_pre);
sz4_pre = sparse(sz4_pre);
sz5_pre = sparse(sz5_pre);
sz6_pre = sparse(sz6_pre);
sz7_pre = sparse(sz7_pre);
sz8_pre = sparse(sz8_pre);

sz1_ict = sparse(sz1_ict);
sz2_ict = sparse(sz2_ict);
sz3_ict = sparse(sz3_ict);
sz4_ict = sparse(sz4_ict);
sz5_ict = sparse(sz5_ict);
sz6_ict = sparse(sz6_ict);
sz7_ict = sparse(sz7_ict);
sz8_ict = sparse(sz8_ict);

save([savePath,'epilepsy'],'sz1_pre','sz2_pre','sz3_pre','sz4_pre','sz5_pre','sz6_pre','sz7_pre','sz8_pre','sz1_ict','sz2_ict','sz3_ict','sz4_ict','sz5_ict','sz6_ict','sz7_ict','sz8_ict','-v7.3');

end
