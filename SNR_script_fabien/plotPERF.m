function [ validPltPERF ] = plotPERF(currentMeterDir, fidLog, pathConfig, resultsPERmin, resultsPERavg, PerfMinLim, PerfAvgLim, PerfPP, LimitAvgBand, LimitMinBand)

%initialise return parameter
validPltPERF = 0;

try
    pathConfig = pathConfig(2,:);

    plotName = 'PERFORMANCE';

    [ numRows, numPaths] = size(PerfPP);
    
    %creat subfolder for test
     
    createDir(plotName, currentMeterDir, fidLog);
    currentMeterDir = strcat(currentMeterDir, '\', plotName);

    %merge results diff subtest to determine a faulty path
    faultyPaths(1,numPaths)=0;
    for i = 1:numPaths
       if resultsPERmin(1,i) | resultsPERavg(1,i)
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
    
    ymin = (PerfMinLim *0.8) *100;
    ymax = 110;

    %make different colors
    cc=color();

    %maak figuur
    f = figure();
    set(f,'Visible','off');                                 %command voor figuur niet te plotten op desktop


    title('PERFORMANCE','FontWeight','bold', 'FontSize', 14);
    xlabel('Samples');
    ylabel('Percentage');
    xlim([xmin,xmax]);
    ylim([ymin,ymax]);

    hold on;
    %plot Performance
    for i = 1:numRows
        for j = 1: numPaths
            PerfPP(i,j) = PerfPP(i,j) * 100;
        end
    end
    
    for i = 1: numPaths
        if faultyPaths(i)
            plot(xVals,PerfPP(:,i),'--','Color',cc(i,:),'LineWidth', 1);
            hold on;
        else
            plot(xVals,PerfPP(:,i),'Color',cc(i,:),'LineWidth', 1);
            hold on;
        end
    end
    
   
    %plot legend
    legend(pathConfig,'location','Eastoutside');
    hold on;

    %plot grenzen
    LimitMinBand(:,1) = LimitMinBand(1,1) * 100;
    LimitAvgBand(:,1) = LimitAvgBand(1,1) * 100;
    plot(xVals, LimitMinBand,':', 'color', [1,0,0]);
    plot(xVals, LimitAvgBand,':', 'color', [1,0.5,0]);
    text(numRows * 0.75,PerfMinLim * 100,' Min Perf Lim');
    text(numRows * 0.75,PerfAvgLim * 100,' Avg Perf Lim');
    hold on;

    fullPathPlotName = strcat(currentMeterDir, '\', plotName);
    saveas(gcf,fullPathPlotName,'png');
    close(f);
    
    %generate tables with results from subtests PERFORMANCE
    validMinPerTbl = testToCsv(currentMeterDir, fidLog, 'minPERF', 'MIN', resultsPERmin, PerfMinLim);
    validAvgPerTbl = testToCsv(currentMeterDir, fidLog, 'avgPERF', 'AVG', resultsPERavg, PerfAvgLim);
    
   
    %write to logfile
    if validMinPerTbl & validAvgPerTbl
        WriteToLogFile(fidLog,'PERFORMANCE Plot succesfully terminated');   
        validPltPERF = 1;
    else
        WriteToLogFile(fidLog,'PERFORMANCE Plot succesfull, error in generating table(s)'); 
    end
catch err 
    WriteToLogFile(fidLog,'Error in plotting PERFORMANCE');
    WriteToLogFile(fidLog,err.message);
end

end
