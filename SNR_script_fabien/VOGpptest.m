function [ validVOGppTest, resultVOGpp, maxdevVOGpp, VOGpp, VOGppband ] = VOGpptest(fidLog, CT, posCSV, LoggedData)

%initialize return parameters
validVOGppTest = 0;
resultVOGpp =0;
maxdevVOGpp = 0;
VOGpp = 0;
VOGppband = 0;

try   
    %get info
    [numRows, ~] = size(LoggedData);
    numPaths = LoggedData(1,1);
    
    VOGpp = LoggedData(:,posCSV.VoGpp:(posCSV.VoGpp + (numPaths - 1)));

    maxdevVOGpp = CT.VGAS(4);
    
    %write info test to logfile
    testInfoToLog(fidLog, 'VoGpp max offset', 2);
    WriteToLogFile(fidLog, strcat('VoGpp NoOfPaths: ', num2str(numPaths)));
    WriteToLogFile(fidLog, strcat('VoGpp Max deviation Paths: ', num2str(maxdevVOGpp)));
    

    %generate abs diff & min/max band for plotting
    VOGppband(2,numRows) = 0;

    for i = 1: numRows
        VOGppband(1,i) = maxdevVOGpp;
        VOGppband(2,i) = -maxdevVOGpp;
    end

    %generate results
    resultVOGpp(2,numPaths) = 0;

    for i = 1:numPaths
        if max(abs(VOGpp(:,i))) > maxdevVOGpp
            resultVOGpp(1,i) = 1;
        end
        if mean(VOGpp(:,i)) > 0
            resultVOGpp(2,i) = max(VOGpp(:,i));
        else
            resultVOGpp(2,i) = min(VOGpp(:,i));
        end
    end
    
    %write end test to logfile
    WriteToLogFile(fidLog,'VoGpp tests succeeded');
    %return valid test boolean
    validVOGppTest = 1;
    
    
catch err
    WriteToLogFile(fidLog,'Error in performing VoGpp tests');
    WriteToLogFile(fidLog,err.message) ;
    return;    
end

end