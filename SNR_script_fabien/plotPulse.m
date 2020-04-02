function validPltMPC = plotPulse(MeterDir, fidLog, pathConfig, numPaths, numCSV, processedData, tableData, CSVdata)
%generate figure for eacht path of the meter

%initialize return parameters
validPltMPC = 0;

try

    
    
    TrLetter='ab';
    for i = 1: numPaths
        for j = 1:2
            plotName = ['Path ', num2str(i), ': ', char(pathConfig(2,i)), ' ', TrLetter(j)];
            fileName = ['t', num2str(i), TrLetter(j)];
            
            eval(['signal = processedData.t', num2str(i), TrLetter(j), '.nSig;']);
            eval(['posPeaks = processedData.t', num2str(i), TrLetter(j), '.posPeakSig;']);
            eval(['negPeaks = processedData.t', num2str(i), TrLetter(j), '.negPeakSig;']);
            eval(['pulseResults = processedData.t', num2str(i), TrLetter(j), '.pulseResults;']);
            eval(['detectionResults = tableData.t', num2str(i), TrLetter(j), '.tableresult(:,7);']);
            eval(['table = tableData.t', num2str(i), TrLetter(j), '.tableresult;']);
            eval(['detectionPoint = CSVdata.CSV1.t', num2str(i), TrLetter(j), '.DetectionPoint;']);
            
            %check if the first detectionpoint for plot zoom is valid, if
            %not --> use the biggest virtualdetecionpoint
            if detectionPoint < 100
                eval(['detectionPoint = max(processedData.t', num2str(i), TrLetter(j), '.VirtualDetection);']);
            end
            

            %check if foldername exists --> if not create folder with testname
           
            fullFilePath = strcat('figures\', fileName);
            createDir(fullFilePath, MeterDir, fidLog);  
    
            %zoominfo
            zoomDetectionPoint = 60;
            
            zoomStartX = detectionPoint - zoomDetectionPoint;
            
            zoomPosPeaks = posPeaks;
            zoomPosPeaks(:,2,:) = posPeaks(:,2,:) - zoomStartX;
            
            zoomNegPeaks = negPeaks;
            zoomNegPeaks(:,2,:) = negPeaks(:,2,:) - zoomStartX;
            
            zoomMax = 0;
            for z = 1:6
                temp = max(zoomPosPeaks(:,3,z));
                if temp > zoomMax
                    zoomMax = temp;
                end
            end
            
            
            zoomMin = 0;
            for z = 1:6
                temp = min(zoomNegPeaks(:,3,z));
                if temp < zoomMin
                    zoomMin = temp;
                end
            end
            
            zoomStartY = zoomMin * 1.05;
            
            if abs(zoomMin) > zoomMax
               zoomAmplitude = abs(zoomMin) * 1.05;
            else
               zoomAmplitude = zoomMax * 1.05;
            end
            
            zoomWindowHeight = (zoomMax + abs(zoomMin)) * 1.05;
            zoomWindowWidth = 120;
            zoomEnd = zoomStartX + zoomWindowWidth;
            
            %GENERAL FIGURE
            %-------------------------------------------
            
            
            %get number of samples
            [ ~ ,samples ] = size(signal);
            t=1:samples;

            %generate zeros for x axis
            xAxis=zeros(samples,1);

            %define y-axis
            amplitude = 1.05;
            
            %generate general figure
            f = figure();
            set(f, 'visible', 'off'); %don't plot to desktop
            set(f,'PaperUnits','centimeters','PaperPosition',[0 0 18 7])
            set(gca,'yticklabel',{[]}) 
            set(gca,'LooseInset',get(gca,'TightInset')) %get rid of whitespace
            
            title(plotName,'FontWeight','bold', 'FontSize', 12);
            xlabel('Samples');
            %ylabel('Amplitude');
            xlim([1,samples]);
            ylim([-amplitude,amplitude]);
            hold on;
           
          
            %plot samples
            for k = 1: numCSV
                plot(t,signal(k,:),'-b');
                hold on;
            end
            
            plot(t,xAxis,'k');
            hold on;
            
            %mark zoomed area
            
            rectangle;
            rectangle('Position',[zoomStartX,zoomStartY,zoomWindowWidth,zoomWindowHeight], 'EdgeColor', 'red', 'LineWidth', 1);
            hold on;                  
                        
            %plot limits


            eval(['maxPeakUsefull = processedData.t' num2str(i), TrLetter(j), '.pltLimits(1,2,2);']);
            eval(['minPeakUsefull = processedData.t' num2str(i), TrLetter(j), '.pltLimits(1,4,2);']);
            eval(['maxPeakTotal = processedData.t' num2str(i), TrLetter(j), '.pltLimits(1,2,3);']);
            eval(['maxPeakTotalSample = processedData.t' num2str(i), TrLetter(j), '.pltLimits(1,1,3);']);
            eval(['minPeakTotal = processedData.t' num2str(i), TrLetter(j), '.pltLimits(1,4,3);']);
            eval(['minPeakTotalSample = processedData.t' num2str(i), TrLetter(j), '.pltLimits(1,3,3);']);

            minPeakUsefullPlt = 0;
            minPeakUsefullPlt(1:samples,1) = minPeakUsefull;
            plot(t,minPeakUsefullPlt,':k');
            hold on;

            maxPeakUsefullPlt = 0;
            maxPeakUsefullPlt(1:samples,1) = maxPeakUsefull;
            plot(t,maxPeakUsefullPlt,':k');
            hold on;

            plot(maxPeakTotalSample,maxPeakTotal , 'o', 'MarkerEdgeColor','r', 'MarkerSize', 4, 'MarkerFaceColor', 'r');
            hold on;
            text(maxPeakTotalSample,maxPeakTotal + 0.03 ,'Pmax', 'FontWeight','bold', 'FontSize', 8)
            hold on;

            plot(minPeakTotalSample,minPeakTotal , 'o', 'MarkerEdgeColor','r', 'MarkerSize', 4, 'MarkerFaceColor', 'r');
            hold on;
            text(minPeakTotalSample,minPeakTotal - 0.03 ,'Nmin', 'FontWeight','bold', 'FontSize', 8)
            hold on;
            
            fullFileName = strcat(MeterDir, '\', fullFilePath, '\', fileName);
            saveas(gcf,fullFileName,'png');
            close(f);
            
            
            %ZOOM FIGURE
            %-------------------------------------------
            
            %get number of samples            
            t=1:zoomWindowWidth;

            %generate zeros for x axis
            xAxis=zeros(zoomWindowWidth,1);

            %define y-axis
            amplitude = zoomAmplitude;
            
            %generate general figure
            g = figure();
            set(g, 'visible', 'off'); %don't plot to desktop
            set(g,'PaperUnits','centimeters','PaperPosition',[0 0 8 6])
            set(gca,'yticklabel',{[]}) 
            set(gca,'xticklabel',{[]})
            set(gca,'LooseInset',get(gca,'TightInset')) %get rid of whitespace
            title('Signal Zoom','FontWeight','bold', 'FontSize', 12);
            xlim([1,zoomWindowWidth]);
            ylim([-amplitude,amplitude]);
            hold on;
           
          
            %plot samples
            
            for k = 1: numCSV
                zoomSig = signal(k,zoomStartX + 1:zoomEnd);
                plot(t,zoomSig,'-r');
                hold on;
            end
            
            plot(t,xAxis,'k');
            hold on;
        
            plot(zoomDetectionPoint, 0 , 'o', 'MarkerEdgeColor','c', 'MarkerSize', 5, 'MarkerFaceColor', 'c');
            hold on;
                        
            str1 = 'Det. Point';
            text(zoomDetectionPoint,-0.05 ,str1, 'FontWeight','bold', 'FontSize', 8);
            hold on;
            
            %plot peaks
            
            for m = 2 : 5
                for n = 1: numCSV
                    plot(zoomPosPeaks(n,2,m), zoomPosPeaks(n,3,m) , 'o', 'MarkerEdgeColor','b', 'MarkerSize', 5, 'MarkerFaceColor', 'b');
                    hold on;
                end
                str1 = ['P', num2str(zoomPosPeaks(n,1,m))];
                text(zoomPosPeaks(n,2,m) + 2,zoomPosPeaks(n,3,m)+0.03 ,str1, 'FontWeight','bold', 'FontSize', 8)
                hold on;
            end

            for m = 2 : 5
                for n = 1: numCSV
                    plot(zoomNegPeaks(n,2,m), zoomNegPeaks(n,3,m) , 'o', 'MarkerEdgeColor','g', 'MarkerSize', 5, 'MarkerFaceColor', 'g');
                    hold on;
                end
                str1 = ['N', num2str(zoomNegPeaks(n,1,m))];
                text(zoomNegPeaks(n,2,m) + 2,zoomNegPeaks(n,3,m)-0.03 ,str1, 'FontWeight','bold', 'FontSize', 8)
                hold on;
            end
            
            zoomFilename = strcat(fileName, '_zoom');
            
            fullFileName = strcat(MeterDir, '\', fullFilePath, '\', fileName, '_zoom');
            saveas(gcf,fullFileName,'png');        
              


            %TABLE FIGURE
            %-------------------------------------------
            fullFileName = strcat(MeterDir, '\', fullFilePath, '\', fileName);
            GenFigureTable(fullFileName, pulseResults, detectionResults, fidLog);         
       
          end
    end   
    

    validPltMPC = 1;

    WriteToLogFile(fidLog,'Plots succesfully executed');

catch err
    WriteToLogFile(fidLog,'Couldnt execute one or more plots');
    WriteToLogFile(fidLog,err.message) ;
    return;
end    
  
end

