function ClearMemory()
%clear the memory after the function is finished, close all files.

clc;
clear all;
close all;
clear functions;
fclose('all');
java.lang.System.gc();

end

