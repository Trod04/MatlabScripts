function multi_MPC_SNR_calculator()
%path dir containing all the csv's for SNR calculation (make sure there are
%only MPC csv's in the dir)
PathDir = 'C:\Users\H162437\OneDrive for Business\documents_onedrive\workflow\2020_03_11_SNR_issue_cmb\69513628\snr_analysis_matlab';

%find all files in DIR
cd(PathDir);
listing = dir('**.csv');

%find num of CSVs
[numCsvs, ~] = size(listing);

%create cell CSV output array
CellData = {};

for x = 1 :numCsvs
    currentCsvName = listing(x).name;
    
    FullDir = strcat(PathDir,'\', currentCsvName);

    data=importdata(FullDir, ',',0);
    MPCdata=data.data;

    %trim off excessive data
    MPCdata = MPCdata(:, 30:end-10);

    %determine pathNums
    [numPaths, ~ ]= size(MPCdata);
    numPaths = numPaths / 2;

    %calculate SNR value for each path
    
    try

        for i = 1:numPaths
            for y = 1:2
            %gather data   
            currentLine = (i-1)*2 + y;    
            currentDataset = MPCdata(currentLine,:);

            %find index of max peak to find limit between signal and noise
            [~,indexMaxPeak] = max(currentDataset);

            if indexMaxPeak < 250
                signalStart = indexMaxPeak - 100;
            else
                signalStart = indexMaxPeak - 200;
            end

            %split up data in noise and signal package
            signalNoise = currentDataset(20:signalStart);
            signalUsefull = currentDataset(signalStart:end);

            %determine Pk to Pk noise and usefull signal
            noisePkToPk = abs(min(signalNoise)) + max(signalNoise);
            signalPkToPk = abs(min(signalUsefull)) + max(signalUsefull);

            %calculate SNR values
            noiseratio = signalPkToPk / noisePkToPk;
            currentSNR = 20 *log10(noiseratio);

            %save values into array
            SNRval(i,y) = currentSNR;    
            end
        end
    
    catch errorOutput
        strError = strcat('Error in processing ', currentCsvName,  'pulse ', num2str(i));
        
        if y == 1
            disp(strcat(strError, ' ,Side A'));
        else
            disp(strcat(strError, ' ,Side B'));
        end
        
        disp(errorOutput);
    end

    %add average values A and B side to dataArray
    for i = 1:numPaths
        currentAverageSNR = mean(SNRval(i,1:2));
        SNRval(i,3) = currentAverageSNR;   
    end    
    
    %add results to cell array
    strCellName = [cellstr(listing(x).name),cellstr('NaN'), cellstr('NaN')];
    resultConversion = num2cell(SNRval);    
    CellData = [CellData; strCellName];
    CellData = [CellData; resultConversion];

end

%write results to output file
cell2csv('SNR_results.csv', CellData);


end

