function SNRlogfile(CT,numPaths,numCSV,snrDataPath)
%generate logfile with the snr detail logfile

%compose filename
currentDateTime = char(datetime('now', 'Format','y_MM_dd_HH-mm-ss'));
meterSerial = num2str(CT.INFO{1,1});
fatRevision = CT.INFO{1,3};

filename = strcat(currentDateTime, '_SN_', num2str(meterSerial),'_FAT_', fatRevision, '_SNR_details.csv');
fileHeader = {'path', 'CSVnum', 'code', 'SNR_min', 'SNR_max', 'RMS', 'WN'};
TR_side = 'ab';

totalLogOutput = fileHeader;

for x = 1:numPaths
    for y = 1:2
        pathName = strcat('Path_', num2str(x), TR_side(y));
        csvNumArray = [1:numCSV]';
        
        cellPath = cell(numCSV,2);
        cellPath(:,1) = cellstr(pathName);
        cellPath(:,2) = num2cell(csvNumArray);
        
        currentTD = struct2cell(snrDataPath.path(x).side(y).SnrDetails)';
        
        pathTotal = [cellPath, currentTD];
        
        totalLogOutput = [totalLogOutput; pathTotal];        
    end    
end

currentpath = 'C:\SNRdata_NTB\FATS\';
csvFullPath = strcat(currentpath, filename);
cell2csv( csvFullPath, totalLogOutput, ';');

end

