function [ validTest, resultKTpath, resultKTfat, resultRelFAT, maxdevPath, maxdevFAT, maxDevRel, DevPathFAT, relDev, absDev  ] = ktDiff(fidLog, CT, posCSV, LoggedData)

%initialize return parameter
validTest = 0; 
resultKTpath = 0;
resultKTfat = 0;
resultRelFAT = 0;
DevPaths = 0;
DevPathFAT = 0;
relDev = 0;
maxdevPath = 0;
maxdevFAT = 0;
maxDevRel = 0;

try
       
    maxdevPath = CT.VOS(1);
    maxdevFAT = CT.VOS(2);
    maxdevRelative = (CT.VOS(3)/100);
    numPaths = LoggedData(1,1);
    vosPaths = LoggedData(:,posCSV.VoSpp:(posCSV.VoSpp + (numPaths - 1)));
    vosFAT = LoggedData(:,posCSV.VoSFAT);
    maxDevRel = (max(vosFAT(:,1)) * maxdevRelative);


    %write info test to logfile
    testInfoToLog(fidLog, 'ktDiff', 2);
    WriteToLogFile(fidLog, strcat('ktDiff NoOfPaths: ', num2str(numPaths)));
    WriteToLogFile(fidLog, strcat('ktDiff Max deviation Paths: ', num2str(maxdevPath)));
    WriteToLogFile(fidLog, strcat('ktDiff Max deviation Path 2 VoSFAT: ', num2str(maxdevFAT)));
    WriteToLogFile(fidLog, strcat('ktDiff Max relative deviation to VoSFAT: ', num2str(maxdevFAT)));


    [numRows, ~]=size(vosPaths);
    resultKTpath(2,numPaths)= 0;
    resultKTfat(2,numPaths)=0;
    resultRelFAT(2,numPaths)=0;
    DevPaths(numRows, numPaths) = 0;
    DevPathFAT(numRows, numPaths) = 0;
    absDevPathFAT(numRows, numPaths) = 0;
    relDev(numRows,2)= 0;

    for h = 1: numRows
        %determine which path from the row comes closest to the actual FAT VoS
        %value, to use as comparision for the other 
        for j = 1: numPaths
            if j == 1
                vosDiff = abs(vosPaths(h,1) - vosFAT(h));
                index = 1;
            else
               if vosDiff > abs(vosPaths(h,j) - vosFAT(h))
                  index = j;
                  vosDiff = abs(vosPaths(h,j) - vosFAT(h));
               end
            end
        end
        toCompare = vosPaths(h,index);
        %generate array with error results: 0 = path ok, 1 = error on path
        for i = 1: numPaths
            %Compare VoS deviation between paths
            if abs(toCompare - vosPaths(h,i)) > maxdevPath
                resultKTpath(1,i) = 1;
            end

            %List deviations between paths
            DevPaths(h,i) = abs(toCompare - vosPaths(h,i));

            %Compare VoS deviation between path & theoretical VoS Fattool
            if abs(vosFAT(h) - vosPaths(h,i)) > maxdevFAT
                resultKTfat(1,i) = 1;
            end

            %List deviations between paths
            DevPathFAT(h,i) = vosFAT(h) - vosPaths(h,i);
            absDevPathFAT(h,i) = abs(vosFAT(h) - vosPaths(h,i));
        end
    end

    %determine maximum deviation for each path

    %max deviation paths
    for j = 1 : numPaths
        resultKTpath(2,j)=max(DevPaths(:,j));
    end

    %max deviation FAT
    for k = 1 : numPaths
        resultKTfat(2,k)=max(absDevPathFAT(:,k));
    end
    
    %generate relative deviation values
    for l = 1: numRows
        relDev(l,1)= (vosFAT(l,1) * maxdevRelative);
    end
    
    for p = 1: numRows
        relDev(p,2) = - relDev(p,1);
    end
    
    
    %generate absolute deviation values
    absDev(1:numRows,1)= maxdevFAT;
    absDev(1:numRows,2)= -maxdevFAT;
    
    %check if relative deviation is exeeded
    
   
    for m = 1 : numRows
        for n = 1 : numPaths
            if absDevPathFAT(m,n) > relDev(m,1)
                resultRelFAT(1,n)= 1;
            end
        end
    end
    
    %max relative deviation
    for o = 1 : numPaths
        resultRelFAT(2,o)=max(absDevPathFAT(:,o));
    end
    
    %write end test to logfile
    WriteToLogFile(fidLog,'KTdiffCHECK succeeded');
    %return valid test boolean
    validTest = 1;
    
catch err
    WriteToLogFile(fidLog,'Error in performing KTdiffCHECK');
    WriteToLogFile(fidLog,err.message) ;
    return;
end



end