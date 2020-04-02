function [ validPublish ] = PublishResults(pulseData,handles)
%publish results into table
validPublish = 0;

try
    voltage = pulseData.nSig.Vptp/1000;
    P4P2 = round((pulseData.pulseResult(1,1)*100))/100;
    P3P1 = round((pulseData.pulseResult(1,2)*100))/100;
    N4N2 = round((pulseData.pulseResult(1,3)*100))/100;
    N3N1 = round((pulseData.pulseResult(1,4)*100))/100;
    SW = round((pulseData.pulseResult(1,5)*100))/100;
    SNR = round((pulseData.pulseResult(1,6)*100))/100;
    
    results = [voltage; P3P1; P4P2; N3N1; N4N2; SNR; SW] ;    
    strResults = num2str(results);
    cellResults = cellstr(strResults)
    cellResults{1} = strcat(strResults(1,:), ' V');
    cellResults{6} = strcat(strResults(6,:), ' dB');
    
    table = get(handles.tblResults,'data');
    table(:,1) = cellResults;    
    set(handles.tblResults,'data',table);    

    %write event to logfile
    WriteToLogFile(handles.fidLog,'Results were published succesfully');
    validPublish = 1;
    
catch err
    WriteToLogFile(handles.fidLog,'Error in Publishing table results');
    WriteToLogFile(handles.fidLog,err.message) ;
    return;
end

end

