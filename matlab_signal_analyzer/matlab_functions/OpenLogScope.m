function [ validLog, fidLog ] = OpenLogScope(FileDir)
fidLog = -1; %initialise return parameters
validLog = 0;
fullPathLog =  strcat(FileDir, '\general_log.txt');
fidLog = fopen(fullPathLog,'w')

if (fidLog > -1)
    validLog = 1;
    fprintf(fidLog,[datestr(now) ' logfile opened for MPCscope \n']);
end
    
end
