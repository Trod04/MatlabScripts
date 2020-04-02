function info2log(CTINFO, meterType, fidLog)
try
    WriteToLogFile(fidLog,'###########################################');
    WriteToLogFile(fidLog,'METER INFO:');
    WriteToLogFile(fidLog, strcat('Serialnumber: ', num2str(cell2mat(CTINFO(1,1)))));
    WriteToLogFile(fidLog, strcat('Number of paths: ', num2str(cell2mat(CTINFO(1,8)))));
    WriteToLogFile(fidLog, strcat('Fatrevision: ', cell2mat(CTINFO(1,3))));
    WriteToLogFile(fidLog, strcat('Metertype: ', meterType));
    WriteToLogFile(fidLog,'###########################################');
catch err
    WriteToLogFile(fidLog, 'error writing meterinfo to logfile');
end
end