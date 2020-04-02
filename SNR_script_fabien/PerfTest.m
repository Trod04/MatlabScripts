function  [ ValidPerf, resultsPERmin, resultsPERavg, PerfMinLim, PerfAvgLim, PerfPP, LimitAvgBand, LimitMinBand ] = PerfTest(fidLog, CT, posCSV, LoggedData)

%checks if performance of individual paths of meter is within limts

%initialize return parameters
ValidPerf = 0;
resultsPERmin = 0;
resultsPERavg = 0;
PerfMinLim = 0;
PerfAvgLim = 0;
PerfPP = 0;
LimitAvgBand = 0;
LimitMinBand = 0;

try
    %get info
    
    numPaths = LoggedData(1,1); 
    [ numRows, ~ ] = size(LoggedData); 
    Samplerate = LoggedData(1,posCSV.SampleRate);
    SamplesPP = LoggedData(:,posCSV.ValidSamples:(posCSV.ValidSamples + (numPaths - 1)));
  
    PerfMinLim = CT.PERF(3);
    PerfAvgLim = CT.PERF(4);

    %create limit bands
    
    LimitMinBand(1:numRows,1) = PerfMinLim;
    LimitAvgBand(1:numRows,1) = PerfAvgLim;

    %calculate performance per Path
    
    PerfPP(numRows, numPaths) = 0;

    for i = 1:numPaths
        for j = 1: numRows
            PerfPP(j,i) = SamplesPP(j,i)/Samplerate;
        end
    end

    %determine if Minimum limit is exceeded
    resultsPERmin(2,numPaths)= 0;
    for i = 1:numPaths
       if min(PerfPP(:,i)) <  PerfMinLim
          resultsPERmin(1,i) = 1;
       end
       resultsPERmin(2,i) = min(PerfPP(:,i));
    end

    %determine if Average limit is exceeded
    resultsPERavg(2,numPaths) = 0;
    for i = 1:numPaths
       if mean(PerfPP(:,i)) <  PerfAvgLim
          resultsPERavg(1,i) = 1;
       end
       resultsPERavg(2,i) = mean(PerfPP(:,i));
    end
    
    
    %write end test to logfile
    WriteToLogFile(fidLog,'PERFORMANCE test succeeded');
    %return valid test boolean
    ValidPerf = 1;   

catch err
    WriteToLogFile(fidLog,'Error in performing PERFORMANCE test');
    WriteToLogFile(fidLog,err.message) ;
    return;   
end


 end

