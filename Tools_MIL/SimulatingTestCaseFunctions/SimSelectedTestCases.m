function [ Test_Output ] = SimTestCases(Selected,Time,Inputs,Test_Input,InputNamesStr,TestCase,FileName)
%SimSelectedTestCases Function simulates only selected test cases
%   create workspace variables, run simulation, save output data

for index=1:length(Selected)
    i=Selected(index);
    Time_Step=cell2mat(Time{:,i}(1));
    Time_End=cell2mat(Time{:,i});
    Time_End=Time_End(length(Time_End));
    SetSimulationTime(FileName,Time_End,Time_Step);
    [~,clmns] = size(Test_Input{i});
    % create workspace variables for test case i
    for j=1:clmns
        % for enum data types set datatype as int16
        EnumClass_expression = 'Te\w*_e_\w*';
        matchStr = regexp(char(Inputs.Datatypes{j}),EnumClass_expression,'match');
        if (~isempty(matchStr))
            Inputs.Datatypes{1,j}='int16';
        else
        end
        % populating name.signals.values
        signal_name=char(strcat(Inputs.Names(j),'.signals.values=',Inputs.Datatypes{1,j},'('));
        if iscellstr(Test_Input{i}(:,j))                                     % if data is char arrays
            sig_val_tmp = char(Test_Input{i}(:,(j)));
            [r,~]= size(sig_val_tmp);
            signal_val=[];
            for k=1:r
                signal_val=[signal_val,';',sig_val_tmp(k,:),';'];           % concatenating the char array
            end
            evalin('base',[signal_name,'[',num2str(signal_val),']',')']);
        else                                                                % if data is not char
            signal_val=mat2str(cell2mat(Test_Input{i}(:,(j))));
            evalin('base',[signal_name,'[',num2str(signal_val),']',')']);
        end;
        % populating name.time
        time_name=char(strcat(Inputs.Names(j),'.time='));
        time_values =mat2str(cell2mat(Time{i}));
        evalin('base',[time_name,'[',time_values,']']);
    end;
    
    %  simulate test case i
    simout = sim(FileName, 'LoadExternalInput', 'on', 'ExternalInput',InputNamesStr,'SrcWorkspace','base');
    logsout = simout.get('logsout');
    % processing output data
    Test_Output(index)=PostprocessingData((TestCase{i}),logsout);
    
end;

end

