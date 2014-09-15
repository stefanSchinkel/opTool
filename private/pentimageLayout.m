%%%%%%%%%%%%%%%%%%%%%%%
%			Define axes			%
%%%%%%%%%%%%%%%%%%%%%%%

axSurf = axes('Parent',figHandle,...
	'Position',[.1 .25 .8 .65],...
	'Tag', 'axSurf',...
	'NextPlot','replace',...
	'Xtickl',[],...
	'Ytickl',[],...
	'Box','on');

%%%%%%%%%%%%%%%%%%%%%%%%%
% Define input fields	%
%%%%%%%%%%%%%%%%%%%%%%%%%

inputField = uibuttongroup('Position', [.225 .01 .374  .15],...
	'visible','on');

	textOrder = uicontrol('Parent',inputField, ...
		'Units', 'normalized', ...
		'Position', [.01 .5 .35 .2],...
		'BackgroundColor',[0.7020 0.7020 0.7020], ...
		'Style','text',... 
		'String','Order/Dim:',...
		'HorizontalAlignment','left',...
		'Visible','on',...
		'Tag','textOrder',...
		'Tooltip','The order is the number of points forming the OPs');


	valOrder = uicontrol('Parent',inputField,...
		'Units', 'normalized', ...
		'Position', [.325 .5 .1 .24],...
		'BackgroundColor',[.801 .75 .688], ...
		'Style','edit',... 
		'String',num2str(order),...
		'HorizontalAlignment','right',...
		'Visible','on',...
		'Tag','valOrder',...
		'Tooltip','Insert the order (2-13)');	

	textDelay = uicontrol('Parent',inputField, ...
		'Units', 'normalized', ...
		'Position', [.5 .5 .2 .2],...
		'BackgroundColor',[0.7020 0.7020 0.7020], ...
		'Style','text',... 
		'String','Delay:',...
		'HorizontalAlignment','left',...
		'Visible','on',...
		'Tag','textDelay',...
		'Tooltip','Delay denotes the discrete distance between the points of the OPs');


	valDelay = uicontrol('Parent',inputField,...
		'Units', 'normalized', ...
		'Position', [.8 .5 .1 .24],...
		'BackgroundColor',[.801 .75 .688], ...
		'Style','edit',... 
		'String',num2str(delay),...
		'HorizontalAlignment','right',...
		'Visible','on',...
		'Tag','valDelay',...
		'Tooltip','Insert the delay');	


	textWindowSize = uicontrol('Parent',inputField, ...
		'Units', 'normalized', ...
		'Position', [.01 .2 .32 .2],...
		'BackgroundColor', [0.7020 0.7020 0.7020], ...
		'Style','text',... 
		'String','Window size :',...
		'HorizontalAlignment','left',...
		'Visible','on',...
		'Tag','textWindowSize',...
		'Tooltip','The size of the shifting window.');

	valWindowSize= uicontrol('Parent',inputField,...
		'Units', 'normalized', ...
		'Position', [.325 .2 .1 .24],...
		'BackgroundColor',[.801 .75 .688], ...
		'Style','edit',... 
		'String',num2str(ws),...
		'HorizontalAlignment','right',...
		'Visible','on',...
		'Tag','valWindowSize',...
		'Tooltip','Insert the window size.');


	textStepSize = uicontrol('Parent',inputField, ...
		'Units', 'normalized', ...
		'Position', [.5 .2 .25 .2],...
		'BackgroundColor',[0.7020 0.7020 0.7020], ...
		'Style','text',... 
		'String','Step size :',...
		'HorizontalAlignment','left',...
		'Visible','on',...
		'Tag','textStepSize',...
		'Tooltip','The number of steps by which the window is shifted.');

	valStepSize= uicontrol('Parent',inputField,...
		'Units', 'normalized', ...
		'Position', [.8 .2 .1 .24],...
		'BackgroundColor',[.801 .75 .688], ...
		'Style','edit',... 
		'String',num2str(ss),...
		'HorizontalAlignment','right',...
		'Visible','on',...
		'Tag', 'valStepSize',...
		'Tooltip','Insert the step size.');

inputField2 = uibuttongroup('Position', [.6 .01 .14 .15],...
	'visible','on');


	textColourChooser = uicontrol('Parent',inputField2, ...
		'Units', 'normalized', ...
		'Position', [.1 .8 .8 .175],...
		'BackgroundColor',[0.7020 0.7020 0.7020], ...
		'Style','text',... 
		'String','Colourmap:',...
		'HorizontalAlignment','left',...
		'Visible','on',...
		'Tooltip','Choose the colourmap you would like to use');

	colourMaps = {'hsv','hot','gray','bone','copper',...
		'pink','white','flag','lines',...
		'jet','prism','cool','autumn','spring',...
		'winter','summer'};
		
	valColourMap = uicontrol('Parent',inputField2,...
		'Units', 'normalized', ...
		'Position',[.1 .5 .8 .25],...
		'Style','popupmenu',...
    	'String',colourMaps,...
		'Tag','valColourMap',...
		'Value',11);

	textNormalise = uicontrol('Parent',inputField2, ...
		'Units', 'normalized', ...
		'Position', [.1 .1 .7 .2],...
		'BackgroundColor',[0.7020 0.7020 0.7020], ...
		'Style','text',... 
		'String','Normalise?',...
		'HorizontalAlignment','left',...
		'Visible','on',...
		'Tag','textNormalise',...
		'Tooltip','If checked the entropy will be normalised. The data not!');

	valNormalise = uicontrol('Parent',inputField2, ...
		'Units', 'normalized', ...
		'Position', [.8 .1 .2 .2],...
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
		'Position', [.75 .11 .15 .05],...
		'BackgroundColor',[.801 .75 .688], ...
		'Style','pushbutton',... 
		'String','Store',...
		'Visible','on', ...
		'Tooltip','Store the data matrix.',...
		'Callback',{@buttonStoreCallback});

	buttonClose = uicontrol('Parent',figHandle, ...
		'Units', 'normalized', ...
		'Position', [.75 .06 .15 .05],...
		'BackgroundColor',[.801 .75 .688], ...
		'Style','pushbutton',... 
		'String','Close',...
		'Visible','on', ...
		'Tooltip','Close the GUI',...
		'Callback',{@buttonCloseCallback});

	buttonCompute = uicontrol('Parent',figHandle, ...
		'Units', 'normalized', ...
		'Position', [.75 .01 .15 .05],...
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
		'Position',[.01 .01 .2 .06],...
		'Style','text',... 
		'BackgroundColor',[.801 .75 .688], ... 
		'Tag', 'NLD ',...
		'FontSize',9,...
		'String',sprintf('University of Potsdam\n (c) 2008'),...
		'ToolTip','The Nonlinear Dynamics Group http://www.agnld.uni-potsdam.de');

	textTitle = uicontrol('Parent',figHandle,...
		'Units', 'normalized', ...
		'Position',[.3 .9 .4 .05],...
		'Style','text',... 
		'HorizontalAlign','center',...
		'BackgroundColor',[.801 .75 .688], ... 
		'FontSize',14,...
		'Tag', 'title',...
		'String',sprintf('Pentimage GUI'),...
		'FontWeight','bold');
