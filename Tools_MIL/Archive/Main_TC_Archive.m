% Script for reading test cases and populating simulink signals
clear all; clc; LoadSysCals;

%% Get files
[M_FileName,M_PathName] = uigetfile('Select the model for MIL Testing');
[TC_FileName,TC_PathName] = uigetfile({'*.xls;*.xlsx'},'Select Test Cases File');

% get filename
Name =  strsplit(M_FileName, '.');
FileName = Name{1};

%% Get Model Objects
[Inputs,Outputs,Locals] = GetModelObjects(M_FileName,M_PathName,1);

%% Create signal strings
InputNamesStr = CreateInputString(Inputs);

%% Get Test Cases
[Data,Time,TestCase] = GetTestCases(Inputs,TC_FileName);

%% Create workspace variables and run test cases
for i=1:length(Data)
    [~,clmns] = size(Data{i});
    % create variables for test case i
    for j=1:clmns
        % populating name.signals.values
        signal_name=char(strcat(Inputs.Names(j),'.signals.values=',Inputs.Datatypes{1,j},'('));
        if iscellstr(Data{i}(:,j))                                          % if data is char arrays
            sig_val_tmp = char(Data{i}(:,(j)));
            [r,~]= size(sig_val_tmp);
            signal_val=[];
            for k=1:r
                signal_val=[signal_val,';',sig_val_tmp(k,:),';'];           % concatenating the char array
            end
            eval([signal_name,'[',signal_val,']',')']);
        else                                                                % if data is not char
            signal_val=mat2str(cell2mat(Data{i}(:,(j))));
            eval([signal_name,'[',signal_val,']',')']);
        end;
        % populating name.time
        time_name=char(strcat(Inputs.Names(j),'.time='));
        time_values =mat2str(cell2mat(Time{i}));
        eval([time_name,'[',time_values,']']);
    end;
    
    %  simulate test case i
    simout = sim(FileName, 'LoadExternalInput', 'on', 'ExternalInput',InputNamesStr);
    logsout = simout.get('VariableName');
    % processing output data
    Test_Output(i)=PostprocessingData((TestCase{i}),logsout); 
end;
    save(strcat('Test_Result_',FileName,'.mat'),'Test_Output')
    disp(['Completed!!!']);
