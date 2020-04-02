function numPaths = numMeterType( strMeterType )
%return numPaths based on Metertype
sw = strMeterType{1};

switch sw
    case 'Qsonic Plus'
        numPaths = 6;        
    case 'Qsonic Max'
        numPaths = 8;        
end

end

