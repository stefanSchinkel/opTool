function pop_rqaimage(varargin)

%pop_rqaimage GUI for plots of windowed oprqa measure 
%
% function pop_rqaimage (EEG,order,ws,ss,[times])
%
% erpimage()-like plot of windowed rqa measures
%
% Input:
%	EEG = matrix (trials,time)
%
% Parameter:
%	dimension = dimension/order of orderpattern
%	delay = time delay
%	ws = window size
%	ss = step size (default: 1)
%	theiler = size of theiler window
%	minDiag = mininmal length of diagonal lines
%	minVert = mininmal length of vertical lines
%	mode = ('full'/'small') compute rqa measures from small plot x(i):x(i+ws) or
%		full plot x(i) : x(i+ws+dimension*delay)
%
% Parameters can be changed/provided interactively 
% using the GUI. Further the colourmap for the plot can 
% be alterted via the GUI.
%
% If ss > 1, then the data is computed using the 'stretch' parameter of 
% opcrqa to have a better visualisation. See help opcrqa for details.
%
% requires: opcrqa.m
%
% see also: pop_opcrp.m pop_opcrqa.m
%
% Note: Limitation for dimension is 12 (due to Matlab precision)
%

% Copyright (C) 2007 Stefan Schinkel, University of Potsdam
% http://www.agnld.uni-potsdam.de 
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 3 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.

% $Log: pop_rqaimage.m,v $
% Revision 1.2  2007/08/23 12:41:19  schinkel
% Fixed surface plot problem
%
% Revision 1.1  2007/08/20 10:24:23  schinkel
% Initial Import
%


%% debug settings
debug = 0;
if debug;warning('on','all');else warning('off','all');end

%% check number of input arguments
error(nargchk(1,10,nargin))

%% check number of out arguments
error(nargoutchk(0,0,nargout))

%% check input
varargin{11} = [];

if sum(size(varargin{1})) == 2; help(mfilename);error('Bad input format');else X = varargin{1};end
if isempty(varargin{2}),dim = 2;else dim = varargin{2};end
if isempty(varargin{3}),tau = 1;else tau = varargin{3};end
if isempty(varargin{4}),ws = size(X,2);else ws = varargin{4};end
if isempty(varargin{5}),ss = 1;else ss = varargin{5};end
if isempty(varargin{6}),theiler = 1;else theiler = varargin{8};end
if isempty(varargin{7}),minDiag = 2;else minDiag = varargin{6};end
if isempty(varargin{8}),minVert = 2;else minVert = varargin{7};end
if isempty(varargin{9}),rpMode = 'small';else rpMode = varargin{9};end
if isempty(varargin{10}),tScale = [];else tScale = varargin{10};end


%% check some params
if ndims(X) > 2; help(mfilename);error('N-dimensional computation not possible (yet)');end
if strcmp('full',rpMode),valPlotSizeValue = 2; else valPlotSizeValue = 1;end
if isempty(tScale);
	tScale = 1:1:size(X,2);
else
	if length(tScale) ~= size(X,2);
		warndlg('Time Scale is not matching data. Not using it','Time Scale Error','modal');
	end
end

%% vars neccessary

%measure
measures = {'RR','DET','L','Lmax','ENT','LAM','TT','Vmax'};

%colourmaps
colourMaps = {'hsv','hot','gray','bone','copper','pink','white','flag','lines','vga',...
	'jet','prism','cool','autumn','spring','winter','summer'};


screenSize = get(0,'Screensize');

%%%%%%%%%%%%%%%%%%%%%%%
%			Define GUI			%
%%%%%%%%%%%%%%%%%%%%%%%
figHandle = figure('Name','RQAIMAGE GUI',... 
'Position',[50,screenSize(4)-650,800,600],... % top left corner 
'Color',[.801 .75 .688], ... 
'Tag','mainFigure',...
'Menubar','none');% choose 'Menubar','figure' to run into trouble


%%%%%%%%%%%%%%%%%%%%%%%
%			Layout GUI			%
%%%%%%%%%%%%%%%%%%%%%%%

set(figHandle,'visible','off')
rqaimageLayout;
set(figHandle,'visible','on')

end %% main

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%			associate callbacks		%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function valColourMapCallback(source,eventdata,colourMaps)

	figHandle = get ( get(source,'Parent'),'Parent');

	%% get params
	axSurf = findobj(figHandle,'Tag','axSurf');
	if isempty(axSurf);
		return;
	else
		map = get(source,'Value');
		colormap(axSurf,colourMaps{map});
	end
end %valColourMapCallback

function valMeasureChooserCallback(source,eventdata,tScale,measures)

	figHandle = get ( get(source,'Parent'),'Parent');

	%% get params
	measure = get(source,'Value');
	
	axSurf = findobj(figHandle,'Tag','axSurf');
	dim = str2num( get( findobj(figHandle,'Tag','valDim'),'String'));
	tau = str2num( get( findobj(figHandle,'Tag','valTau'),'String'));
	
	%get data
	rqa = get( figHandle,'Userdata');
	if isempty(rqa);return;end

	%% param check
	cols = size(rqa,1);
	rows = size(rqa,2);

	
	%plot the data
	cla(axSurf);
	
	%plot the data
	cla(axSurf);
	toPlot = rqa(:,:,measure);
	[m,n] = size(toPlot);
	if m == 1; toPlot = [toPlot;toPlot]; else toPlot(m+1,:) = 0; end
	if n == 1; toPlot = [toPlot toPlot];end
	

	surface(zeros(size(toPlot)),toPlot,'Parent',axSurf);

	axis(axSurf,'tight');
	shading(axSurf,'flat');
	surfTitle = title(axSurf,sprintf('RQAimage for measure %s dim: %d tau %d',measures{measure},dim,tau));
	set(surfTitle,'FontWeight','bold');
	set(axSurf,'Xtick',0:50:rows,...
			'XTickl',tScale(1:50:rows),...
			'YTick',0:5:cols+1);
						
end %valColourMapCallback

function buttonStoreCallback(source,eventdata) 

	%% get RQA data & assing to workspace if not empty
	rqa = get(get(source,'Parent'),'Userdata');

	if isempty(rqa);warndlg('No data found. Compute first.','No Data','modal');return;end

	%create input dialog
	defaultAnswer = {'rqa'};
	%convert to char, inputdlg returns cellarray
	varname = cell2mat(inputdlg('Enter variable name','Store RQA',1,defaultAnswer));
	
	if isempty(varname);return;end
	if ~isvarname(varname);warndlg('Not a valid variable name','Variable name error','modal');return;end
	try
		assignin('base',varname, rqa);
		msgbox(sprintf('RQA data stored as %s in your workspace.',varname),'Data stored');
	catch 
		warndlg('Could not store data!','Data storage	error');
	end

end %buttonStoreCallback

function buttonCloseCallback(source,eventdata) 

	close( get(source,'Parent') )

end % buttonCloseCallback

function buttonComputeCallback(source,eventdata,X,measures,colourMaps,tScale)
	
	figHandle = get(source,'Parent');

	%% necessary vars
	rpMode = {'small','full'};

	% graphic handles
	axSurf = findobj(figHandle,'Tag','axSurf');
	hColourbar = findobj(figHandle,'Tag','Colourbar');
	
	%opcrqa params
	dim = str2double( get( findobj(figHandle,'Tag','valDim'),'String') );
	tau = str2double( get( findobj(figHandle,'Tag','valTau'),'String') );
	ws = str2double( get( findobj(figHandle,'Tag','valWindowSize'),'String') );
	ss = str2double( get( findobj(figHandle,'Tag','valStepSize'),'String') );
	theiler = str2double( get( findobj(figHandle,'Tag','valTheiler'),'String') );
	minDiag = str2double( get( findobj(figHandle,'Tag','valMinDiag'),'String') );
	minVert = str2double( get( findobj(figHandle,'Tag','valMinVert'),'String') );
	plotSize = get( findobj(figHandle,'Tag','valPlotSize'),'Value');
	measure = get( findobj(figHandle,'Tag','valMeasureChooser'),'Value');
	colourMap = get( findobj(figHandle,'Tag','valColourMap'),'Value');

	%% param check
	cols = size(X,1);
	rows = size(X,2);

	%% param check
	if ( (dim-1)*tau ) > rows;
		warndlg('ERROR: patterns longer than data','Check parameters','modal');return;
	end
	if ws > rows; 
		warndlg('ERROR: Window too large','Check parameters','modal');return;
	end

	if ws < (dim+1)*tau;
		warndlg('ERROR: Window too small','Check parameters','modal');return;
	end

	if theiler > rows/2; 
		warndlg('ERROR: Theiler window too large','Check parameters','modal');return;
	end
	
	if 	strcmp(rpMode{plotSize},'full')
		if ws+dim*tau > rows;
			warndlg('ERROR: patterns longer than data','Check parameters','modal');return;
		end
	end

	%% calc rqa

	hWaitbar = waitbar(0,'Computing RQA measures ....','WindowStyle','modal');

	try
		for i = 1:cols
			rqa(i,:,:) = opcrqa(X(i,:),dim,tau,ws,ss,theiler,minVert,minDiag,rpMode{plotSize},'stretch');
			waitbar(i/cols,hWaitbar);
		end
	catch
		warndlg('Error while computing RQA measures','Compute Error','modal');
	end
	close(hWaitbar);
	
	%% store data in GUI
	set( get(source,'Parent'),'UserData',rqa );
	
	%plot the data
	cla(axSurf);
	toPlot = rqa(:,:,measure);
	[m,n] = size(toPlot);
	if m == 1; toPlot = [toPlot;toPlot]; else toPlot(m+1,:) = 0; end
	if n == 1; toPlot = [toPlot toPlot];end
	
	surface(zeros(size(toPlot)),toPlot,'Parent',axSurf);
		
	axis(axSurf,'tight');
	shading(axSurf,'flat');
	surfTitle = title(axSurf,sprintf('RQAimage for measure %s dim: %d tau %d',measures{measure},dim,tau));
	set(surfTitle,'FontWeight','bold');
	set(axSurf,'Xtick',0:50:rows,...
			'XTickl',tScale(1:50:rows)-1,...
			'YTick',0:5:cols+1);

	hColourbar = colorbar('peer',axSurf,...
		'Box','on',...
		'Tag','Colourbar');
	
end % buttonComputeCallback
