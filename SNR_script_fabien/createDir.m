function createDir(nameFolder,MeterDir,fidLog)
%function tries to create folder, if failed retry

try
    fullPath = strcat(MeterDir, '\', nameFolder);
    
    if ~(exist(fullPath) == 7)
        %maximum number of retries trying to create a folder
        numRetries = 10;
        
        %repeat trying to create folder until it is done OR when the
        %maximum retries are reached
        counter = 0;
        
        while ~(exist(fullPath) == 7) || counter > numRetries
            mkdir(fullPath);
            counter = counter + 1;
            if~(exist(fullPath) == 7)
                pause(1);
            end
        end
        
        %write results to logfile
        
        if (exist(fullPath) == 7)
            messageLog = strcat( nameFolder, ' folder was created succesfully');
            WriteToLogFile(fidLog, messageLog); 
        else
            messageLog = strcat( nameFolder, ' folder could not be created');
            WriteToLogFile(fidLog, messageLog); 
        end    
    end
catch err
    WriteToLogFile(fidLog,'Error in trying to create folder');
    WriteToLogFile(fidLog,err.message) ;
    return;
end

end

