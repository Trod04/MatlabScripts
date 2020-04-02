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
    
    [dataSize, rowLenght] = size(numData);
    
    %delete double lines
    currentPath = 8; %temp value works for qmax meters only
    currentSide = 2;
    
    for i = dataSize:-1:1
        csvPathval = numData(i,1);
        csvSideval = numData(i,2);
        
        if   csvPathval == currentPath &&  csvSideval == currentSide
            %go down in currentpath or currentside
            if currentSide == 2
                currentSide = 1;
            else
                currentPath = currentPath - 1;
                currentSide = 2;
            end
        else
            %delete faulty row
            numData(i,:) = [];
        end
    end
    
    %trim second row of nan values in case of tracking window
    
    [dataSize, ~] = size(numData);
    
    shortestNanRowSize = rowLenght;

    
    for i = 1:dataSize
       for y = rowLenght:-1:0
           if ~isnan(numData(i,y))
               if y < shortestNanRowSize
                   shortestNanRowSize = y
               end
               break;
           end
       end
    end

    numData = numData(:,1:shortestNanRowSize);
    
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

