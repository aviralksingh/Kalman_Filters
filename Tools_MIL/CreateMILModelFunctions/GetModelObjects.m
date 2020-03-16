function [Inputs,Outputs,Locals] = GetModelObjects(TestFileName,TestPathName,SearchDepth)
%% Path Setting
cd(TestPathName);
%% Load the System
open_system(TestFileName);
root = bdroot;
%% Reading Number of Inputs and Outputs
InportHandles = find_system(root,'SearchDepth',SearchDepth,'BlockType','Inport');
OutportHandles  = find_system(root,'SearchDepth',SearchDepth,'BlockType','Outport');
InportHandles_Number = find_system(root,'FindAll','On','SearchDepth',2,'BlockType','Inport');
OutportHandles_Number  = find_system(root,'FindAll','On','SearchDepth',2,'BlockType','Outport');
set_param(bdroot,'SimulationCommand','update')
Locals =find_system (root,'SearchDepth',2,'BlockType','Outport');
Locals =find_system (root,'SearchDepth',2,'LookUnderMasks','all','BlockType','Outport');
signalLines = find_system(root,'FindAll','on','type','Line');
for i = 1:length(signalLines)
      % set(signalLines(i),'signalPropagation','off');
      set(signalLines(i),'signalPropagation','off');
end
signals_list = get_param(signalLines,'Name');

%% Get Outport and Inport Information - Name, Size and Datatype
% Compile the Model
Cmd=[root, '([],[],[],''','compile', ''' ); ' ];
eval(Cmd)

% Get inport dimensions and datatypes
for i=1:length(InportHandles)
    InputDimensions = get_param(InportHandles_Number(i),'CompiledPortDimensions');
    InputDimensions=InputDimensions.Outport;
    InportDimensions(i,:,:)=InputDimensions;
    InputDataTypes = get_param(InportHandles_Number(i),'CompiledPortDataTypes');
    InputDataTypes = InputDataTypes.Outport;
    InportDataTypes{i} = InputDataTypes;
end
% Get outport dimensions and datatypes

for i=1:length(OutportHandles)
    OutputDimensions = get_param(OutportHandles_Number(i),'CompiledPortDimensions');
    OutputDimensions=OutputDimensions.Inport;
    OutportDimensions(i,:,:)=OutputDimensions;
    OutputDataTypes = get_param(OutportHandles_Number(i),'CompiledPortDataTypes');
    OutputDataTypes = OutputDataTypes.Inport;
    OutportDataTypes{i} = OutputDataTypes;
end

%% Identify Inputs, Outputs and Locals
% Inputs
for(Le_index=1:length(InportHandles))
Input_Cell=strsplit(InportHandles{Le_index},'/');
Input_Names(Le_index)=Input_Cell(length(Input_Cell));
end
% Outputs
for(Le_index=1:length(OutportHandles))
Outputs_Cell=strsplit(OutportHandles{Le_index},'/');
Output_Names(Le_index)=Outputs_Cell(length(Outputs_Cell));
end
Object_Names= ['Test Case',Input_Names, '___t___',Output_Names];
% Locals
Le_index=1;
Previous_signal={};
for i = 1:length(signalLines)
    if (i>1)
        if isequal(signals_list{i},signals_list{i-1})
            Signal_Copy_True=1;
        else
            Signal_Copy_True=0;
        end
    end
    if ~isempty(signals_list{i})
        if (i==1 || Signal_Copy_True ==0)
            Local_True=0;
            for j = 1:length(Object_Names)
                if ~isequal(signals_list{i},Object_Names{j})
                    Local_True = 1;
                end
            end
            if (Local_True==1)
                Local_Names{Le_index} = signals_list{i};
                Le_index = Le_index + 1;   
            end
        end
    end
Previous_signal=signals_list{i};
end  

Object_Names=[Object_Names Local_Names];
%% Creating Structure
% Inputs
Inputs.Handles=InportHandles;
Inputs.Names=Input_Names;
Inputs.Dimensions=InportDimensions;
Inputs.Datatypes=InportDataTypes;

% Outputs
Outputs.Handles=OutportHandles;
Outputs.Names=Output_Names;
% Outputs.Dimensions=OutportDimensions;
Outputs.Datatypes=OutportDataTypes;

% Locals
Locals.Names =Local_Names;
Locals.Dimensions = single(-1)*ones(length(Local_Names));
Locals.Datatypes = single(-1)*ones(length(Local_Names));
Cmd=[root, '([],[],[],''','term', ''' ); ' ];
eval(Cmd)
set_param(gcs, 'SimulationCommand', 'stop') 


DataObjects.Inputs=Inputs;
DataObjects.Outputs=Outputs;
DataObjects.Locals=Locals;
end

