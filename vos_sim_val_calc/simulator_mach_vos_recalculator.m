function simulator_mach_vos_recalculator()

Avg_VoG = 10;
VoS_Raw = 340;

angle = 50;

test_sin = sind(angle);

Mach_corr = 1 + 0.5*((Avg_VoG*sind(angle))/VoS_Raw)^2;

test = 3;


end

