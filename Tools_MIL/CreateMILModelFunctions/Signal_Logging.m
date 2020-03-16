function [ ] = Signal_Logging(FileName)
%Function enables signal logging at the point of creation of a signal

%find location of all lines
signal_loc = find_system(FileName,'FindAll','on','type','Line');

%get port the line originates from
line_loc = get_param(signal_loc,'SrcPortHandle');

% if line is not named then do not enable logging for that line
for i=1: length(line_loc)
    signals_list{i} = get_param(line_loc{i},'Name');
    if ~isempty(signals_list{i})
        set_param(line_loc{i},'datalogging','on');
    else
    end
end

end

