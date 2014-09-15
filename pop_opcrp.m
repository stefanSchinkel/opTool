function pop_opcrp(varargin)

%pop_opcrp GUI for Order Patterns RPs.
% 
% Compute (Cross) recurrence plot based on 
% order patterns using a GUI.
%
% Input:
%	X = time series (vector)
%	Y = time series (vector)
%	dim = dimension (number of points)
%	tau = time delay (distance between points)
%
% Output:
%	if whished the RP can be stored in the workspace.
%
% requires: opcrp.m
%
% see also: opcrqa.m
%
%
% Due to memory limitiations the size of X/Y is limited
% to ~7500 time points (depending on the system uses).
% The maximal supported dimension is 12 (by Matlab)

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


% $Log: pop_opcrp.m,v $
% Revision 1.8  2008/02/14 14:21:00  schinkel
% Added transcoding feature
%
% Revision 1.7  2007/08/20 10:03:04  schinkel
% Better errorhandling. Improved consistency.
%
% Revision 1.6  2007/08/17 09:58:25  schinkel
% Improved storing facility
%
% Revision 1.5  2007/08/10 09:35:06  schinkel
% Added GPL note
%
% Revision 1.4  2007/07/31 12:11:24  schinkel
% Properly adjusted for Doc for m2html
%
% Revision 1.3  2007/07/31 11:14:15  schinkel
% Added Logo. Fancied Layout
%
% Revision 1.2  2007/07/27 13:10:01  schinkel
% Doc fixes
%
% Revision 1.1  2007/07/27 13:06:09  schinkel
% Initial Import.
%

%% debug settings
debug = 1;
if debug;warning('on','all');else warning('off','all');end

%% check number of input arguments
error(nargchk(1,4,nargin))

%% check number of out arguments
error(nargoutchk(0,0,nargout))

%% check && assign input
varargin{5} = [];
X = varargin{1};

if isempty(varargin{2}) | length(varargin{2}) == 1 % RP
	Y = X;
	dim = varargin{2};
	tau = varargin{3};
else % CRP
	Y = varargin{2};
	if length(X) ~= length(Y);error('Input vectors X and Y must be of the same length');end
	dim = varargin{3};
	tau = varargin{4};
end


%%%%%%%%%%%%%%%%%
%	Define GUI	%
%%%%%%%%%%%%%%%%%

figHandle = figure('Name','OPCRP GUI',... 
	'Position',[200,100,500,650],...,
	'Color',[.801 .75 .688], ... 
	'Menubar','none');% choose 'Menubar','figure' to run into trouble

%%%%%%%%%%%%%%%%%%%%%
%	Layout GUI		%
%%%%%%%%%%%%%%%%%%%%%

set(figHandle,'visible','off')
opcrpLayout;


%% bottom
plot(axDataBottom,X,'k');
set(axDataBottom,'Ytick',[],'Xlim',[0 length(X)]);
set(axDataBottom,'Tag','axDataBottom');

%% left
plot(axDataLeft,Y,1:length(Y),'k');
set(axDataLeft,'XTick',[],'XDir','reverse','Ylim',[0 length(Y)]);
set(axDataLeft,'Tag','axDataLeft');

%% show things
set(figHandle,'visible','on')

end %% end main()

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% callback definitions	%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function buttonCloseCallback(source,eventdata) 

	close( get(source,'Parent') )

end% buttonCloseCallback

function buttonStoreCallback(source,eventdata) 

	rp = get(get(source,'Parent'),'Userdata');

	if isempty(rp);warndlg('No data found. Compute first.','No Data','modal');return;end

	%create input dialog
	defaultAnswer = {'RP'};
	
	%convert to char, inputdlg returns cellarray
	varname = cell2mat(inputdlg('Enter variable name','Store Plot',1,defaultAnswer));
	
	if isempty(varname);return;end
	if ~isvarname(varname);warndlg('Not a valid variable name','Variable name error','modal');return;end

	try
		assignin('base',varname, rp);
		msgbox(sprintf('RP data stored as %s in your workspace.',varname),'Data stored');
	catch 
		warndlg('Could not store data!','Data storage	error');
	end

end %buttonStoreCallback


function buttonComputeCallback(source,eventdata,varargin)

	%% assing input
	X = varargin{1};
	Y = varargin{2};
	
	if X == Y; 
		rpType = 'Recurrence Plot';
	else 
		rpType = 'Cross - Recurrence Plot';
	end
	
	%% aquire handles
	figHandle = get(source,'Parent');
	
	axRP = findobj(figHandle,'Tag','axDataRP');
	axLeft = findobj(figHandle,'Tag','axDataLeft');
	dim = str2double( get( findobj(figHandle,'Tag','valDim'),'String') );
	tau = str2double( get( findobj(figHandle,'Tag','valTau'),'String') );
	flagSymbolise =   get( findobj(figHandle,'Tag','valSymbolise'),'Value') ;

	%% check
	if isnan (dim) || dim < 2 || dim >12 
		warndlg('Please enter a dimenision between 2 & 12 !','Dimension error','modal')
		return;
	end
	if isnan(tau)
		warndlg('Please enter a delay value !','Delay error','modal')
		return;
	end
	
	%% busytext
	axes(axRP);
	cla(axRP,'reset');
	set(axRP,'Box','on','XTick',[],'YTick',[],'Tag','axDataRP')
		
	%% busy text
	text(.3, .45,'Computing RP','Fontweight','bold','Fontsize',14);

	drawnow;

	try
		if flagSymbolise
			RP = symcrp(X,Y,dim,tau);	
			imagesc(RP);
			nColours = length(unique(RP));
			cmap = colormap(hsv(nColours-1));
			cmap(nColours,:) = 1; % whiten zeros needed
			cmap = flipud(cmap);
			colormap(cmap);
			set(axLeft,'Visible','off');
			
			cbHandle = colorbar('Position',get(axLeft,'Position'));
			set(cbHandle,'Ytick',[],...
				'Tag','Colourbar');
		else 
			if 	strcmp(get(axLeft,'Visible'),'off')
				set(findobj(figHandle,'Tag','Colourbar'),'Visible','off')
				set(axLeft,'Visible','on')
			end
			RP = opcrp(X,Y,dim,tau);
			imagesc(RP,[0 1]);
			c = colormap(gray(2));
			colormap(flipud(c));
		end
	catch
		warndlg('Error while computing RPs','Compute Error','modal');return
	end
	
	% plot
	set(axRP,'YDir','normal','YTick',[],'XTick',[],'Tag','axDataRP')
	title(sprintf('%s Dimension: %d Delay: %d',rpType,dim,tau));
	
	%store data	
	set(get(source,'Parent'),'Userdata',RP);

end%buttonComputeCallback

function buttonEstCallback(source,eventdata,varargin)

	X = varargin{1};Y = varargin{2};

	try
		delay = estDelay(X,Y);
	catch 
		warndlg('Error while estimating delay','Estimate Error','modal');return
	end

	set( findobj( get(source,'Parent'),'Tag','valTau'),'String',num2str(delay));

end%buttonEstCallback
