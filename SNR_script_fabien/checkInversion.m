function [ validInvChk, InvChkResults ] = checkInversion(fidLog, CT, nSig, detection, ValidDetection, strCurrPath, numCSV)
%Checks if the inversion of the signal matches the inversion of the criteria

%initialize return parameters
validInvChk = 0;
InvChkResults = 0;

try
    if ValidDetection == 1
        signal = nSig.signalNorm;

        %check what detection is found by the meter, sample on detection point
        %>0 --> negative detection, <0 --> postive detection
        if signal(1,detection) > 0
            currentdetection = 0;
        else
            currentdetection = 1;
        end

        %check actual 
        if currentdetection == CT.DETECTION(1,1)
            InvChkResults = 1;
        else
            InvChkResults = 0;
        end

        %write finish test to logfile & set valid bit check
        validInvChk = 1;
        WriteToLogFile(fidLog, ['Inversion Check in CSV' , num2str(numCSV), ', tranducer ', strCurrPath, ' succesfully terminated']);      
    else
        WriteToLogFile(fidLog, ['Inversion Check can not be performed --> no valid detection point in CSV', num2str(numCSV), ', tranducer ', strCurrPath]);   
        validInvChk = 1;
        InvChkResults = 0;
    end

catch err
    WriteToLogFile(fidLog, ['Error in performing error check in CSV' , num2str(numCSV), ', tranducer ', strCurrPath]);
    WriteToLogFile(fidLog,err.message) ;
    return;
end


end

