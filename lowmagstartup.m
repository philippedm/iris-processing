%% startup file to add path

addpath(genpath('c:/Users/Iris_user/documents/GitHub/iris-processing'));


str ={'Create a multichannel look up table',
	'Analyze multiple single channel images using an existing look-up table'};

name='Low-Mag Iris Analysis options';

[option,v] = listdlg('Name', name,...
                'PromptString','I want to:',...
                'SelectionMode','single',...
                'ListSize', [400 100],...
                'ListString',str);

            
            
if option == 1
    generateAccurateLUT;
elseif option == 2
    useLUTmultiSingleColor;
else
    h = warndlg('No analysis option selected.  Please restart anlysis.');
    waitfor(h)
    exit
end
    