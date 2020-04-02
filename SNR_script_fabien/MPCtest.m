function [ validMPCtest, MPCPulseTops, MPCPeakRatios, MPCSecondWaves, MPCSnr ] = MPCtest(MeterDir, pathConfig, PathCT, CT, numCSV, CSVdata, fidRF, fidLog, PulseSB)
%Function processes the MPC file according to the generated criteria in the
%following order:
%file
%8 plot the signals: actual signal and schematic view

%7 the least good results will be generated to compile a general results
%9 Generate tables



%initialize return parameters
validMPCtest = 0;
MPCPulseTops = 0;
MPCPeakRatios = 0;
MPCSecondWaves = 0;
MPCSnr = 0;

try
    %log starting MPC tests
    %######################################################################
    testInfoToLog(fidLog, 'MPCTESTS', 1);
    
    
    %execute all subtests
    %######################################################################
    
    [numPaths,~]  = size(PathCT);
    
    for i = 1:numPaths
        TrLetter='ab';
        for j = 1:2
            CurrentSignal = [];
            CurrentPosPeakSig = [];
            CurrentNegPeakSig = [];
            CurrentPltLimits = [];
            CurrentPulseResults = [];
            CurrentInvChkResults = [];
            SnrDetails = [];
            
            for k = 1:numCSV 

                %eval(['CSVdata.CSV', num2str(k), '.t', num2str(i), TrLetter(j), '.Puls = numData(I,27:col-6);']);

                %Current pulse
                eval(['signal = CSVdata.CSV', num2str(k), '.t', num2str(i), TrLetter(j), '.Puls;']);
                eval(['detection = CSVdata.CSV', num2str(k), '.t', num2str(i), TrLetter(j), '.DetectionPoint;']);
                currPathCT = PathCT(i,:);
                currPathCT(1,end) = CT.DETECTION(1,i);
                strCurrPath = strcat('t', num2str(i), TrLetter(1,j));
                

                %process pulse                  
                [validPeakSearch, nSig, posPeakSig, negPeakSig, pltLimits, pulseResults, ValidDetection, VirtualDetection, currentSnrDetails ] = PulseProcess(fidLog, signal, detection, currPathCT, strCurrPath, numCSV, PulseSB);

                %determine if inversion in correct   
                [validInvChk, InvChkResults ] = checkInversion(fidLog, CT, nSig, detection, ValidDetection, strCurrPath, numCSV);
                
                currpath = strcat('t', num2str(i), TrLetter(1,j));
                
                if ~(validPeakSearch && validInvChk)
                   WriteToLogFile(fidLog,'Processed Data incomplete --> test terminated'); 
                   return;
                end                   
                
                %bundle results
                CurrentSignal = [CurrentSignal; nSig.signalNorm];
                CurrentPosPeakSig(k,:,:) = posPeakSig;
                CurrentNegPeakSig(k,:,:) = negPeakSig;
                CurrentPltLimits(k,:,:) = pltLimits;
                CurrentPulseResults(k,:,:) = pulseResults;
                CurrentInvChkResults(k,:) = InvChkResults;
                CurrentValidDetection(k,:) = ValidDetection;
                CurrentVirtualDetection(k,:) = VirtualDetection;
                
                %additional info script Fabien
                SnrDetails = [SnrDetails; currentSnrDetails];
                
            end
            
            eval(['processedData.t', num2str(i), TrLetter(j), '.nSig = CurrentSignal;']);
            eval(['processedData.t', num2str(i), TrLetter(j), '.posPeakSig = CurrentPosPeakSig;']);
            eval(['processedData.t', num2str(i), TrLetter(j), '.negPeakSig = CurrentNegPeakSig;']);
            eval(['processedData.t', num2str(i), TrLetter(j), '.pltLimits = CurrentPltLimits;']);
            eval(['processedData.t', num2str(i), TrLetter(j), '.pulseResults = CurrentPulseResults;']);
            eval(['processedData.t', num2str(i), TrLetter(j), '.InvChkResults = CurrentInvChkResults;']);
            eval(['processedData.t', num2str(i), TrLetter(j), '.ValidDetection = CurrentValidDetection;']);
            eval(['processedData.t', num2str(i), TrLetter(j), '.VirtualDetection = CurrentVirtualDetection;']);
            
            %bundled snr data i = path number, j = path side (a = 1, b = 2)
            snrDataPath.path(i).side(j).SnrDetails = SnrDetails;
                        
        end
    end
    
    %publish results
    %######################################################################
    
    writeToResultsMPC( fidLog, fidRF, numCSV, numPaths, processedData, PulseSB);    

      
    %Compose least good values list for plots
    %######################################################################
    
    [validTable, tableData] = tableGen(fidLog, numCSV, numPaths, processedData);
    
    
    %execute all plots
    %######################################################################
    
    %create figures Folder
    createDir('figures',MeterDir,fidLog);
    
    %generate snr error code result table (script Fabien)
    
    snrErrorTable = genSnrErrorTable(numPaths, numCSV, snrDataPath);
    
    %generate SNR detail logfile
    SNRlogfile(CT,numPaths,numCSV,snrDataPath);
  
    %Generate noise table
    validNoiseTable = GenerateNoiseTable(MeterDir, fidLog, pathConfig, numPaths, tableData, snrErrorTable);   
   
    %plot different tests
    validPltMPC = plotPulse(MeterDir, fidLog, pathConfig, numPaths, numCSV, processedData, tableData, CSVdata);

    %if no errors accured, return valid parameter
    %######################################################################
       
    if validNoiseTable && validTable  && validPltMPC
        validMPCtest = 1;
        WriteToLogFile(fidLog,'MPC tests succesfully terminated');      
    else
        WriteToLogFile(fidLog,'Couldnt execute one or more subtests');
    end
catch err
    WriteToLogFile(fidLog,'Error in performing MPCtests');
    WriteToLogFile(fidLog,err.message) ;
    return;
end
    

end

