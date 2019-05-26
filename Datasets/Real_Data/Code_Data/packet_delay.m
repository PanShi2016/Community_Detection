function [] = packet_delay()
% Process packet_delay dataset

dataPath = '../Original_Data/packet_delay/';
savePath = '../Processed_Data/';

% load FBR1output.delay
A = load([dataPath,'FBR1output.delay']);

dlmwrite([savePath,'packet_delay'],A,'delimiter','\t');

end
