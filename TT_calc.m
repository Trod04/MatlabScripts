function [ vograw ] = TT_calc( Vos, PL, TTdiff )
%vog raw calculator based on vos, pathlenght and traveltime

%input parameters for independent calculation

Vos = 400; %Vos at operational conditions
TTdiff = 5; %Vos in micro seconds
PL = 0.053; %pathlenght in m
angle = 55; %path angle degrees celcius

Tgeneral = 1/Vos*PL;

Tab = Tgeneral - (TTdiff/1000000/2);
Tba = Tgeneral + (TTdiff/1000000/2);

P1= PL/(2*cosd(angle));
P2 = (1/Tab) - (1/Tba);

%resulting VoG deviation

VogRaw = round(P1*P2,4);
strVoG = strcat('VoG: ', num2str(VogRaw),' m/s');

%deviation at qmin (VoG = 0.125 m/s or 1 m3/h for 2" meter)

deviationQmin = round(VogRaw /0.125 *100,0);
percentageDevQmin = strcat('Qmin Deviation: ',num2str(deviationQmin),'%');

%deviation at Qt (VoG = 2 m/s or 1 m3/h for 2" meter)

deviationQt = round(VogRaw /2 *100,0);
percentageDevQt = strcat('Qt Deviation: ',num2str(deviationQt),'%');

%deviation at qmin (VoG = 20 m/s or 1 m3/h for 2" meter)

deviationQmax = round(VogRaw /20 *100,0);
percentageDevQmax = strcat('Qmax Deviation: ',num2str(deviationQmax),'%');

%display  results

disp(strVoG);
disp(percentageDevQmin);
disp(percentageDevQt);
disp(percentageDevQmax);

end




