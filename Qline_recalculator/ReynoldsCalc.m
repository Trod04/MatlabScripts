function Rfactor = ReynoldsCalc(VogRaW, PathTypeNum)
%calculate Reynolds par for current VoG value

%initialize return parameter
Rfactor = 0;

%get data from meterconfig

MeterConfig  = MeterParameterConfigQ();

%specific data
%-------------

%Reynolds pars

R1 = MeterConfig.ReynoldsType(PathTypeNum).Par(1);
R2 = MeterConfig.ReynoldsType(PathTypeNum).Par(2);
R3 = MeterConfig.ReynoldsType(PathTypeNum).Par(3);
R4 = MeterConfig.ReynoldsType(PathTypeNum).Par(4);
R5 = MeterConfig.ReynoldsType(PathTypeNum).Par(5);
R6 = MeterConfig.ReynoldsType(PathTypeNum).Par(6);

%Dens/Visc pars

Density = MeterConfig.Density;
Viscosity = MeterConfig.Visc;

%meter pars

velocity = VogRaW;
ID = MeterConfig.ID;


%Reynolds correction factor calculation
%--------------------------------------

%reynolds number calc

ReynoldsNumber = (abs(velocity) * ID * Density) / Viscosity;

%reynolds correction factor calc
F1 = 1/(1+(ReynoldsNumber/R1)^R2);
Rfactor = R3  *F1 + (1 - F1)*(R4 - R5/(R6 + log10(ReynoldsNumber)));

end

