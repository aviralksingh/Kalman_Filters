buffer = fileread( 'hvbrmaut.c' ) ; 

buffer = regexprep( buffer, '/\*.*?\*/', '' );
buffer = regexprep( buffer, '//.*?(\r)?\n', '$1\n' ); 


C = strsplit(buffer,' ') ;

K = strfind(C,'Poke');
I=find(char(K{:}) == 1);

PokeNames = C(I)';