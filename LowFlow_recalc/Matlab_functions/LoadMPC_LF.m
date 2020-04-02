function CSVdata = LoadMPC_LF(fullPath,numPaths)

try  
    %try open the selected file  
    data=importdata(fullPath, ',',0);
    numData=data.data;
    
    %initialize zero cross array
    zeroCrossPos(numPaths*2) = 0;
        
    %delete NaN rows but preserve sample zerocross positions !NOT TESTED
    %for mpc's with NaN vals yet!
    
    [dataSize, rowSize] = size(numData);
    
    %keep track of currentpath to fill zercrossspos
    currentPath = 16;
    
    %keep track of double row in case of NaN values
    doubleRow = 0;
    
    for i = dataSize:-1:1
       if isnan(numData(i,end))
           %scan NaN row for last datapoint that isn't a nan value to save
           %zercross, when found break loop
           for y = rowSize:-1:1
               if ~isnan(numData(i,y))
                    zeroCrossPos(currentPath) = numData(i, y-1);
                    break
               end
               doubleRow = 1;
           end
           
           %delete NaN row
           numData(i,:) = [];
       else
           %populate zerocrosspoints and adjust currentPath, ignore in case
           %of NaN value before
           if ~doubleRow
                zeroCrossPos(currentPath) = numData(i, end -1);
                doubleRow = 0;
           end
           currentPath = currentPath -1;
       end
    end
    
    %add correction value to zerocross samples
    zeroCrossPos = zeroCrossPos + 4;   
    
    
    %compose return parameter values
    CSVdata.samples = numData;
    CSVdata.ZC = zeroCrossPos;
           
catch err
    strError = err
end      



end

