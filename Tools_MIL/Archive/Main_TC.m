% Script for reading test cases and populating simulink signals
clear all; clc; LoadSysCals;

%% Get files
[Mdl_FileName,Mdl_PathName]=uigetfile('Select the model for MIL Testing');
[TC_FileName,TC_PathName]=uigetfile({'*.xls;*.xlsx'},'File Name','Select Test Cases Excel File');

% get filename
Name =  strsplit(Mdl_FileName, '.');
FileName = Name{1};

%% Get Model Objects
[Inputs,Outputs,Locals]=GetModelObjects(Mdl_FileName,Mdl_PathName,1);

%% Create Signal Strings
InputNamesStr = CreateInputString(Inputs);

%% Get Test Cases
[Test_Input,Time,TestCase,Input_Matrix,Inputs_Matrix_Struct] = GetTestCases(Inputs,TC_FileName);

%% Select test cases to simulate
[Selected,OK_Pressed]=listdlg('PromptString','Select test cases to run:',...
    'ListString',TestCase);
Inputs_Selected=[];

%% Simulate
% if user presses ok continue execution else terminate
if (OK_Pressed==1)
    % extracting selected inputs and time matrix
    for i=1:length(Selected)
        Inputs_Selected=[Inputs_Selected;Inputs_Matrix_Struct{Selected(i)}];
        Time_Selected{i}=Time{Selected(i)};
    end;
    
    % run only selected test cases
    Test_Output=SimTestCases(Selected,Time,Inputs,Test_Input,InputNamesStr,TestCase,FileName);
    
    % save simulation logs as .mat file
    save(strcat('Test_Result_',TC_FileName,'.mat'),'Test_Output')
    disp('Completed!!!');
    
    % data post processing before saving to excel file
    Sort_Matrix=GenerateOutputMatrix(Inputs,Outputs,Locals,Test_Input,Time_Selected,Test_Output);
    Output_Matrix=[Inputs_Selected Sort_Matrix];
    
    % save as excel
    Test_Output_LogFile=['Test_Ouput_' FileName '.xlsx'];
    xlswrite(Test_Output_LogFile,Output_Matrix)
else
    msgbox('No test cases were selected','Title','modal');
end;
