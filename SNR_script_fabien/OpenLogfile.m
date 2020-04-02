function [ validLog, fidLog ] = OpenLogfile(MeterDir)
% logfile for analysis of UDATA Logfile

fidLog = -1; %initialise return parameters
validLog = 0;

try
    fullPathLog = strcat(MeterDir, '\AnalyseLogFile.txt');
    fidLog = fopen(fullPathLog,'w');
   
    if (fidLog > -1)
        validLog = 1;
        Version = GetVersionNumber();
        fprintf(fidLog,'\n');
        fprintf(fidLog,[datestr(now) ' logfile opened, Matlab Script Version: %s \n'],Version);
    end
catch err
    if (fidLog > -1)
        fprintf(fidLog,[err.message]);
    end
    % show in message box since no logfile is available
end
    
end
