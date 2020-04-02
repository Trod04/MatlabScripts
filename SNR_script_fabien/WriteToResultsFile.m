function WriteToResultsFile(fidRF, myString )

fwrite(fidRF,myString);
fprintf(fidRF,'\n');

end

