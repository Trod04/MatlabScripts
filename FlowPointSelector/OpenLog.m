function [ validLog, fidLog ] = OpenLog(FileDir)
fidLog = -1; %initialise return parameters
validLog = 0;
fullPathLog =  strcat(FileDir, '\error_log.txt');
fidLog = fopen(fullPathLog,'w');

if (fidLog > -1)
    validLog = 1;
    fprintf(fidLog,[datestr(now) ' error logfile opened \n']);
end
    
end
