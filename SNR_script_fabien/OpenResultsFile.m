function [ fidRF] = OpenResultsFile(MeterDir, fidLog)

fullPathRF = strcat(MeterDir, '\RESULTS.txt');
fidRF = fopen(fullPathRF,'w'); %create a new file for writing

if (fidRF > -1)
    WriteToLogFile(fidLog,'RESULTS.TXT opened');
else
    WriteToLogFile(fidLog,'Could not open RESULTS.TXT');
end

end

