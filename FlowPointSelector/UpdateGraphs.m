function [ handles ] = UpdateGraphs( handles )

%Function description
%--------------------------------------------------------------------------
% Owner:     TROD
% Date modified:    27-07-2018
% General discription:  updates the graphs
%--------------------------------------------------------------------------

%set visibility off in case only one path gets plotted

cla(handles.axesQlineTotal,'reset');
cla(handles.axesVosSelection,'reset');
cla(handles.axesVogSelection,'reset');



%update axesQlineTotal
%--------------------------------------------------------------------------

%collect Qline data from logfile

signal = handles.csvData(:,handles.Qline);

%generate number of samples
t=handles.sampleStart:handles.sampleStop;

%plot samples
axes(handles.axesQlineTotal);

handles.A1 = plot(t,signal(handles.sampleStart:handles.sampleStop),'-b');

hold on;


%update axesVosSelection
%--------------------------------------------------------------------------

%collect VoS data from logfile
if handles.plotSelection == 9
    signal = handles.csvData(:,handles.VosStart:(handles.VosStart + handles.numPaths - 1));
else
    signal = handles.csvData(:,(handles.VosStart + handles.plotSelection - 1));
end

%generate number of samples
t=handles.sampleStart:handles.sampleStop;
t = t';

%plot samples
axes(handles.axesVosSelection);

pathColor = color(); 
if handles.plotSelection == 9
    for i = 1:handles.numPaths
        pathSignal = signal(:,i);
        pathSignalSelection = pathSignal(handles.sampleStart:handles.sampleStop);
        handles.A2(i) = plot(t,pathSignalSelection, 'Color', pathColor(i,:));
        hold on;
    end
else
    handles.A2(handles.plotSelection) = plot(t,signal(handles.sampleStart:handles.sampleStop), 'Color' ,pathColor(handles.plotSelection,:));
    hold on;
end
    
legend('Location','southeast');
legend('boxoff')
hold on;

set(gca,'xticklabel',{[]}); 
hold on;

%update axesVogSelection
%--------------------------------------------------------------------------

%collect VoG data from logfile
if handles.plotSelection == 9
    signal = handles.csvData(:,handles.VogStart:(handles.VogStart + handles.numPaths - 1));
else
    signal = handles.csvData(:,(handles.VogStart + handles.plotSelection - 1));
end

%generate number of samples
t=handles.sampleStart:handles.sampleStop;
t = t';

%plot samples
axes(handles.axesVogSelection);

pathColor = color(); 
if handles.plotSelection == 9
    for i = 1:handles.numPaths
        pathSignal = signal(:,i);
        pathSignalSelection = pathSignal(handles.sampleStart:handles.sampleStop);
        handles.A3(i) = plot(t,pathSignalSelection, 'Color', pathColor(i,:));

        hold on;
    end
else
    handles.A3(handles.plotSelection) = plot(t,signal(handles.sampleStart:handles.sampleStop), 'Color' ,pathColor(handles.plotSelection,:));
    hold on;
end

%set x/y-axis limits/labels
uplimY = max(signal)*1.1;
xlim([handles.sampleStart handles.sampleStop]);
ylim([0 uplimY]);
hold on;

set(gca,'xticklabel',{[]}); 
hold on;

end

