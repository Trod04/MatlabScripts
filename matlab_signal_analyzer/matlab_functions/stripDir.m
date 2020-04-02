function [MainDir,NameTemplate] = stripDir(FileDir)
[~,DirSize] = size(FileDir);

separationChar = '\';

for i = DirSize:-1:1
    currentChar = FileDir(1,i);
    if currentChar == separationChar
        separationNum =i;
        break
    end    
end

MainDir = FileDir(1,1:separationNum - 1);
NameTemplate = FileDir(1,separationNum + 1:DirSize-4);

end