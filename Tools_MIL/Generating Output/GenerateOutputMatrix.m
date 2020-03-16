function [ Sort_Matrix ] = GenerateOutputMatrix(Inputs,Outputs,Locals,Test_Input,Time,Test_Output) 
Output_Final={};

%% Generate Output
TestCase_Matrix={};
Output_Matrix={};

for i = 1:length(Test_Output)
Fields = fieldnames(Test_Output(i));
Length=FindTestOutputlength(Test_Output(i));
    for j = 1:length(Fields)
        Test_Field=getfield(Test_Output(i), {1}, Fields{j});
        if (length(Test_Field.time)==Length)
            Time_Logged=Test_Field.time; % this needs to be done only once, optimize later.
            sz= size(Test_Field.values,2);
           if (sz==1)
                Output_Vector=num2cell(Test_Field.values(:));
           else
               for k = 1:Length
                Output_SubVector = Test_Field.values(k,:);
                Output_Cell=num2str(Output_SubVector);  
                Output_Vector(k) = {Output_Cell}; 
                Output_Vector(k)=RemoveWhiteSpace(Output_Vector(k));
               end
               Output_Vector=Output_Vector';
           end
        else
        Output_Vector=num2cell(NaN(Length,1) );
        end
%         Output_Vector=[Test_Field.name;Output_Vector];
        TestCase_Matrix=[TestCase_Matrix Output_Vector];
        clear Output_Vector Output_Cell Output_SubVector ;
    end   
%% Trim Function
%Find all the matching indices
    Test_Time=cell2mat(Time{1,i});
    % Give "true" if the element in "a" is a member of "b".
    Test_Time=RoundingFunction( Test_Time,5);
    Time_Logged=RoundingFunction( Time_Logged,5);
    Match_TF=ismember(Time_Logged, Test_Time);
    % Extract the elements of a at those indexes.
    Match_Indices = find(Match_TF);
    Trim_Matrix=TestCase_Matrix([Match_Indices'],:);
 %Create New Matrix from the function   
    Output_Matrix=[Output_Matrix ; Fields';Trim_Matrix];
    TestCase_Matrix={};
    Trim_Matrix={};
end
%% Sort Function
for i=1:length(Outputs.Names)
    % Give "true" if the element in "a" is a member of "b".
    Match_TF=ismember(Output_Matrix(1,:), Outputs.Names(i));
    % Extract the elements of a at those indexes.
    Match_Index = find(Match_TF);
    if isempty(Match_Index)
        sprintf('%s was missing from the Logged Signals.',char(Outputs.Names(i)))
    else
    Sort_Matrix(:,i)=Output_Matrix(:,Match_Index);
    end
end

for i=1:length(Locals.Names)
    % Give "true" if the element in "a" is a member of "b".
    Match_TF=ismember(Output_Matrix(1,:), Locals.Names(i));
    % Extract the elements of a at those indexes.
    Match_Index = find(Match_TF);
    Sort_Matrix(:,length(Outputs.Names)+i)=Output_Matrix(:,Match_Index);
end
 
end

