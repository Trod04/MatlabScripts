function WriteToLogFile(fidLog, myString )

fwrite(fidLog,[datestr(now,13) ' ' myString]);
fprintf(fidLog,'\n');

end
