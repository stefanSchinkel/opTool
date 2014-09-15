function pop_opcrqa(varargin)

%pop_opcrqa GUI for plots of windowed oprqa measure 
%
% function pop_opcrqa (EEG,dim,tau [,ws,ss,theiler,minDiag,minVert,calcMode])
%
% GUI to opcrqa - for better visualisation the output is computed in 
% strechMode = 'stretch'. See help opcrqa for details. 
%
% Parameter:
%	dimension = dimension/order of orderpattern
%	delay = time delay
%	ws = window size
%	ss = step size (default: 1)
%	minDiag = mininmal length of diagonal lines
%	minVert = mininmal length of vertical lines
%	theiler = size of theiler window
%	calcMode = ('full'/'small') compute measures from small or large plot 
%		small plot = x(i):x(i+ws) 
%		full plot = x(i) : x(i+ws+dimension*delay)
%
%
% Parameters can be changed/provided interactively 
% using the GUI.
%
% requires: opcrqa.m opCalc.m
%
% see also: pop_rqaimage.m pop_opcrp.m pop_opgram.m pop_pentimage.m 
%
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

% $Log: pop_opcrqa.m,v $
% Revision 1.3  2008/03/05 10:49:20  schinkel
% Improved plotting routines
%
% Revision 1.2  2007/11/20 11:38:00  schinkel
% Added automatic tau estimation. Improved error handling
%
% Revision 1.1  2007/10/25 13:30:25  schinkel
% Initial Import
%


%% debug settings
debug = 1;
if debug;warning('on','all');else warning('off','all');end

%% check input
varargin{11} = [];
if sum(size(varargin{1})) == 2; help(mfilename);error('Bad input format');else X = varargin{1};end
if isempty(varargin{2}),dim = 2;else dim = varargin{2};end
if isempty(varargin{3}),tau = 1;else tau = varargin{3};end
if isempty(varargin{4}),ws = size(X,2);else ws = varargin{4};end
if isempty(varargin{5}),ss = 1;else ss = varargin{5};end
if isempty(varargin{6}),minDiag = 2;else minDiag = varargin{6};end
if isempty(varargin{7}),minVert = 2;else minVert = varargin{7};end
if isempty(varargin{8}),theiler = 1;else theiler = varargin{8};end
if isempty(varargin{9}),rpMode = 'small';else rpMode = varargin{9};end

%% check some params
if strcmp('full',rpMode),valPlotSizeValue = 2; else valPlotSizeValue = 1;end

screenSize = get(0,'Screensize');

%%%%%%%%%%%%%%%%%%%%%
%	Define GUI		%
%%%%%%%%%%%%%%%%%%%%%
fHandle = figure('Name','OPCRQA GUI',... 
'Position',[50,screenSize(4)-650,800,600],... % top left corner 
'Color',[.801 .75 .688], ... 
'Menubar','none');% choose 'Menubar','figure' to run into trouble


%%%%%%%%%%%%%%%%%%%%%
%	Layout GUI		%
%%%%%%%%%%%%%%%%%%%%%

set(fHandle,'visible','off')

	opcrqaLayout;

	set(axData,'XTick',[]);
	set(axOP,'XTick',[],'YTick',[]);
	set(axRR,'XTick',[]);
	set(axDET,'XTick',[],'YAxisLocation','right');
	set(axL,'XTick',[]);
	set(axLmax,'XTick',[],'YAxisLocation','right');
	set(axENT,'XTick',[]);
	set(axLAM,'XTick',[],'YAxisLocation','right');
	set(axVmax,'YAxisLocation','right');

% adjust plot
	set(axData,'Xlim',[1 length(X)],'Ylim',[min(X) max(X)]);

%plot the data
	plot(axData,X);
	set(axData,'Tag','axData');
	set(axData,'Xlim',[1 length(X)])

%show figure
	set(fHandle,'visible','on')

%hide
	set(0,'showhidden','off')
	set(fHandle,'HandleVisibility','Callback');
end %main()



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%	associate callbacks		%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function buttonStoreCallback(source,eventdata) 

	%% get opgram
	rqa = get(get(source,'Parent'),'Userdata');

	if isempty(rqa);warndlg('No data found. Compute first.','No Data','modal');return;end

	%convert to char, inputdlg returns cellarray
	varname = cell2mat(inputdlg('Enter variable name','Store H(n)',1,{'rqa'}));

	if isempty(varname);return;end	
	if ~isvarname(varname);
		warndlg('Not a valid variable name','Variable name error','modal');return;
	end
	try
		assignin('base',varname, rqa);
		msgbox(sprintf('RQA data stored as %s in your workspace.',varname),'Data stored');
	catch 
		warndlg('Could not store data!','Data storage	error');
	end

end % buttonCloseCallback	

function buttonCloseCallback(source,eventdata) 
	close( get(source,'Parent') )
end % buttonCloseCallback	

function buttonComputeCallback(source,eventdata,X) 
	
	set(0,'ShowHidden','on')
	%% get parent
	figHandle = get(source,'Parent');

	%% busy text
	set(findobj(figHandle,'Tag','buttonCompute'),'String','Busy ...');
	set(findobj(figHandle,'Tag','buttonCompute'),'Enable','off');
	drawnow;

	%% get params 

	dim = str2num( get( findobj(figHandle,'Tag','valDim'),'String') );
	tau = str2num( get( findobj(figHandle,'Tag','valTau'),'String') );
	ws = str2num( get( findobj(figHandle,'Tag','valWindowSize'),'String') );
	ss = str2num( get( findobj(figHandle,'Tag','valStepSize'),'String') );
	minDiag = str2num( get( findobj(figHandle,'Tag','valMinDiag'),'String') );
	minVert = str2num( get( findobj(figHandle,'Tag','valMinVert'),'String') );
	theiler = str2num( get( findobj(figHandle,'Tag','valMinVert'),'String') );
	valPlotSize =  get( findobj(figHandle,'Tag','valPlotSize'),'Value');
		modes = {'small','full'};
		calcMode = modes{valPlotSize};

	%% get handles		
	axData = findobj(figHandle,'Tag','axData');
	axOP = findobj(figHandle,'Tag','axOP');
	axRR = findobj(figHandle,'Tag','axRR');
	axDET= findobj(figHandle,'Tag','axDET');
 	axL = findobj(figHandle,'Tag','axL');
	axLmax = findobj(figHandle,'Tag','axLmax');
	axENT = findobj(figHandle,'Tag','axENT');
	axLAM = findobj(figHandle,'Tag','axLAM');
	axTT = findobj(figHandle,'Tag','axTT');
	axVmax = findobj(figHandle,'Tag','axVmax');
	
	%% estimat tau in none is given
	if tau == 0,
		tau = estDelay(X);
	end
	
	%% compute and  plot the opgramm
	opgram = opCalc(X,dim,tau);
	opgram = [opgram opgram];
	hSurf = surface(zeros(size(opgram')),opgram','parent',axOP);
	shading(axOP,'flat')
	axis(axOP,[1 length(opgram) 1 2]);
	set(axOP,'Ytick',[1:.5:2],'Ytickl',{});
	set(axOP,'Xlim',[1 length(opgram)])
	set(axOP,'XTick',get(axData,'XTick'));
	set(axOP,'XTickl',get(axData,'XTickl'));

	% compute rqa measures 
	try
		rqa = opcrqa(X,dim,tau,ws,ss,minDiag,minVert,theiler,calcMode,'stretch');
	catch
		warndlg('Error computing RQA measures','Compute Error','modal');
	end
	
	% plot
	try
		if length(rqa) == 8%% show only a number if no ts available
			cla(axRR,'reset');set(axRR,'Tag','axRR');set(axRR,'XTick',[],'Ytick',[]);
			text(.45, .45,num2str(rqa(:,1)),'Fontweight','bold','Fontsize',10,'Parent',axRR);;

			cla(axDET,'reset');set(axDET,'Tag','axDET');set(axDET,'XTick',[],'Ytick',[]);
			text(.45, .45,num2str(rqa(:,2)),'Fontweight','bold','Fontsize',10,'Parent',axDET);

			cla(axL,'reset');set(axL,'Tag','axL');set(axL,'XTick',[],'Ytick',[]);
			text(.45, .45,num2str(rqa(:,3)),'Fontweight','bold','Fontsize',10,'Parent',axL);

			cla(axLmax,'reset');set(axLmax,'Tag','axLmax');set(axLmax,'XTick',[],'Ytick',[]);
			text(.45, .45,num2str(rqa(:,4)),'Fontweight','bold','Fontsize',10,'Parent',axLmax);

			cla(axENT,'reset');set(axENT,'Tag','axENT');set(axENT,'XTick',[],'Ytick',[]);
			text(.45, .45,num2str(rqa(:,5)),'Fontweight','bold','Fontsize',10,'Parent',axENT);

			cla(axLAM,'reset');set(axLAM,'Tag','axLAM');set(axLAM,'XTick',[],'Ytick',[]);
			text(.45, .45,num2str(rqa(:,6)),'Fontweight','bold','Fontsize',10,'Parent',axLAM);

			cla(axTT,'reset');set(axTT,'Tag','axTT');set(axTT,'XTick',[],'Ytick',[]);
			text(.45, .45,num2str(rqa(:,7)),'Fontweight','bold','Fontsize',10,'Parent',axTT);

			cla(axVmax,'reset');set(axVmax,'Tag','axVmax');set(axVmax,'XTick',[],'Ytick',[]);
			text(.45, .45,num2str(rqa(:,8)),'Fontweight','bold','Fontsize',10,'Parent',axVmax);
			drawnow;												

		% plot, reset Tag & adjust scale
		else 
			plot(axRR,rqa(:,1));
	 		set(axRR,'Xlim',[1 length(X)]);
	 		set(axRR,'XTick',[]);
	 		set(get(axRR,'YLabel'),'String','RR');
	 		set(axRR,'Tag','axRR');

	 		plot(axDET,rqa(:,2));	
	 		set(axDET,'Xlim',[1 length(X)]);
	 		set(axDET,'XTick',[],'YAxisLocation','right');
	 		set(get(axDET,'YLabel'),'String','DET');
	 		set(axDET,'Tag','axDET');

	 		plot(axL,rqa(:,3));
	 		set(axL,'Xlim',[1 length(X)]);
	 		set(axL,'XTick',[]);
	 		set(get(axL,'YLabel'),'String','L');
	 		set(axL,'Tag','axL');		

	 		plot(axLmax,rqa(:,4));
	 		set(axLmax,'Xlim',[1 length(X)]);
	 		set(axLmax,'XTick',[],'YAxisLocation','right');
	 		set(get(axLmax,'YLabel'),'String','Lmax');
			set(axLmax,'Tag','axLmax');

	 		plot(axENT,rqa(:,5));
	 		set(axENT,'Xlim',[1 length(X)]);
	 		set(axENT,'XTick',[]);
	 		set(get(axENT,'YLabel'),'String','ENT');
	 		set(axENT,'Tag','axENT');				

	 		plot(axLAM,rqa(:,6));
	 		set(axLAM,'Xlim',[1 length(X)]);
	 		set(axLAM,'XTick',[],'YAxisLocation','right');
	 		set(get(axLAM,'YLabel'),'String','LAM');
	 		set(axLAM,'Tag','axLAM');				

	 		plot(axTT,rqa(:,7));
	 		set(axTT,'Xlim',[1 length(X)]);
	 		set(get(axTT,'YLabel'),'String','TT');
	 		set(axTT,'Tag','axTT');

	 		plot(axVmax,rqa(:,8));
	 		set(axVmax,'Xlim',[1 length(X)])
	 		set(axVmax,'YAxisLocation','right');
	 		set(get(axVmax,'YLabel'),'String','Vmax');
	 		set(axVmax,'Tag','axVmax');
		end
	catch

		set(get(source,'Parent'),'Userdata',rqa);
		set(findobj(figHandle,'Tag','buttonCompute'),'String','Compute');
		set(findobj(figHandle,'Tag','buttonCompute'),'Enable','on');
		warndlg('Error plotting RQA measures','Compute Error','modal');
	end

	set(findobj(figHandle,'Tag','buttonCompute'),'String','Compute');
	set(findobj(figHandle,'Tag','buttonCompute'),'Enable','on');
	
	%hide figure
	set(0,'showhidden','off')
	set(figHandle,'HandleVisibility','Callback');

end % buttonComputeCallback	
