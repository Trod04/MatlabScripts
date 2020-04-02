function CSVdata = getSelectedSignal(hObject, handles)
%get selected data from gui and update handles.CSVdata

%data gui retrieval
pathSel = get(handles.popPaths, 'Value');
pathSide = get(handles.popSide, 'Value');
MPCNum = get(handles.popMPC, 'Value');

%calculate current selected line CSVdataRaw
PathNum = handles.typeCsv(1,1);

MPCPart = (MPCNum -1)* PathNum * 2;
PathPart =  (pathSel -1) * 2;
SidePart = pathSide;

SelectedLine = MPCPart + PathPart +SidePart;

%update CSVdata with the current selected line
CSVdata = handles.CSVdataRaw(SelectedLine,:);
