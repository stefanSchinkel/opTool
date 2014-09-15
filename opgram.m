function varargout = opgram(varargin)

%opgram visualise order patterns
%
% function opgram(X,dim,[tau,timescale])
%
% Surface plot of the order patterns 
% derived from data in X using the given
% embedding dimension and time delay.
% If no time delay is provided, the delay
% is estimated for each trial individually. 
%
% If the delay is estimated, the resulting symbol
% series may be of different lentgh
%
% Input:
%	X = matrix (trials,time)
%	dim = embedding dimension / order 
%	tau = time delay (default =0)
%
% requires: opCalc.m
%
% see also: opTool
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

% $Log: opgram.m,v $
% Revision 1.3  2007/10/25 13:53:31  schinkel
% Added output
%
% Revision 1.2  2007/08/23 12:30:44  schinkel
% Fixed surface plot problem
%
% Revision 1.1  2007/08/20 10:53:27  schinkel
% Initial Import
%

%% debug settings
debug = 0;
if debug;warning('on','all');else warning('off','all');end

% check number of input arguments
error(nargchk(2,3,nargin))

% check number of out arguments
error(nargoutchk(0,1,nargout))

%% check input
varargin{4} = [];

if ~isempty(varargin{1});X = varargin{1};else error('No data supplied!');end
if ~isempty(varargin{2});dim = varargin{2}; else error('No dimension/order supplied!'); end
if ~isempty(varargin{3});tau = varargin{3}; else tau = 0;end

trials = size(X,1);
time = size(X,2);


%% check if input makes sense (general)
if ndims(X) > 2; error('Sorry n-dimensional input not yet supported');end
if ~(2< dim < 13); error('Dimension/order must be between 2 & 13');end
if dim + ((tau-1)*dim) > time;error('Time series to short for given parameters');end


%% find time delay & compute patterns 
if tau == 0;
	for i = 1:trials
		tau(i) = estDelay(X(i,:));
	end

	%% allocate opgram for max length
	opgram = zeros(trials,time-dim);
	
	for i = 1:trials
		OP = opCalc(X(i,:),dim,tau(i));
		opgram(i,1:length(OP)) = OP(1:length(OP));
	end
			
else

	%% allocate opgram for max length
	opgram = zeros(trials,time-(dim-1)*tau);

	for i = 1:trials
		opgram(i,:) = opCalc(X(i,:),dim,tau);
	end

end	

%% plot opgram, or return to caller
if nargout
	varargout{1} = opgram;
	return
else 
	%% layout figure
	figHandle = figure;
	set(figHandle,'Visible','off')

	axSurf = axes('Position',[.05 .2 .9 .75],...
		'Parent',figHandle,...
		'View',[0 90],...
		'Box','on');

 
	% fix plot for surface
	[m,n] = size(opgram);
	if m == 1; 
		opgram = [opgram;opgram];fixAxes = 1;
		size(opgram)
	else 
		opgram(m+1,:) = 0;
		fixAxes = 0;
	end
	
	%% plot
	hSurf = surface(zeros(size(opgram)),opgram,'parent',axSurf);
	shading(axSurf,'flat');
	if fixAxes,	
		axis(axSurf,[1 n 1 2]);
		set(axSurf,'Ytick',[1:.5:2],'Ytickl',{'','1',''});
	else
		axis(axSurf,[1 n 1 m+1]);
	end
	
	title(axSurf,sprintf('OPGRAM Dimension/order: %d Delay: %d',dim,tau));

	%% adjust colormap
	colormap( jet( numel(unique(opgram)) ));

	%% adjust colorbar
	colorbar('Location','South',...
		'Position',[.05 .1 .9 .025],...
		'YTick',[],...
		'YTickMode','manual',...
		'XTick',[],...
		'XTickMode','manual',...
		'Box','on');
	

	%% show plot	
	set(figHandle,'Visible','on')
end

