function [typeCsv, validCSV, CSVdata] = LoadMpcNGQ(FileDir, fidlog)

%initialise return parameters
validCSV = 0;
numPaths = 1;
numMPCs = 1;
typeCsv = [numPaths, numMPCs];


try  
    %try open the selected file  
    data=importdata(FileDir, ',',0);
    numData=data.data;
    
    %determine number of paths and MPC number
    numPaths = max(numData(:,1));
    [cols, ~] = size(numData);
    numMPCs = cols / numPaths / 2;
    typeCsv = [numPaths, numMPCs];
    
    %trim data
    CSVdata = numData(:, 30:end-5);

    %test succeeded, set validCSV
    validCSV = 1;
    
    %write event to logfile
    WriteToLogFile(fidlog,'MPC files were loaded succesfully');
           
catch err
    try
        
    %try open the selected file
    data = csvread(FileDir,6);
    CSVdata = data(:,3)';

    %test succeeded, set validCSV
    validCSV = 1;
    
    %write event to logfile
    WriteToLogFile(fidlog,'MPC files were loaded succesfully');
        
    catch err
    %write event to logfile
    CSVdata = 0;
    WriteToLogFile(fidLog,'Error in loading MPC files');
    WriteToLogFile(fidLog,err.message) ;
    end
end      



end

