function [ plotSelection ] = numPlotSelection( strPlotSelected )
%return pathSelection based on Metertype

switch strPlotSelected
    case 'All Paths'
        plotSelection = 9;        
    case 'Path1'
        plotSelection = 1;
    case 'Path2'
        plotSelection = 2; 
    case 'Path3'
        plotSelection = 3; 
    case 'Path4'
        plotSelection = 4; 
    case 'Path5'
        plotSelection = 5; 
    case 'Path6'
        plotSelection = 6; 
    case 'Path7'
        plotSelection = 7; 
    case 'Path8'
        plotSelection = 8; 
end

end

