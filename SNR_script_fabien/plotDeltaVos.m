function [validDeltaVos] =  plotDeltaVos(currentMeterDir, fidLog, pathConfig, resultKTpath, resultKTfat, resultRelFAT, maxdevPath, maxdevFAT, maxDevRel,DevPathFAT, relDev, absDev)

%initialise return parameter
validDeltaVos = 0;

try
    pathConfig = pathConfig(2,:);

    plotName = 'DeltaVos';

    [ numRows, numPaths] = size(DevPathFAT);
    
    %creat subfolder for test
     
    createDir(plotName, currentMeterDir, fidLog);
    currentMeterDir = strcat(currentMeterDir, '\', plotName);

    %merge results diff subtest to determine a faulty path
    faultyPaths(1,numPaths)=0;
    for i = 1:numPaths
       if resultKTpath(1,i) | resultKTfat(1,i) | resultRelFAT(1,i)
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

    if maxdevFAT > maxDevRel
        ymin= -(maxdevFAT * 1.3);
        ymax= (maxdevFAT * 1.3);
    else
        ymin= -(maxDevRel * 1.3);
        ymax= (maxDevRel * 1.3);
    end
    
   
    for i = 1:numPaths
        if (max(DevPathFAT(:,i)) > ymax) && (max(DevPathFAT(:,i)) < 10)
            ymax = max(DevPathFAT(:,i)) * 1.1;
        end
        if (min(DevPathFAT(:,i)) < ymin) && (min(DevPathFAT(:,i)) > -10)
            ymin = min(DevPathFAT(:,i)) * 1.1;
        end            
    end
  

    %make different colors
    cc=color();

    %maak figuur
    f = figure();
    set(f,'Visible','off');                                 %command voor figuur niet te plotten op desktop


    title('Relative/absolute deviation VoS FAT ','FontWeight','bold', 'FontSize', 14);
    xlabel('Samples');
    ylabel('Delta VoS [m/s]');
    xlim([xmin,xmax]);
    ylim([ymin,ymax]);

    hold on;
    %get diff 
    for i = 1: numPaths
        if faultyPaths(i)
            plot(xVals,DevPathFAT(:,i),'--','Color',cc(i,:),'LineWidth', 1);
            hold on;
        else
            plot(xVals,DevPathFAT(:,i),'color',cc(i,:),'LineWidth', 1);
            hold on;
        end
    end

    %plot legend
    legend(pathConfig,'location','Eastoutside');
    hold on;


    %plot grenzen
    plot(xVals, absDev,':', 'color', [1,0,0]);
    text(numRows * 0.9,maxdevFAT,' posAbs');
    text(numRows * 0.9,-maxdevFAT,' negAbs');
    hold on;
    plot(xVals, relDev,':', 'color', [1,0.5,0]);
    text(numRows * 0.9,maxDevRel,' posRel');
    text(numRows * 0.9,-maxDevRel,' negRel');
    hold on;
    
    fullPathPlotName = strcat(currentMeterDir, '\', plotName);
    saveas(gcf,fullPathPlotName,'png');
    close(f);
    
    %generate tables with results from subtests ktDiff
    validTblKt = testToCsv(currentMeterDir, fidLog, 'diffKT', 'max', resultKTpath, maxdevPath);
    validTblAbs = testToCsv(currentMeterDir, fidLog, 'diffAbs', 'max', resultKTfat, maxdevFAT);
    validTblRel = testToCsv(currentMeterDir, fidLog, 'diffRel', 'max', resultRelFAT, maxDevRel);
    
    
    %write to logfile
    if validTblKt & validTblRel & validTblAbs
        WriteToLogFile(fidLog,'Delta Vos Plot succesfully terminated');   
        validDeltaVos = 1;
    else
        WriteToLogFile(fidLog,'Delta Vos Plot succesfull, error in generating table(s)'); 
    end
catch err 
    WriteToLogFile(fidLog,'Error in plotting DeltaVos');
    WriteToLogFile(fidLog,err.message);
end

end

