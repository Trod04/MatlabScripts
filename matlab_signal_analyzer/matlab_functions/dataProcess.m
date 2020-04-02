function [validPlot, pulseData] = dataProcess(handles,firstProcess, hObject)
%pulse process and plot to gui

%process MPC data
[validProcess, pulseData] = PulseProcessScope(handles,firstProcess, hObject);

if validProcess
    %publish results into table
    validPublish = PublishResults(pulseData,handles);

    %plot signal
    [validPlot, plotData] = PlotPulseScope(pulseData,handles);
    pulseData.plotData = plotData;
end

end

