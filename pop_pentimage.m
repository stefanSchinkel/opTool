function pop_pentimage(varargin)

%pop_pentimage GUI for pentimage
%
% function pop_pentimage (EEG,order,ws,ss,[time])
%
% erpimage()-like plot of windowed permuation entropy
%
% Input:
%	EEG = matrix (trials,time)
%
% Parameter:
%	order = order of entropy
%	ws = window size
%	ss = step size (default: 1)
%	timescale = vector of latencies (in ms) for each epoch time point
%
% Parameters (except timescale) can be changed interactively 
% using the GUI. Furhter the colourmap for the plot can be alterted
% via the GUI.
%
% requires: pent.m
%
% see also: pent.m pent2.m opTool
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

% $Log: pop_pentimage.m,v $
% Revision 1.1  2007/08/20 10:45:36  schinkel
% Initial Import
%


%% debug settings
debug = 0;
if debug;warning('on','all');else warning('off','all');end

% I/O check
if (nargchk(1,5,nargin)), help(mfilename),error(nargchk(2,4,nargin)); end
if (nargchk(0,2,nargout)), help(mfilename),error(nargchk(0,2,nargout)); end


%% check input
varargin{5} = [];

if ndims(varargin{1}) > 2; 	error(help(mfilename));	else X = varargin{1}; 		end
if ~(2< varargin{2} < 13); 	error(help(mfilename));	else order = varargin{2};	end
if ~isempty(varargin{3}); 	delay = varargin{3}; 	else delay = []; 			end
if ~isempty(varargin{4}); 	ws = varargin{4};		else ws = [];				end
if ~isempty(varargin{5}); 	ss = varargin{5}; 		else ss = [];				end

screenSize = get(0,'Screensize');

%%%%%%%%%%%%%%%%%
%	Define GUI	%
%%%%%%%%%%%%%%%%%

figHandle = figure('Name','PENTIMAGE GUI',... 
'Position',[50,screenSize(4)-650,630,470],... % top left corner 
'Color',[.801 .75 .688], ... 
'Menubar','Figure');% choose 'Menubar','figure' to run into trouble


%%%%%%%%%%%%%%%%%
%	Layout GUI	%
%%%%%%%%%%%%%%%%%

set(figHandle,'visible','off')
pentimageLayout;
set(figHandle,'visible','on')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%	associate callbacks		%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
set(buttonStore,'Callback',{@buttonStoreCallback});
set(buttonClose,'Callback',{@buttonCloseCallback});
set(buttonCompute,'Callback',{@buttonComputeCallback,X});
set(valColourMap,'Callback',{@valColourMapCallback,colourMaps})

end % main()
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%	callback definitions	%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function buttonStoreCallback(source,eventdata) 

	%% get data & assing to workspace if not empty
	Hn = get(get(source,'Parent'),'Userdata');

	if isempty(Hn);warndlg('No data found. Compute first.','No Data','modal');return;end

	%create input dialog
	defaultAnswer = {'Hn'};
	%convert to char, inputdlg returns cellarray
	varname = cell2mat(inputdlg('Enter variable name','Store H(n)',1,defaultAnswer));
	
	if isempty(varname);return;end	
	if ~isvarname(varname);warndlg('Not a valid variable name','Variable name error','modal');return;end
	try
		assignin('base',varname, Hn);
		msgbox(sprintf('H(n) data stored as %s in your workspace.',varname),'Data stored');
	catch 
		warndlg('Could not store data!','Data storage	error');
	end

end %buttonStoreCallback

function buttonCloseCallback(source,eventdata) 

	close( get(source,'Parent') )

end % buttonCloseCallback	

function valColourMapCallback(source,eventdata,colourMaps)

	%get selected map
	map = get(source,'Value');
	colormap(colourMaps{map});

end % valColourMapCallback

function buttonComputeCallback(source,eventdata,varargin)
	
	figHandle = get(source,'Parent');
	
	%% assign input
	X = varargin{1}; 
	
	axSurf = findobj(figHandle,'Tag','axSurf');
	order = str2num( get(findobj(figHandle,'Tag','valOrder') ,'String') );
	delay = str2num( get(findobj(figHandle,'Tag','valDelay') ,'String') );
	ws = str2num( get(findobj(figHandle,'Tag','valWindowSize') ,'String') );
	ss = str2num( get(findobj(figHandle,'Tag','valStepSize') ,'String') );
	flagNormalise = get( findobj(figHandle,'Tag','valNormalise'),'Value' );
	colourMap = get( findobj(figHandle,'Tag','valColourMap') ,'Value');



	%% catch errors
	if isempty(order) || order < 2 || order >12 
		warndlg('Please choose an order between 2 & 12 !','Order error','modal');return;
	end
	if ws > length(X)
		warndlg('Chosen window larger than time series.','Window error','modal');return
	end
	if ws <= order + 1;
		warndlg('Chosen window too small.','Window size error','modal');return
	end

	%% clear axes
	axes(axSurf);
	cla(axSurf,'reset');
	set(axSurf,'Box','on',...
		'Tag','axSurf',...
		'XTick',[],...
		'YTick',[]);
			
	%% busy text
	text(.3, .45,'Computing permutation entropy',...
		'Fontweight','bold',...
		'Fontsize',14);
	drawnow;

	% compute permutation entropy
	try
		for i = 1:size(X,1);
			if flagNormalise
				[dummy Hn(i,:)] = pent(X(i,:),order,delay,ws,ss);
			else	
				Hn(i,:) = pent(X(i,:),order,delay,ws,ss);
			end
		end
	catch
		errordlg(lasterr,'Compute Error','modal');
		return;
	end
	
	%% clear temp text
	axes(axSurf);
	cla(axSurf,'reset');
	set(axSurf,'Box','on',...
		'Tag','axSurf');

	%% plot the data

	% fix plot for surface
	[m,n] = size(Hn);
	flagFixAxes = logical(0); 

	if m == 1; 
		Hn = [Hn;Hn];
		flagFixAxes = 1; 
	else 
		Hn(m+1,:) = 0; 
	end
	
	hSurf = surface(zeros(size(Hn)),Hn,'parent',axSurf);

	shading(axSurf,'flat');
	axis(axSurf,'tight');
	xlabel(axSurf,'time');
	ylabel(axSurf,'realisation/trials');

	%% fix axes
	if flagFixAxes
		axis(axSurf,[1 n+1 1 2]);
		set(axSurf,'Ytick',1:.5:2,'Ytickl',{'','1',''});
	else
			axis(axSurf,[1 n+1 1 m]);
	end
	
	title(axSurf,sprintf('H(%d) delay: %d window: %d step: %d',order,delay, ws,ss));
	colorbar('peer',axSurf);
	title(axSurf,sprintf('Permutation Entropy of order %d',order));
	ylabel(axSurf,'trial / epoch');
	set(get(source,'Parent'),'Userdata',Hn);

end % buttonComputeCallback

