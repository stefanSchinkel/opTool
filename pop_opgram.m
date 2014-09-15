function pop_opgram(varargin)

%pop_opgram GUI for opgram
%
% function pop_opgram (X,[dim,tau])
%
% GUI to opgram. The GUI provides the additional 
% features of pattern transcoding and reversi 
% transformation (for d = 3). Later implementation will
% be able to handle any number of d.
%
% Input:
%	X = matrix (trials,time)
%
% Parameters:
%	dim = embedding dimension / order 
%	tau = time delay used in 
%
% Parameters can be provided at the prompt
% or via the GUI. 
%
% requires: opTool
%
% see also: opsra.m wordstat.m  opTool
%
% Note: Limitation for dimension/order is 12 (due to Matlab precision)
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

% $Log: pop_opgram.m,v $
% Revision 1.5  2007/11/09 14:42:50  schinkel
% Added trancoding and reversi
%
% Revision 1.4  2007/10/25 13:58:11  schinkel
% Fixed Bug in data storage
%
% Revision 1.3  2007/08/23 12:28:45  schinkel
% Fixed ambigue naming of storage var
%
% Revision 1.2  2007/08/23 12:26:31  schinkel
% Fixed plot problem with vector input
%
% Revision 1.1  2007/08/20 11:00:00  schinkel
% Initial Import
%


%% debug settings
debug = 0;
if debug;warning('on','all');else warning('off','all');end

% check number of input arguments
error(nargchk(1,3,nargin))

% check number of out arguments
error(nargoutchk(0,0,nargout))

%% check input
varargin{4} = [];

if ndims(varargin{1}) > 2;
	help(mfilename);error('Sorry n-dimensional input not yet supported');
else 
	X = varargin{1};
end
if ~isempty(varargin{2}); dim = varargin{2}; else dim = [];end
if ~isempty(varargin{3}); tau = varargin{3}; else tau = 0; end

screenSize = get(0,'Screensize');

%%%%%%%%%%%%%%%%%%%%%%%
%			Define GUI			%
%%%%%%%%%%%%%%%%%%%%%%%
figHandle = figure('Name','OPGRAM GUI',... 
	'Position',[50,screenSize(4)-650,800,600],... % top left corner 
	'Color',[.801 .75 .688], ... 
	'Tag','mainFigure',...
	'Menubar','none');% choose 'Menubar','figure' to run into trouble


%%%%%%%%%%%%%%%%%%%%%%%
%			Layout GUI			%
%%%%%%%%%%%%%%%%%%%%%%%

set(figHandle,'visible','off');
opgramLayout;
set(figHandle,'visible','on');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%			associate callbacks		%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

set(valColourMap,'Callback',{@valColourMapCallback,colourMaps})
set(buttonStore,'Callback',{@buttonStoreCallback});
set(buttonClose,'Callback',{@buttonCloseCallback});
set(buttonCompute,'Callback',{@buttonComputeCallback,X,colourMaps});
set(buttonTranscode,'Callback',{@buttonTranscodeCallback,colourMaps});
set(buttonReversi,'Callback',{@buttonReversiCallback,colourMaps});


end % main()

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% callback definitions	%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function buttonStoreCallback(source,eventdata) 

	%% get opgram
	opgram = get(get(source,'Parent'),'Userdata');

	if isempty(opgram);warndlg('No data found. Compute first.','No Data','modal');return;end

	opgram(end-1,:) = [];

	%convert to char, inputdlg returns cellarray
	varname = cell2mat(inputdlg('Enter variable name','Store output',1,{'ops'}));

	if isempty(varname);return;end	
	if ~isvarname(varname);warndlg('Not a valid variable name','Variable name error','modal');return;end
	try
		assignin('base',varname, opgram);
		msgbox(sprintf('Opgram stored as %s in your workspace.',varname),'Data stored');
	catch 
		warndlg('Could not store data!','Data storage	error');
	end

end %buttonStoreCallback



function buttonCloseCallback(source,eventdata) 
	close( get(source,'Parent') )
end % buttonCloseCallback	



function valColourMapCallback(source,eventdata,colourMaps)

	figHandle = get( get(source,'Parent'),'Parent');

	%get map & bar scaling
	map = get(source,'Value');
	nColours = numel(unique( get( figHandle,'Userdata')));

	%% adjust colourmap
	if nColours > 1; %% no data yet, just look a different maps
		cString = colourMaps{map};
		funcHandle = str2func(cString);
		colormap(funcHandle( nColours ));
	else
		colormap(colourMaps{map});
	end

end % valColourMapCallback



function buttonComputeCallback(source,eventdata,varargin)

	figHandle = get(source,'Parent');

	%% assign input
	X = varargin{1};
	colourMaps = varargin{2};
	
	axSurf = findobj(figHandle,'Tag','axSurf');
	hValDim = findobj(figHandle,'Tag','valDim');
	hValTau = findobj(figHandle,'Tag','valTau');
	hValColourMap = findobj(figHandle,'Tag','valColourMap');
	hColourbar =  findobj(figHandle,'Tag','Colourbar');
		
	dim = str2num( get(hValDim,'String') );
	tau = str2num( get(hValTau,'String') );
	map = get(hValColourMap,'Value');

	
	% get params
	trials = size(X,1);
	time = size(X,2);

	%% check if input makes sense (general)
	if isempty(dim);
		warndlg('Please provide a dimension/order value','Missing Input error','modal');return;
	end
	if isempty(tau);
		tau = 0; 
	end

	if ~(2< dim < 13); 
		warndlg('Please choose an dimension/order between 2 & 12 !','Dimension/order error','modal');return;
	end
	if dim + ((tau-1)*dim) > time;
		warndlg('Time series to short for given parameters','Data error','modal');return;
	end
	
	%% clear axes
	axes(axSurf);
	cla(axSurf,'reset');
	set(axSurf,'Box','on',...
		'Tag','axSurf',...
		'Xtick',[],...
		'YTick',[]);
	
	% compute stuff
	if tau == 0;

		%% busy text
		text(.3, .45,'Estimating embedding delays ...',...
			'Fontweight','bold',...
			'Fontsize',14);
		drawnow;

		%% estDelay
		try
			for i = 1:trials
				tau(i) = estDelay(X(i,:));
			end
		catch
			warndlg('Error while estimating delay. Check data layout/parameter',...
				'Estimation	Error','modal')
			return;
		end
		%% allocate opgram for max length
		ops = zeros(trials,time-dim);

		%% busy text 2
		cla(axSurf,'reset');
		set(axSurf,'Box','on',...
		'Tag','axSurf',...
		'Xtick',[],...
		'YTick',[]);
		
		text(.3, .45,'Computing order patterns...',...
			'Fontweight','bold',...
			'Fontsize',14);
		drawnow;

		%% compute
		try
			for i = 1:trials
				OP = opCalc(X(i,:),dim,tau(i));
				ops(i,1:length(OP)) = OP(1:length(OP));
			end
		catch
			warndlg('Error while computing patterns. Check data layout/parameter',...
				'Compute Error','modal')
			return
		end	
		
	else

		%% allocate opgram for max length
		%ops = zeros(trials,(time-(dim-1)*tau) );
		
		%% busy text
		text(.3, .45,'Computing order patterns...',...
			'Fontweight','bold',...
			'Fontsize',14);
		drawnow;

		%% compute
		try 
			for i = 1:trials
				ops(i,:) = opCalc(X(i,:),dim,tau);
			end
		catch
			warndlg('Error while computing patterns. Check data layout/parameter',...
				'Compute Error','modal')
			return
		end		
		
	end	% estDelaySwitch

	% fix plot for surface
	[m,n] = size(ops);
	if m == 1; 
		ops = [ops;ops];fixAxes = 1;
	else 
		ops(m+1,:) = ops(m,:);
		fixAxes = 0;
	end
	
	%% clear plot
	cla(axSurf,'reset');
	set(axSurf,'Box','on','Tag','axSurf');

	%% plot
	hSurf = surface(zeros(size(ops)),ops,'parent',axSurf);
	shading(axSurf,'flat');

	%% fix axes
	if fixAxes,	
		axis(axSurf,[1 n 1 2]);
		set(axSurf,'Ytick',[1:.5:2],'Ytickl',{'','1',''});
	else
		axis(axSurf,[1 n 1 m+1]);
	end
	
	% adjust title
	if length(tau) == 1
		title(axSurf,sprintf('OPGRAM Dimension/order: %d Delay: %d',dim,tau));
	else
		title(axSurf,sprintf('OPGRAM Dimension/order: %d Delay: auto',dim));
	end
		
	%% adjust colormap
	cString = colourMaps{map};
	funcHandle = str2func(cString);
	colormap(funcHandle( numel(unique(ops)) ));
	
	%% fix Colourbar
	hColourbar = colorbar('Location','South',...
	'Position',[.1 .2 .8 .025],...
	'YTick',[],...
	'YTickMode','manual',...
	'XTick',[],...
	'XTickMode','manual',...
	'Box','on',...
	'Tag','Colourbar');

	%% delete added zeros (from plotting)
	ops(end,:) = [];

	set(get(source,'Parent'),'Userdata',ops);
	if dim == 3 && str2num( get(hValTau,'String') ) ~= 0
		set( findobj(figHandle,'Tag','buttonTranscode'),'Enable','on');
	end
	
end % buttonComputeCallback

function buttonTranscodeCallback(source,eventdata,varargin)
	
	%% neccessary params
	figHandle = get(source,'Parent');
	axSurf = findobj(figHandle,'Tag','axSurf');
	hValColourMap = findobj(figHandle,'Tag','valColourMap');
	hColourbar =  findobj(figHandle,'Tag','Colourbar');
	map = get(hValColourMap,'Value');

	%fetch data
	colourMaps = varargin{1};
	ops = get( figHandle ,'Userdata');
	
	if isempty(ops)
			warndlg('No opgram found. Compute first','No data error','modal');
			return;
	end

	%% check if data fits
	if numel(unique(ops)) ~= 6,
			warndlg('Sorry transcoding for d > 3 not yet defined','Transcoding Error','modal');
			return;
	end
	
	%% transcode 
	
	axes(axSurf);
	cla(axSurf,'reset');
	set(axSurf,'Box','on',...
		'Tag','axSurf',...
		'Xtick',[],...
		'YTick',[]);

	%% busy text
	text(.3, .45,'Transcoding patterns...',...
			'Fontweight','bold',...
			'Fontsize',14);
	drawnow;

	sym3 = transcodePatterns(ops);

	%% clear plot
	cla(axSurf,'reset');
	set(axSurf,'Box','on','Tag','axSurf');

	%% plot
	hSurf = surface(zeros(size(sym3)),sym3,'parent',axSurf);
	shading(axSurf,'flat');
	axis tight;

	%% adjust colormap
	cString = colourMaps{map};
	funcHandle = str2func(cString);
	colormap(funcHandle( 3 ));

	%% fix Colourbar
	hColourbar = colorbar('Location','South',...
	'Position',[.1 .2 .8 .025],...
	'YTick',[],...
	'YTickMode','manual',...
	'XTick',[],...
	'XTickMode','manual',...
	'Box','on',...
	'Tag','Colourbar');

	%% enable reversi
	set( findobj(figHandle,'Tag','buttonTranscode'),'Enable','off');
	set( findobj(figHandle,'Tag','buttonReversi'),'Enable','on');
	set( get(source,'Parent'),'Userdata',sym3);

end % buttonTranscodeCallback

function buttonReversiCallback(source,eventdata,varargin)
	
	%% neccessary params
	figHandle = get(source,'Parent');
	axSurf = findobj(figHandle,'Tag','axSurf');
	hValColourMap = findobj(figHandle,'Tag','valColourMap');
	hColourbar =  findobj(figHandle,'Tag','Colourbar');
	map = get(hValColourMap,'Value');

	%% fetch data
	colourMaps = varargin{1};
	sym3 = get( figHandle ,'Userdata');
	
	if isempty(sym3)
			warndlg('No data found. Compute first','No data error','modal');
			return;
	end

	%% check if data fits
	if numel(unique(sym3)) ~= 3,
			warndlg('Can only reversi tranform of 3 symbols!','Reversi Error','modal');
			return;
	end
	

	%% activate & clear axes
	axes(axSurf);
	cla(axSurf,'reset');
	set(axSurf,'Box','on',...
		'Tag','axSurf',...
		'Xtick',[],...
		'YTick',[]);

	%% busy text
	text(.3, .45,'Performing reversi transformation...',...
			'Fontweight','bold',...
			'Fontsize',14);
	drawnow;
	
	%% rransform
	sym2 = reversi(sym3);

	%% clear plot
	axes(axSurf);
	cla(axSurf,'reset');
	set(axSurf,'Box','on',...
		'Tag','axSurf',...
		'Xtick',[],...
		'YTick',[]);

	%% plot
	hSurf = surface(zeros(size(sym2)),sym2,'parent',axSurf);
	shading(axSurf,'flat');
	axis tight;

	%% adjust colormap
	cString = colourMaps{map};
	funcHandle = str2func(cString);
	colormap(funcHandle( 2 ));

	%% fix Colourbar
	hColourbar = colorbar('Location','South',...
	'Position',[.1 .2 .8 .025],...
	'YTick',[],...
	'YTickMode','manual',...
	'XTick',[],...
	'XTickMode','manual',...
	'Box','on',...
	'Tag','Colourbar');

	%% enable reversi

	set( findobj(figHandle,'Tag','buttonReversi'),'Enable','off');
	set( get(source,'Parent'),'Userdata',sym2);
	
end % buttonReversiCallback
