function writeToResultsMPC( fidLog, fidRF, numCSV, numPaths, processedData, PulseSB)

try  
    TrLetter='ab';
    
    %publish peak ratios to results
    for i = 1: numPaths
        for j = 1: 2
            for k = 1:numCSV
                CurrentResult(3,7) = 0;
                eval(['CurrentResult(:,:) = processedData.t', num2str(i), TrLetter(j), '.pulseResults(k,1:3,:);']);
                %force positive current results detectionpoint with SB
                if PulseSB
                    CurrentResult(1,7) = 1;
                end
                
                %get current detection validation --> disable with SB pulse
                %analysis (force positive result)
                if PulseSB
                    CurrentDetection = 1;
                else
                    eval(['CurrentDetection = processedData.t', num2str(i), TrLetter(j), '.InvChkResults;']);
                end
                
                tdName = ['t', num2str(i), TrLetter(j)];                
                for l = 1:7
                    switch l
                        case 1
                            if CurrentResult(1,l)
                                fwrite(fidRF, [ 'PR; ' , tdName , '; ' , num2str(k) , '; P4P2; OK; ', num2str(CurrentResult(2,l)) ,  '; MAX; ' , num2str(CurrentResult(3,l))]);
                                fprintf(fidRF,'\n'); 
                            else
                                fwrite(fidRF, [ 'PR; ' , tdName , '; ' , num2str(k) , '; P4P2; FAULT; ', num2str(CurrentResult(2,l)) ,  '; MAX; ' , num2str(CurrentResult(3,l))]);
                                fprintf(fidRF,'\n'); 
                            end
                        case 2
                            if CurrentResult(1,l)
                                fwrite(fidRF, [ 'PR; ' , tdName , '; ' , num2str(k) , '; P3P1; OK; ', num2str(CurrentResult(2,l)) ,  '; MIN; ' , num2str(CurrentResult(3,l))]);
                                fprintf(fidRF,'\n'); 
                            else
                                fwrite(fidRF, [ 'PR; ' , tdName , '; ' , num2str(k) , '; P3P1; FAULT; ', num2str(CurrentResult(2,l)) ,  '; MIN; ' , num2str(CurrentResult(3,l))]);
                                fprintf(fidRF,'\n'); 
                            end                            
                        case 3
                            if CurrentResult(1,l)
                                fwrite(fidRF, [ 'PR; ' , tdName , '; ' , num2str(k) , '; N4N2; OK; ', num2str(CurrentResult(2,l)) ,  '; MAX; ' , num2str(CurrentResult(3,l))]);
                                fprintf(fidRF,'\n'); 
                            else
                                fwrite(fidRF, [ 'PR; ' , tdName , '; ' , num2str(k) , '; N4N2; FAULT; ', num2str(CurrentResult(2,l)) ,  '; MAX; ' , num2str(CurrentResult(3,l))]);
                                fprintf(fidRF,'\n'); 
                            end
                        case 4
                            if CurrentResult(1,l)
                                fwrite(fidRF, [ 'PR; ' , tdName , '; ' , num2str(k) , '; N3N1; OK; ', num2str(CurrentResult(2,l)) ,  '; MIN; ' , num2str(CurrentResult(3,l))]);
                                fprintf(fidRF,'\n'); 
                            else
                                fwrite(fidRF, [ 'PR; ' , tdName , '; ' , num2str(k) , '; N3N1; FAULT; ', num2str(CurrentResult(2,l)) ,  '; MIN; ' , num2str(CurrentResult(3,l))]);
                                fprintf(fidRF,'\n'); 
                            end    
                            
                        case 5
                            if CurrentResult(1,l)
                                fwrite(fidRF, ['PR; ' , tdName , '; ' , num2str(k) , '; SWL; OK; ', num2str(CurrentResult(2,l)) ,  '; MIN; ' , num2str(CurrentResult(3,l))]);
                                fprintf(fidRF,'\n'); 
                            else
                                fwrite(fidRF, ['PR; ' , tdName , '; ' , num2str(k) , '; SWL; FAULT; ', num2str(CurrentResult(2,l)) ,  '; MIN; ' , num2str(CurrentResult(3,l))]);
                                fprintf(fidRF,'\n'); 
                            end
                            
                        case 6
                            if CurrentResult(1,l)
                                fwrite(fidRF, ['SN; ' , tdName , '; ' , num2str(k) , '; SNR; OK; ', num2str(CurrentResult(2,l)) ,  '; MIN; ' , num2str(CurrentResult(3,l))]);
                                fprintf(fidRF,'\n'); 
                            else
                                fwrite(fidRF, ['SN; ' , tdName , '; ' , num2str(k) , '; SNR; FAULT; ', num2str(CurrentResult(2,l)) ,  '; MIN; ' , num2str(CurrentResult(3,l))]);
                                fprintf(fidRF,'\n'); 
                            end
                            
                        case 7
                            if CurrentDetection
                                fwrite(fidRF, ['DT; ' , tdName , '; ' , num2str(k) , '; DET; OK; ', '0; 0; 0; ' ]);
                                fprintf(fidRF,'\n'); 
                            else
                                fwrite(fidRF, ['DT; ' , tdName , '; ' , num2str(k) , '; DET; FAULT; ', '0; 0; 0; ' ]);
                                fprintf(fidRF,'\n'); 
                            end
                            
                    end      
                end
                if isempty(find(CurrentResult(1,:)==0))
                    fwrite(fidRF, ['GENERAL; ' , tdName , '; ' , num2str(k) , '; 3.125; -1; 0; OK']);
                    fprintf(fidRF,'\n');
                else
                    fwrite(fidRF, ['GENERAL; ' , tdName , '; ' , num2str(k) , '; 3.125; -1; 0; FAULT']);
                    fprintf(fidRF,'\n');
                end
            end
            
        end
    end

    
    %publish plot coordinates to results
    %positive plots

    for i = 1: numPaths
        for j = 1: 2
            for k = 1:numCSV
                CurrentPlot(3,7) = 0;
                eval(['CurrentPlot(:,1:6) = processedData.t', num2str(i), TrLetter(j), '.posPeakSig(k,:,:);']);
                eval(['CurrentPlot(2:3,7) = processedData.t', num2str(i), TrLetter(j), '.pltLimits(k,1:2,3);']);
                tdName = ['t', num2str(i), TrLetter(j)];
                for l = 1:6
                    fwrite(fidRF, [ 'PL; ' , tdName , '; ' , num2str(k) , '; P',  num2str(l-1), '; ', num2str(CurrentPlot(3,l)), '; ', num2str(CurrentPlot(2,l)) ]);
                    fprintf(fidRF,'\n'); 
                end
                fwrite(fidRF, [ 'PL; ' , tdName , '; ' , num2str(k) , '; PMAX; ', num2str(CurrentPlot(3,7)), '; ', num2str(CurrentPlot(2,7)) ]);
                fprintf(fidRF,'\n'); 
            end
            
        end
    end

    %negative peaks
    
    for i = 1: numPaths
        for j = 1: 2
            for k = 1:numCSV
                CurrentPlot(3,7) = 0;
                eval(['CurrentPlot(:,1:6) = processedData.t', num2str(i), TrLetter(j), '.negPeakSig(k,:,:);']);
                eval(['CurrentPlot(2:3,7) = processedData.t', num2str(i), TrLetter(j), '.pltLimits(k,3:4,3);']);
                tdName = ['t', num2str(i), TrLetter(j)];
                for l = 1:6
                    fwrite(fidRF, [ 'PL; ' , tdName , '; ' , num2str(k) , '; N',  num2str(l-1), '; ', num2str(CurrentPlot(3,l)), '; ', num2str(CurrentPlot(2,l)) ]);
                    fprintf(fidRF,'\n'); 
                end
                fwrite(fidRF, [ 'PL; ' , tdName , '; ' , num2str(k) , '; NMAX; ', num2str(CurrentPlot(3,7)), '; ', num2str(CurrentPlot(2,7)) ]);
                fprintf(fidRF,'\n'); 
            end
            
        end
    end

    WriteToLogFile(fidLog, 'Testresults were succesfully written to resultsfile');

catch err
    WriteToLogFile(fidLog, 'Error in writing too resultsfile');
    WriteToLogFile(fidLog,err.message) ;
end

end

