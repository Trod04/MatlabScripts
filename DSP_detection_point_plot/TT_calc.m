function [ VogRaw ] = TT_calc( Vos, PL, TTdiff )
% vog raw calculator based on vos, pathlenght and traveltime
% 
% input parameters for independent calculation

Vos = 350;
TTdiff = 1;
PL = 0.248;


Tgeneral = 1/Vos*PL;
angle = 50;

Tab = Tgeneral - (TTdiff/1000000000/2);
Tba = Tgeneral + (TTdiff/1000000000/2);

P1= PL/(2*cos(angle));
P2 = (1/Tab) - (1/Tba);

VogRaw = P1*P2;


end




