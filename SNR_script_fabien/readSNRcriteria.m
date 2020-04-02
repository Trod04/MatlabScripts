function [snrCriteria] = readSNRcriteria()
%get the SNR criteria from the root NTB folder

currentFolder = 'C:\SNRdata_NTB';
fileName = 'SNRcriteria.crit';

fullPath = strcat(currentFolder, '\', fileName);

rawData = csvread(fullPath);

snrCriteria.RMS_limit  = rawData(1,1);
snrCriteria.WN_limit  = rawData(1,2);
snrCriteria.fr_length  = rawData(1,3);


end

