function [Sig_Names] = CreateInputString(Inputs)
%Concatenate all Input.Names 

Sig_Names=[];
for i=1:length(Inputs.Names)
    % populating signal names string
    if i ==length(Inputs.Names)
        Sig_Names=strcat(Sig_Names,Inputs.Names{i});
    else
        Sig_Names=strcat(Sig_Names,Inputs.Names{i},',');
    end
end

end

