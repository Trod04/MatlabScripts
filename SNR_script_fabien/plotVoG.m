function [ validPltVoG ] = plotVoG(currentMeterDir, fidLog, pathConfig, resultVOG, resultVOGpp, resultSTD, resultsPKS, maxdevVOG, maxdevVOGpp, maxStdDev, maxNmbPeaks, VOG, VOGpp, VOGband, VOGppband)

%initialise return parameter
validPltVoG = 0;

try
    pathConfig = pathConfig(2,:);
    pathConfig = [pathConfig, 'VoG'];

    plotName = 'VoG';

    [ numRows, numPaths] = size(VOGpp);
    
    %creat subfolder for test
     
    createDir(plotName, currentMeterDir, fidLog);
    currentMeterDir = strcat(currentMeterDir, '\', plotName);


    %merge results diff subtest to determine a faulty path
    faultyPaths(1,numPaths)=0;
    for i = 1:numPaths
       if resultVOGpp(1,i)  | resultSTD(1,i) | resultsPKS(1,i)
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

    if maxdevVOG > maxdevVOGpp
        ymin= -(maxdevVOG * 1.3);
        ymax= (maxdevVOG * 1.3);
    else
        ymin= -(maxdevVOGpp * 1.3);
        ymax= (maxdevVOGpp * 1.3);
    end
    
       
    for i = 1:numPaths
        if (max(VOGpp(:,i)) > ymax) && (max(VOGpp(:,i)) < 10)
            ymax = max(VOGpp(:,i)) * 1.1;
        end
        if (min(VOGpp(:,i)) < ymin) && (min(VOGpp(:,i)) > -10)
            ymin = min(VOGpp(:,i)) * 1.1;
        end            
    end
  

    %make different colors
    cc=color();

    %maak figuur
    f = figure();
    set(f,'Visible','off');                                 %command voor figuur niet te plotten op desktop


    title('Absolute & STD Deviation VoG FAT ','FontWeight','bold', 'FontSize', 14);
    xlabel('Samples');
    ylabel('VoG [m/s]');
    xlim([xmin,xmax]);
    ylim([ymin,ymax]);

    hold on;
    %plot VoGpp
    for i = 1: numPaths
        if faultyPaths(i)
            plot(xVals,VOGpp(:,i),'--','Color',cc(i,:),'LineWidth', 1);
            hold on;
        else
            plot(xVals,VOGpp(:,i),'Color',cc(i,:),'LineWidth', 1);
            hold on;
        end
    end
    
    %plot VoG General
    
    if resultVOG(1,1)
        plot(xVals,VOG, '-.','Color',[0,0,0],'LineWidth', 5);
    else
        plot(xVals,VOG,'Color',[0,0,0],'LineWidth', 5);
    end
    
    hold on;

    
    %plot legend
    legend(pathConfig,'location','Eastoutside');
    hold on;

    %plot grenzen
    plot(xVals, VOGband,':', 'color', [1,0,0]);
    hold on;
    plot(xVals, VOGppband,':', 'color', [1,0.5,0]);
    text(numRows * 0.85,maxdevVOGpp,' PosLimVoGpp');
    text(numRows * 0.85,-maxdevVOGpp,' NegLimVoGpp');
    hold on;

    fullPathPlotName = strcat(currentMeterDir, '\', plotName);
    saveas(gcf,fullPathPlotName,'png');
    close(f);
    

    %generate tables with results from subtests ktDiff
    validTblVOG = testToCsv(currentMeterDir, fidLog, 'devVoG', 'max', resultVOG, maxdevVOG);
    validTblVOGpp = testToCsv(currentMeterDir, fidLog, 'devVoGpp', 'max', resultVOGpp, maxdevVOGpp);
    validTblSTD = testToCsv(currentMeterDir, fidLog, 'STDdev', 'STD', resultSTD, maxStdDev);
    validTblPKS = testToCsv(currentMeterDir, fidLog, 'Peaks', 'PKS', resultsPKS, maxNmbPeaks);
         
    
    %write to logfile
    if validTblVOG & validTblVOGpp & validTblSTD & validTblPKS
        WriteToLogFile(fidLog,'VoG Plot succesfully terminated');   
        validPltVoG = 1;
    else
        WriteToLogFile(fidLog,'VoG Plot succesfull, error in generating table(s)'); 
    end
catch err 
    WriteToLogFile(fidLog,'Error in plotting VoG');
    WriteToLogFile(fidLog,err.message);
end

end

