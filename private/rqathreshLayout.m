% Layout axes, title & slider


axSurf = axes('Parent',figHandle,...
	'Position',[.1 .1 .8 .8],...
	'Tag', 'axSurf',...
	'NextPlot','replace',...
	'Box','on',...
	'Xtick',[],...
	'YTick',[]);

title = uicontrol('Parent',figHandle, ...
		'Units', 'normalized', ...
		'Position',[.1 .9 .8 .05],...
		'BackgroundColor',[.801 .75 .688], ... 
		'Style','text',... 
		'String','Threshold: xx.xxx',...
		'HorizontalAlignment','right',...
		'Visible','on',...
		'FontSize',15,...
		'Tag','title',...
		'HorizontalAlignment','center');

slider = uicontrol('Parent',figHandle, ...
		'Units', 'normalized', ...
		'Position',[.1 .05 .8 .04],...
		'BackgroundColor',[0.7020 0.7020 0.7020], ...
		'Style','slider',... 
		'String','Dimension:',...
		'HorizontalAlignment','right',...
		'Visible','on',...
		'Tooltip','Move the slider to increase/decrease the threshold.');
		

%fancy stuff


textNLD = uicontrol('Parent',figHandle,...
	'Units', 'normalized', ...
	'Position',[.49 .01 .5 .02],...
	'Style','text',... 
	'BackgroundColor',[.801 .75 .688], ... 
	'Tag', 'NLD ',...
	'FontSize',9,...
	'String',sprintf('Stefan Schinkel University of Potsdam (c) 2007-%s',datestr(now,'yy')),...
	'ToolTip','The Nonlinear Dynamics Group http://www.agnld.uni-potsdam.de');
