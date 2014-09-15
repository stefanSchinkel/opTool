
%%%%%%%%%%%%%%%%%
% Define axes	%
%%%%%%%%%%%%%%%%%

axDataTop = axes('Parent',figHandle,...
	'Position',[.1 .65 .8 .2],...
	'Tag', 'axDataTop',...
	'NextPlot','replace',...
	'Box','on');
		
axDataBottom = axes('Parent',figHandle,...
	'Position',[.1 .35 .8 .2],...
	'Tag', 'axDataBottom',...
	'NextPlot','replace',...
	'Box','on');

%%%%%%%%%%%%%%%%%%%%%%%%%
% Define input fields	%
%%%%%%%%%%%%%%%%%%%%%%%%%

inputField = uibuttongroup('Position', [.225 .05 .37 .2],...
	'visible','on');

	textOrder = uicontrol('Parent',inputField, ...
		'Units', 'normalized', ...
		'Position', [.01 .65 .35 .2],...
		'BackgroundColor',[0.7020 0.7020 0.7020], ...
		'Style','text',... 
		'String','Order/Dim:',...
		'HorizontalAlignment','left',...
		'Visible','on',...
		'Tag','textOrder',...
		'Tooltip','The order is the number of points forming the OPs');


	valOrder = uicontrol('Parent',inputField,...
		'Units', 'normalized', ...
		'Position', [.375 .65 .15 .24],...
		'BackgroundColor',[.801 .75 .688], ...
		'Style','edit',... 
		'String',num2str(order),...
		'HorizontalAlignment','right',...
		'Visible','on',...
		'Tag','valOrder',...
		'Tooltip','Insert the order (2-13)');	

	textDelay = uicontrol('Parent',inputField, ...
		'Units', 'normalized', ...
		'Position', [.55 .65 .2 .2],...
		'BackgroundColor',[0.7020 0.7020 0.7020], ...
		'Style','text',... 
		'String','Delay:',...
		'HorizontalAlignment','left',...
		'Visible','on',...
		'Tag','textDelay',...
		'Tooltip','Delay denotes the discrete distance between the points of the OPs');


	valDelay = uicontrol('Parent',inputField,...
		'Units', 'normalized', ...
		'Position', [.875 .65 .1 .24],...
		'BackgroundColor',[.801 .75 .688], ...
		'Style','edit',... 
		'String',num2str(delay),...
		'HorizontalAlignment','right',...
		'Visible','on',...
		'Tag','valDelay',...
		'Tooltip','Insert the delay');	


	textWindowSize = uicontrol('Parent',inputField, ...
		'Units', 'normalized', ...
		'Position', [.01 .4 .32 .2],...
		'BackgroundColor', [0.7020 0.7020 0.7020], ...
		'Style','text',... 
		'String','Window size :',...
		'HorizontalAlignment','right',...
		'Visible','on',...
		'Tag','textWindowSize',...
		'Tooltip','The size of the shifting window.');

	valWindowSize= uicontrol('Parent',inputField,...
		'Units', 'normalized', ...
		'Position', [.375 .4 .15 .24],...
		'BackgroundColor',[.801 .75 .688], ...
		'Style','edit',... 
		'String',num2str(ws),...
		'HorizontalAlignment','right',...
		'Visible','on',...
		'Tag','valWindowSize',...
		'Tooltip','Insert the window size.');


	textStepSize = uicontrol('Parent',inputField, ...
		'Units', 'normalized', ...
		'Position', [.55 .4 .25 .2],...
		'BackgroundColor',[0.7020 0.7020 0.7020], ...
		'Style','text',... 
		'String','Step size :',...
		'HorizontalAlignment','left',...
		'Visible','on',...
		'Tag','textStepSize',...
		'Tooltip','The number of steps by which the window is shifted.');

	valStepSize= uicontrol('Parent',inputField,...
		'Units', 'normalized', ...
		'Position', [.875 .4 .1 .24],...
		'BackgroundColor',[.801 .75 .688], ...
		'Style','edit',... 
		'String',num2str(ss),...
		'HorizontalAlignment','right',...
		'Visible','on',...
		'Tag', 'valStepSize',...
		'Tooltip','Insert the step size.');

	textNormalise = uicontrol('Parent',inputField, ...
		'Units', 'normalized', ...
		'Position', [.01 .14 .275 .2],...
		'BackgroundColor',[0.7020 0.7020 0.7020], ...
		'Style','text',... 
		'String','Normalise?',...
		'HorizontalAlignment','right',...
		'Visible','on',...
		'Tag','textNormalise',...
		'Tooltip','If checked the entropy will be normalised. The data not!');

	valNormalise = uicontrol('Parent',inputField, ...
		'Units', 'normalized', ...
		'Position', [.3 .15 .1 .2],...
		'BackgroundColor',[0.7020 0.7020 0.7020], ...
		'Style','checkbox',... 
		'HorizontalAlignment','right',...
		'Visible','on',...
		'Tag','valNormalise',...
		'Tooltip','Check to normalise entropy, data won''t be touched');

%%%%%%%%%%%%%%%%%%%%%
%	Define buttons	%
%%%%%%%%%%%%%%%%%%%%%

	buttonStore = uicontrol('Parent',figHandle, ...
		'Units', 'normalized', ...
		'Position', [.61 .1 .13 .05],...
		'BackgroundColor',[.801 .75 .688], ...
		'Style','pushbutton',... 
		'String','Store',...
		'Visible','on', ...
		'Tooltip','Store the permutation entropy vector.',...
		'Callback',{@buttonStoreCallback});

	buttonClose = uicontrol('Parent',figHandle, ...
		'Units', 'normalized', ...
		'Position', [.61 .05 .13 .05],...
		'BackgroundColor',[.801 .75 .688], ...
		'Style','pushbutton',... 
		'String','Close',...
		'Visible','on', ...
		'Tooltip','Close the GUI',...
		'Callback',{@buttonCloseCallback});

	buttonCompute = uicontrol('Parent',figHandle, ...
		'Units', 'normalized', ...
		'Position', [.75 .05 .15 .1],...
		'BackgroundColor',[.801 .75 .688], ...
		'Style','pushbutton',... 
		'String','Compute',...
		'FontWeight','bold',...
		'Visible','on', ...
		'Tooltip','Start the computation',...
		'Callback',{@buttonComputeCallback,X});

%%%%%%%%%%%%%%%%%
%	fancy stuff	%
%%%%%%%%%%%%%%%%%

	textNLD = uicontrol('Parent',figHandle,...
		'Units', 'normalized', ...
		'Position',[.01 .05 .2 .2],...
		'Style','text',... 
		'BackgroundColor',[.801 .75 .688], ... 
		'Tag', 'NLD ',...
		'FontSize',9,...
		'String',sprintf('Nonlinear \n Dynamics \n Group \n\n University of Potsdam\n (c) 2008'),...
		'ToolTip','The Nonlinear Dynamics Group http://www.agnld.uni-potsdam.de');

	textTitle = uicontrol('Parent',figHandle,...
		'Units', 'normalized', ...
		'Position',[.3 .93 .4 .05],...
		'Style','text',... 
		'HorizontalAlign','center',...
		'BackgroundColor',[.801 .75 .688], ... 
		'Tag', 'title',...
		'String',sprintf('Permutation Entropy H(n) GUI'),...
		'FontWeight','bold');
