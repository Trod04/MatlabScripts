function [ validBandTest, resultsBand, Bandwidth, MinMaxBand ] = vosBandTest( fidLog, CT, posCSV, LoggedData )

%initialize return parameters
validBandTest = 0;
resultsBand =0;
MinMaxBand = 0;
Bandwidth = 0;

try   
    %get info
    [numRows, ~] = size(LoggedData);
    numPaths = LoggedData(1,1);
    
    vosPaths = LoggedData(:,posCSV.VoSpp:(posCSV.VoSpp + (numPaths - 1)));
    vosFAT = LoggedData(:,posCSV.VoSFAT);

    meanVos = mean(vosFAT);
    Bandwidth = CT.VOS(4);
    
    %write info test to logfile
    testInfoToLog(fidLog, 'Bandwidth', 2);
    WriteToLogFile(fidLog, strcat('Bandwidth NoOfPaths: ', num2str(numPaths)));
    WriteToLogFile(fidLog, strcat('Bandwidth Max deviation Paths: ', num2str(Bandwidth)));
    

    %generate abs diff & min/max band for plotting
    MinMaxBand(2,numRows) = 0;

    for i = 1: numRows
        MinMaxBand(1,i) = meanVos + Bandwidth;
        MinMaxBand(2,i) = meanVos - Bandwidth;
    end

    %generate list with absolute differences
    absDiff(numRows, numPaths)=0;

    for j = 1:numPaths
        for k = 1: numRows
            absdiff(k,j) = abs(meanVos- vosPaths(k,j));        
        end
    end

    %generate results
    resultsBand(2,numPaths) = 0;

    for l = 1:numPaths
        if max(absdiff(:,l)) > Bandwidth
            resultsBand(1,l) = 1;
        end
        resultsBand(2,l) = max(absdiff(:,l));
    end
    
    %write end test to logfile
    WriteToLogFile(fidLog,'Bandwidth test succeeded');
    %return valid test boolean
    validBandTest = 1;
    
    
catch err
    WriteToLogFile(fidLog,'Error in performing Bandwidth test');
    WriteToLogFile(fidLog,err.message) ;
    return;    
end

end

