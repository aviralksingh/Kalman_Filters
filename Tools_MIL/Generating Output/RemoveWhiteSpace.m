function [ Word_Out ] = RemoveWhiteSpace( Word_In )
%REMOVEWHITESPACE Summary of this function goes here
%   Detailed explanation goes here
Word_In = strtrim(Word_In);
Word_Out = regexprep(Word_In, '\s+', ' ');
end

