function TransitTime_vals = TT_recalculator( VoG_path, VoS_path, PL, path_angle )
%Recalculate VoG values to transit times

%test VoG value
VoG_path = 5; %value velocity of gas path, unit m/s
VoS_path = 350; % value velocity of sound path, unit m
PL = 0.43; %value pathlenght in unit m, unit m
path_angle = 50; %value path angle, unit degrees

%Recalculation
%--------------

%calculate average transittime first

TTaverage = VoS_path/PL;

%calculate TTdiff

TTdiff = (PL/VoG_path)/cosd(path_angle);

TT_AB = TTaverage - (TTdiff/2);
TT_BA = TTaverage + (TTdiff/2);

%initialize return parameter
TransitTime_vals(1) = TT_AB;
TransitTime_vals(2) = TT_BA;


end

