function [ ] = AddAHS2FunctionCall(TestFileName,TestPathName)
open_system(TestFileName)
load_system('simulink')
blockname = [num2str(TestFileName), '/Call'];
add_block('simulink/Ports & Subsystems/Function-Call Generator',blockname)
set_param(blockname,'sample_time','-1')

x=find_system(bdroot,'SearchDepth',3,'BlockType','From');
Tag_Name=get_param(x,'Gototag');
Tag_Visibility = get_param(x,'tagvisibility');

expression = 'Mng_\w*_\w*ms';

matchStr = regexp(Tag_Name,expression,'match');
for i=1:length(matchStr)
    if ~isempty(matchStr{i})
    Goto_Tag_Name=matchStr{i};
    break;
    end  
end

blockname_Goto = [num2str(TestFileName), '/Goto'];
add_block('simulink/Signal Routing/Goto',blockname_Goto)
set_param(blockname_Goto,'Gototag',char(Goto_Tag_Name));
set_param(blockname_Goto,'tagvisibility','global');


FunctionCall_Handle=get_param(blockname, 'PortHandles');
FunctionCall_Handle=FunctionCall_Handle.Outport;
Goto_Handle=get_param(blockname_Goto, 'PortHandles');
Goto_Handle=Goto_Handle.Inport;
add_line(num2str(TestFileName),FunctionCall_Handle,Goto_Handle,'autorouting','On');
save_system(TestFileName);
close_system(TestFileName);
end

