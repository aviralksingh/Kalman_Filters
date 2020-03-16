function [Data,Time,TestCase,Inputs_Matrix,Inputs_Matrix_Struct] = GetTestCases(Inputs,FileName)
%Read test cases excel sheet and populate start and end row of test cases
% outputs of this function

% read test cases sheet
[~,Text_Data,All_Data] = xlsread(FileName,'Sheet1');

%% find column of __t__
Clmn_no.Time = strmatch('___t___',Text_Data(1,:));

%% for every signal in Inputs.Names find the column number in excel sheet
for i=1:length(Inputs.Names)
    Find_Col = ismember(All_Data(1,1:Clmn_no.Time),Inputs.Names(i));
    Clmn_no.Signal(i) = find(Find_Col);
end;

%% find the start and end row no. of every test case
[rows,~]=size(All_Data);
k=1;
st=1;
for i=2:rows
    if i>2 && isnan(All_Data{i,Clmn_no.Time}) && ~isnan(All_Data{i-1,Clmn_no.Time})
        TC_End(k) = i-1;
        k=k+1;
    else
        if ischar(All_Data{i-1,Clmn_no.Time}) && ~isnan(All_Data{i,Clmn_no.Time})
            TC_Start(st) = i;
            st=st+1;
        elseif i>2 && ...
                (isnan(All_Data{i-1,Clmn_no.Time}) && ~isnan(All_Data{i,Clmn_no.Time}))
            TC_Start(st) = i;
            st=st+1;
        end;
    end;
    TC_End(k)=rows(end);
end
Le_cnt_TC = numel(TC_End);

%% Breaking up test cases.
% creating Data and Time and test case ID's array (array of cell arrays)
for TC=1:Le_cnt_TC
    temp=[];
    for i=1:length(Inputs.Names)
        temp = [temp,All_Data(TC_Start(TC):TC_End(TC),Clmn_no.Signal(i))];
    end;
    Data{TC}=temp;
    Time{TC}=All_Data(TC_Start(TC):TC_End(TC),Clmn_no.Time);
    TestCase{TC}= cell2mat(All_Data(TC_Start(TC),1)); % Test Case ID will be provided in the first row of a test case only!
end;

% create Inputs_Matrix struct 
for TC=1:Le_cnt_TC
    TestCase_Col = (['Test Case';All_Data(TC_Start(TC):TC_End(TC),1)]);
    Data_Col = [Inputs.Names;Data{TC}];
    Time_Col = ['___t___';Time{TC}];
    Inputs_Matrix_Struct{TC}=[[TestCase_Col, Data_Col, Time_Col]];
end;

Inputs_Matrix=[];
% create Inputs_Matrix
for TC=1:Le_cnt_TC
    TestCase_Col = (['Test Case';All_Data(TC_Start(TC):TC_End(TC),1)]);
    Data_Col = [Inputs.Names;Data{TC}];
    Time_Col = ['___t___';Time{TC}];
    Inputs_Matrix=[Inputs_Matrix; [TestCase_Col, Data_Col, Time_Col]];
end;

end

