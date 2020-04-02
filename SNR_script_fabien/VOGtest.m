function [ validVOGTest, resultVOG, maxdevVOG, VOG, VOGband ] = VOGtest(fidLog, CT, posCSV, LoggedData)

%initialize return parameters
validVOGTest = 0;
resultVOG = 0;
maxdevVOG = 0;
VOG = 0; 
VOGband = 0;

try   
    %get info
    [numRows, ~] = size(LoggedData);

    VOG = LoggedData(:,posCSV.VoG);

    maxdevVOG =  CT.VGAS(3);
    
    %write info test to logfile
    testInfoToLog(fidLog, 'VoGGeneral', 2);
    WriteToLogFile(fidLog, strcat('Bandwidth Max deviation General: ', num2str(maxdevVOG)));
    

    %generate abs diff & min/max band for plotting
    VOGband(2,numRows) = 0;

    for i = 1: numRows
        VOGband(1,i) = -maxdevVOG;
        VOGband(2,i) = maxdevVOG;
    end

   %generate results
    resultVOG(2,1) = 0;

    if max(abs(VOG)) > maxdevVOG
        resultVOG(1,1) = 1;
    end
    if mean(VOG) > 0
        resultVOG(2,1) = max(VOG);
    else
        resultVOG(2,1) = min(VOG);
    end
    
    %write end test to logfile
    WriteToLogFile(fidLog,'VOG general test succeeded');
    %return valid test boolean
    validVOGTest = 1;
    
    
catch err
    WriteToLogFile(fidLog,'Error in performing VOG general test');
    WriteToLogFile(fidLog,err.message) ;
    return;    
end

end
