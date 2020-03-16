function [ ] = AddTopLevelImports(TestFileName,TestPathName,Inputs,Outputs,Locals)
%ENABLE DATATYPE CONVERSION
DCO_Enable=0;
DCI_Enable=0;

%Function creates and adjusts top level inports and outports
open_system(TestFileName);

Source_Block=find_system(TestFileName,'SearchDepth',1,'Type','Block');
% add input and output ports from library
h_Inports=find_system(Source_Block,'FindAll','On','SearchDepth',1,'BlockType','Inport');
Name_Inports=get(h_Inports,'Name');
h_Outports=find_system(Source_Block,'FindAll','On','SearchDepth',1,'BlockType','Outport');
Name_Outports=get(h_Outports,'Name');

Test_Block='Sl_test';
Dest_Block=strcat(TestFileName,'/',Test_Block);
% xspacing = [inportL inportR outportL outportR]; %column margins (left/right of blocks)
% get the subsystem port handle positions
pc = get_param(gcb,'PortConnectivity');
% distance from the subsystem to the port
offset = 200;
w = 30; % block half width
h = 10; % height of the row
DC_block_offset=75;
load_system('simulink')

EnumClass_expression = 'Te\w*_e_\w*';

for i = 1:length(Inputs.Names)

    x = pc(i).Position(1);
    y = pc(i).Position(2);
    
    Convertblockname = [num2str(TestFileName), '/Data Type Conversion'];
    blockname = [num2str(TestFileName), '/In1'];
    add_block('simulink/Sources/In1',blockname)
    
    % adjust position of port block
    set_param(blockname,'Position',[x-offset,y-h/2,x-offset+w,y+h/2]);
    set_param(blockname, 'Interpolate','off');
    set_param(blockname, 'Name',num2str(Inputs.Names{i}))
    if (DCI_Enable==1)
        matchStr = regexp(char(Inputs.Datatypes{i}),EnumClass_expression,'match');
        DC_Block_1=['DCI_',num2str(i)];
        DC_Block_2=['DCI_2_',num2str(i)];
        if (~isempty(matchStr))
            add_block('simulink/Signal Attributes/Data Type Conversion',Convertblockname);
            set_param(Convertblockname,'Position',[x-offset+DC_block_offset,y-h/2,x-offset+DC_block_offset+w/2,y+h/2]);
            set_param(Convertblockname, 'Name',DC_Block_1);
            set_param([TestFileName,'/',DC_Block_1],'BackgroundColor','yellow');
            add_block('simulink/Signal Attributes/Data Type Conversion',Convertblockname);
            set_param(Convertblockname,'Position',[x-offset+DC_block_offset*2,y-h/2,x-offset+DC_block_offset*2+w/2,y+h/2]);
            set_param(Convertblockname, 'Name',DC_Block_2);
            set_param([TestFileName,'/',DC_Block_2],'BackgroundColor','green');
            add_line(num2str(TestFileName),[DC_Block_1,'/1'],[DC_Block_2,'/1'])
            Source_Port= [num2str(Inputs.Names{i}),'/1'];
            Dest_Port=[Test_Block,'/',num2str(i)];
            add_line(num2str(TestFileName),Source_Port,[DC_Block_1,'/1']);
            add_line(num2str(TestFileName),[DC_Block_2,'/1'],Dest_Port);
        else
            add_block('simulink/Signal Attributes/Data Type Conversion',Convertblockname);
            set_param(Convertblockname,'Position',[x-offset+DC_block_offset,y-h/2,x-offset+DC_block_offset+w/2,y+h/2]);
            set_param(Convertblockname, 'Name',DC_Block_1);
            set_param([TestFileName,'/',DC_Block_1],'BackgroundColor','yellow');
            Source_Port= [num2str(Inputs.Names{i}),'/1'];
            Dest_Port=[Test_Block,'/',num2str(i)];
            add_line(num2str(TestFileName),Source_Port,[DC_Block_1,'/1']);
            add_line(num2str(TestFileName),[DC_Block_1,'/1'],Dest_Port);
        end
    else
    % adjust position of port block
    Source_Port= [num2str(Name_Inports{i}),'/1'];
    Dest_Port=[Test_Block,'/',num2str(i)];
    add_line(num2str(TestFileName),Source_Port,Dest_Port)
    end
end

for i = 1:length(Outputs.Names) 
    
    x = pc(length(Inputs.Names)+i).Position(1);
    y = pc(length(Inputs.Names)+i).Position(2);
    
    Convertblockname = [num2str(TestFileName), '/Data Type Conversion'];
    blockname = [num2str(TestFileName), '/Out1'];
    add_block('simulink/Sinks/Out1',blockname)
    set_param(blockname,'Position',[x+offset,y-h/2,x+offset+w,y+h/2]);
    set_param([num2str(TestFileName), '/Out1'], 'Name',num2str(Outputs.Names{i}))
    
    % adjust position of port block
    matchStr = regexp(char(Outputs.Datatypes{i}),EnumClass_expression,'match');
    DC_Block_1=['DCO_',num2str(i)];
    DC_Block_2=['DCO_2_',num2str(i)];
    if (DCO_Enable==1)
        if (~isempty(matchStr))
            add_block('simulink/Signal Attributes/Data Type Conversion',Convertblockname);
            set_param(Convertblockname,'Position',[x+offset-DC_block_offset,y-h/2,x+offset-DC_block_offset+w/2,y+h/2]);
            set_param(Convertblockname, 'Name',DC_Block_1);
            set_param([TestFileName,'/',DC_Block_1],'BackgroundColor','yellow');
            add_block('simulink/Signal Attributes/Data Type Conversion',Convertblockname);
            set_param(Convertblockname,'Position',[x+offset-DC_block_offset*2,y-h/2,x+offset-DC_block_offset*2+w/2,y+h/2]);
            set_param(Convertblockname, 'Name',DC_Block_2);
            set_param([TestFileName,'/',DC_Block_2],'BackgroundColor','green');
            add_line(num2str(TestFileName),[DC_Block_2,'/1'],[DC_Block_1,'/1']);
            Dest_Port= [num2str(Outputs.Names{i}),'/1'];
            Source_Port=[Test_Block,'/',num2str(i)];
            add_line(num2str(TestFileName),Source_Port,[DC_Block_2,'/1']);
            add_line(num2str(TestFileName),[DC_Block_1,'/1'],Dest_Port);
        else
            add_block('simulink/Signal Attributes/Data Type Conversion',Convertblockname);
            set_param(Convertblockname,'Position',[x+offset-DC_block_offset,y-h/2,x+offset-DC_block_offset+w/2,y+h/2]);
            set_param(Convertblockname, 'Name',DC_Block_1);
            set_param([TestFileName,'/',DC_Block_1],'BackgroundColor','yellow');
            Dest_Port= [num2str(Outputs.Names{i}),'/1'];
            Source_Port=[Test_Block,'/',num2str(i)];
            add_line(num2str(TestFileName),Source_Port,[DC_Block_1,'/1']);
            add_line(num2str(TestFileName),[DC_Block_1,'/1'],Dest_Port);
        end
    else
    % adjust position of port block
        Dest_Port= [num2str(Name_Outports{i}),'/1'];
        Source_Port=[Test_Block,'/',num2str(i)];
        add_line(num2str(TestFileName),Source_Port,Dest_Port)
    end
end
save_system(TestFileName);

close_system(TestFileName);
 
end

