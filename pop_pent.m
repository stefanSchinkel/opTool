function pop_pent(varargin)

%POP_PENT compute permutation entropy (GUI)
% 
% Compute permutation entropy H(n) using a GUI.
%
% for details see >>help(pent)
%
% Output:
%	the resulting vector can be stored via the GUI.
%
%
% requires: pent.m
%
% see also: pop_pentimage.m
%
% Note: The maximal supported order is currently 12.

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


% $Log: pop_pent.m,v $
% Revision 1.6  2007/08/20 13:36:37  schinkel
% Added spatial computation. Now includes pop_pent2.m functionality
%
% Revision 1.5  2007/08/14 10:54:32  schinkel
% Fixed bug in plotting routine
%
% Revision 1.4  2007/08/10 12:44:32  schinkel
% Adjusted to fit new opCalc.m version
%
% Revision 1.3  2007/08/10 09:35:06  schinkel
% Added GPL note
%
% Revision 1.2  2007/08/10 08:30:59  schinkel
% user can choose name of output
%
% Revision 1.1  2007/08/09 14:34:12  schinkel
% Initial Import
%


%% debug settings
debug = 0;
if debug;warning('on','all');else warning('off','all');end

% I/O check
if (nargchk(1,5,nargin)), help(mfilename),error(nargchk(2,4,nargin)); end
if (nargchk(0,0,nargout)), help(mfilename),error(nargchk(0,0 ,nargout)); end

%% check && assign input
varargin{6} = [];

X = varargin{1};
if ~isempty(varargin{2});order = varargin{2};else order = 2;end
if ~isempty(varargin{3});delay = varargin{3};else delay = 1;end
if ~isempty(varargin{4});ws = varargin{4};else ws = length(X);end
if ~isempty(varargin{5});ss = varargin{5};else ss = 1;end

screenSize = get(0,'Screensize');


%%%%%%%%%%%%%%%%%%%%%
%	Define GUI		%
%%%%%%%%%%%%%%%%%%%%%

figHandle = figure('Name','PENT GUI',... 
'Position',[50,screenSize(4)-450,600,400],... % top left corner 
'Color',[.801 .75 .688], ... 
'Menubar','None');% choose 'Menubar','figure' to run into trouble

%%%%%%%%%%%%%%%%%%%%%
%	Layout GUI		%
%%%%%%%%%%%%%%%%%%%%%

set(figHandle,'visible','off')
pentLayout;

% data params & initial plotting
[rows cols] = size(X);
% plot original data
if rows == 1,
	plot(axDataTop,X);
else 
	hold(axDataTop,'all');
	plot(axDataTop,1:size(X,2),X);
end

title(axDataTop,'Underlying time series');
axis(axDataTop,'tight');

set(figHandle,'visible','on')

end %% main()


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%	callback definitions	%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function buttonCloseCallback(source,eventdata) 

	close( get(source,'Parent') )

end % buttonCloseCallback	

function buttonStoreCallback(source,eventdata) 

	Hn = get(get(source,'Parent'),'Userdata');

	if isempty(Hn);
		warndlg('No entropy data found. Compute first.','No Data','modal');return;
	end

	%create input dialog
	defaultAnswer = {'Hn'};

	%convert to char, inputdlg returns cellarray
	varname = cell2mat(inputdlg('Enter variable name','Store H(n)',1,defaultAnswer));
	
	if isempty(varname);
		return;
	end	
	if ~isvarname(varname);
		warndlg('Not a valid variable name','Variable name error','modal');return;
	end

	try
		assignin('base',varname, Hn);
		msgbox(sprintf('H(n) data stored as %s in your workspace.',varname),'Data stored');
	catch 
		warndlg('Could not store data!','Data storage	error');
	end

end %buttonStoreCallback

function buttonComputeCallback(source,eventdata,varargin)
	
	figHandle = get(source,'Parent');
	
	%% assign input
	X = varargin{1}; % data
	
	axDataTop = findobj(figHandle,'Tag','axDataTop');
	axDataBottom = findobj(figHandle,'Tag','axDataBottom');
	order = str2num( get( findobj(figHandle,'Tag','valOrder'),'String') );
	delay = str2num( get( findobj(figHandle,'Tag','valDelay'),'String') );
	ws = str2num( get( findobj(figHandle,'Tag','valWindowSize'),'String') );
	ss = str2num( get( findobj(figHandle,'Tag','valStepSize'),'String') );
	flagNormalise = get( findobj(figHandle,'Tag','valNormalise'),'Value' );

	% param error check
	if isempty(order) || order < 2 || order >12 
		warndlg('Please choose an order between 2 & 12 !',...
		'Order error','modal');return;
	end
	
	if ~(size(X,1) > 1 && size(X,2) > 1)
		X = X(:);
		if ws > length(X)
			warndlg('Chosen window larger than time series.',...
			'Window error','modal');return
		end
		if ws < order + 1;
			warndlg('Chosen window too small. Use at least order +1.',...
			'Window size error','modal');return
		end
	else
		if size(X,1) < order * delay
			warndlg('Order too large for data','Order error','modal');return
		end
	end
		
	%% busy text
	cla(axDataBottom)
	text(.2,.5,'Computing permutation entropy',...
		'Fontweight','bold',...
		'Fontsize',14);
	drawnow;

	% compute permutation entropy
	try 
		if flagNormalise
			permEnt = pent(X,order,delay,ws,ss);
		else
			[dummy permEnt] = pent(X,order,delay,ws,ss);		
		end
	catch
		warndlg(lasterr,'Compute Error','modal');
		return;
	end

	%% plot H(n)
	if length(permEnt) == 1
		axes(axDataBottom);
		cla(axDataBottom);
		text(.45,.45,num2str(permEnt),...
			'Fontweight','bold',...
			'Fontsize',14);
		drawnow;
	else		
		cla(axDataBottom);
		plotLine = line(1:ws:length(permEnt),permEnt(1:ws:end),'LineWidth',1,...
		'Color','black','Parent',axDataBottom); 
	end

	title(axDataBottom,sprintf('Permutation Entropy of order %d',order));
	ylabel(axDataBottom,sprintf('H(%d)',order));
	set(get(source,'Parent'),'Userdata',permEnt);

end % buttonComputeCallback
