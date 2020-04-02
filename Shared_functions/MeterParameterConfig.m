function [ MeterConfig ] = MeterParameterConfig(size, meterType)

%Pathlengths
%-----------
MeterConfig.meterType = meterType;
MeterConfig.size = size;

Pinfo = pathInfo(MeterConfig.size, MeterConfig.meterType);

MeterConfig.PL = Pinfo.PL;
MeterConfig.Pangle = Pinfo.angle;
MeterConfig.numPaths = Pinfo.numPaths;
MeterConfig.Ptype = Pinfo.Ptype;
MeterConfig.PtypeUsed = Pinfo.PtypeUsed;


%Dens/Visc
%-------------
MeterConfig.density = 55;
MeterConfig.visc = 0.0000130;


%Reynolds Pars
%-------------

%Type A
MeterConfig.ReynoldsType(1).Par(1) = 4000;
MeterConfig.ReynoldsType(1).Par(2) = 25;
MeterConfig.ReynoldsType(1).Par(3) = 0.85;
MeterConfig.ReynoldsType(1).Par(4) = 1.006;
MeterConfig.ReynoldsType(1).Par(5) = 0.2;
MeterConfig.ReynoldsType(1).Par(6) = 0;


%Type B
MeterConfig.ReynoldsType(2).Par(1) = 1;
MeterConfig.ReynoldsType(2).Par(2) = 1;
MeterConfig.ReynoldsType(2).Par(3) = 1;
MeterConfig.ReynoldsType(2).Par(4) = 1;
MeterConfig.ReynoldsType(2).Par(5) = 0;
MeterConfig.ReynoldsType(2).Par(6) = 0;

%Type C
MeterConfig.ReynoldsType(3).Par(1) = 1;
MeterConfig.ReynoldsType(3).Par(2) = 1;
MeterConfig.ReynoldsType(3).Par(3) = 1;
MeterConfig.ReynoldsType(3).Par(4) = 1;
MeterConfig.ReynoldsType(3).Par(5) = 0;
MeterConfig.ReynoldsType(3).Par(6) = 0;

%Type D
MeterConfig.ReynoldsType(4).Par(1) = 4000;
MeterConfig.ReynoldsType(4).Par(2) = 25;
MeterConfig.ReynoldsType(4).Par(3) = 0.85;
MeterConfig.ReynoldsType(4).Par(4) = 1.085;
MeterConfig.ReynoldsType(4).Par(5) = 0.2;
MeterConfig.ReynoldsType(4).Par(6) = 0;

%Pathtype weight
%---------------

MeterConfig.WeightType(1) = 1;
MeterConfig.WeightType(2) = 0;
MeterConfig.WeightType(3) = 0;
MeterConfig.WeightType(4) = 1;

end

