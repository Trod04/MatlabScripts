function TransitTime_vals = TT_recalculator(PathData, CurrentPath )
%Recalculate VoG values to transit times

%test VoG value
% PathData.VoG = 5; %value velocity of gas path, unit m/s
% PathData.VoS = 350; % value velocity of sound path, unit m
% PathData.PL = 0.43; %value pathlenght in unit m, unit m
% PathData.angle = 62.2; %value path angle, unit degrees

%Recalculation
%--------------

%calculate transittime: TTab = TT(vos - vog), TTba = TT(vog - vos)

TT_AB = PathData.PL/(PathData.VoS -(PathData.VoG*cosd(PathData.angle))); 
TT_BA = PathData.PL/(PathData.VoS +(PathData.VoG*cosd(PathData.angle)));

%initialize return parameter
TransitTime_vals(1) = TT_AB;
TransitTime_vals(2) = TT_BA;


end

