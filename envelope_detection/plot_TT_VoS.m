function plot_TT_VoS(TransitTimesVoS, strTTVplot)

%convert transit times to ns
TransitTimesVoS(:,1:4) = TransitTimesVoS(:,1:4) * 1000000;

%x-vals for plotting
[numSamples,~] = size(TransitTimesVoS);
t = 1:numSamples;

%determine plot limits
minTT = round(min(min(TransitTimesVoS(:,1:4)))*0.99,2);
maxTT = round(max(max(TransitTimesVoS(:,1:4)))*1.01,2);
minVoS = round(min(min(TransitTimesVoS(:,5:6)))*0.999,2);
maxVoS = round(max(max(TransitTimesVoS(:,5:6)))*1.001,2);

TTstep = round((maxTT - minTT)/10,2);
VoSstep = round((maxVoS - minVoS)/10,2);

%open plot
h = figure();
set(h, 'visible', 'off'); %don't plot to desktop

%set labels
xlabel('samples');
title('Transit Times and VoS');
hold on;

%plot TT and VoS
[AX, H1, H2] = plotyy(t, [TransitTimesVoS(:,1)'; TransitTimesVoS(:,2)'; TransitTimesVoS(:,3)';TransitTimesVoS(:,4)'], t, [TransitTimesVoS(:,5)'; TransitTimesVoS(:,6)'], 'plot');

%set markup
set(H1(:),'LineStyle','--','LineWidth',1);
set(H2(:),'LineWidth',3);

set(AX(1),'YLim',[minTT maxTT]);
set(AX(2),'YLim',[minVoS maxVoS]);

set(AX(1),'YTick',[minTT:TTstep:maxTT]);
set(AX(2),'YTick',[minVoS:VoSstep:maxVoS]);

ylabel(AX(1),'TransitTimes[ns]');
ylabel(AX(2),'Velocity of Sound [m/s]');

legend([H1(1);H1(2);H1(3);H1(4);H2(1); H2(2)],'P1-TTup','P1-TTdwn','P2-TTup','P2-TTdwn', 'P1-VoS', 'P2-VoS');

%save plot
savedir = strcat(strTTVplot,'\TT_vos_plot.png');
saveas(gcf,savedir,'png');

end