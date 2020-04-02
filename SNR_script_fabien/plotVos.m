function [validVos] =  plotVos(currentMeterDir, fidLog, pathConfig, resultsSTDmax, resultsSTDpeak, resultsBand, maxStdDev, maxNmbPeaks, Bandwidth, vosPaths, MinMaxBand)

%initialise return parameter
validVos = 0;

try
    pathConfig = pathConfig(2,:);

    plotName = 'Vos';

    [ numRows, numPaths] = size(vosPaths);
    
    
    %creat subfolder for test
     
    createDir(plotName, currentMeterDir, fidLog);
    currentMeterDir = strcat(currentMeterDir, '\', plotName);

    %merge results diff subtest to determine a faulty path
    faultyPaths(1,numPaths)=0;
    for i = 1:numPaths
       if resultsSTDmax(1,i) | resultsSTDpeak(1,i) | resultsBand(1,i)
           faultyPaths(1,i) = 1;
       end
    end

    %generate different colors for all lines
    cc=hsv(numPaths);

    % generate x values
    xVals(1: numRows) = [1:numRows];

    %generate limits
    xmin = 1;
    xmax = numRows;

    ymin= MinMaxBand(2,1) - (Bandwidth *0.3);
    ymax= MinMaxBand(1,1) + (Bandwidth *0.3);

    for i = 1:numPaths
        if (max(vosPaths(:,i)) > ymax) && (max(vosPaths(:,i)) < 400)
            ymax = max(vosPaths(:,i)) * 1.01;
        end
        if (min(vosPaths(:,i)) < ymin) && (min(vosPaths(:,i)) > 300)
            ymin = min(vosPaths(:,i)) * 0.99;
        end            
    end
  

    %make different colors
    cc=color();

    %maak figuur
    f = figure();
    set(f,'Visible','off');                                 %command voor figuur niet te plotten op desktop


    title('Std Deviation, peaks & max bandwidth VoS ','FontWeight','bold', 'FontSize', 14);
    xlabel('Samples');
    ylabel('VoS [m/s]');
    xlim([xmin,xmax]);
    ylim([ymin,ymax]);

    hold on;
    %get diff 
    for i = 1: numPaths
        if faultyPaths(i)
            plot(xVals,vosPaths(:,i),'--','Color',cc(i,:),'LineWidth', 1);
            hold on;
        else
            plot(xVals,vosPaths(:,i),'color',cc(i,:),'LineWidth', 1);
            hold on;
        end
    end

    %plot legend
    legend(pathConfig,'location','Eastoutside');
    hold on;


    %plot grenzen
    plot(xVals, MinMaxBand,':', 'color', [1,0,0]);
    text(numRows * 0.9, MinMaxBand(2,1),' negBand');
    text(numRows * 0.9, MinMaxBand(1,1),' posBand');
    hold on;


    fullPathPlotName = strcat(currentMeterDir, '\', plotName);
    saveas(gcf,fullPathPlotName,'png');
    close(f);
    
    %generate tables with results from subtests ktDiff
    validTblSTD = testToCsv(currentMeterDir, fidLog, 'STDdev', 'STD', resultsSTDmax, maxStdDev);
    validTblPKS = testToCsv(currentMeterDir, fidLog, 'Peaks', 'PKS', resultsSTDpeak, maxNmbPeaks);
    validTblBND = testToCsv(currentMeterDir, fidLog, 'Bandwidth', 'Band', resultsBand, Bandwidth);
    

    %write to logfile
    if validTblSTD & validTblPKS & validTblBND
        WriteToLogFile(fidLog,'Vos Plot succesfully terminated');   
        validVos = 1;
    else
        WriteToLogFile(fidLog,'Vos Plot succesfull, error in generating table(s)'); 
    end
catch err 
    WriteToLogFile(fidLog,'Error in plotting Vos');
    WriteToLogFile(fidLog,err.message);
end

end
