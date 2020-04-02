function [dataOut] = NormSignal(signalIn)
% OWNER:    MZAR
% YEAR:     2012
% INPUT:    signalIn (signal unnormalized supplied as row vector)
% OUTPUT:   dataOut.signalNorm (row vector of normalized data)
%           dataOut.avg (average value of singalIn)
%           dataOut.amp (max amplitude of signalIn)
% FUNCTION: normalizes input singal and returns structure with normalized
%           data as row vector,average value, and max amplitude
%--------------------------------------------------------------------------
%%
avg=mean(signalIn);
signalNorm=signalIn-avg;

maxAmp=max(signalNorm);
minAmp=abs(min(signalNorm));
maxPtP=maxAmp+minAmp;

amp=0;

if maxAmp >= minAmp
    
    amp=maxAmp;
    
else
    
    amp=-minAmp;
    
end

signalNorm=signalNorm./abs(amp);

dataOut.signalNorm=signalNorm;
dataOut.avg=avg;
dataOut.amp=amp;
dataOut.Vptp=maxPtP;

end

