function varargout = pentimage(varargin)

%PENTIMAGE erpimage-like plot of windowed H(n)
%
%function pent(X,order[,delay, ws, ss])
%
% Compute and plot erpimage-like plots of 
% windowed H(n) from a given MxN ensemble X. 
% where M should correspond to the realisation
% and N to time timeline of the process.
%
%
% Input:
%	X 		= matrix (trials,time)
%	order 	= order of entropy (2-13)
% 	lag 	= time delay (def: 1)
%	ws 		= window size (def: order*delay+1
%	ss 		= step size (def: 1)
%
% Output: (supresses plotting)
%
%	pentImage 		= data of the image plot
%	pentImageNorm 	= normalised data of image
% requires: pent.m
%
% see also: pop_pentimage.m opTool
%
% Note: Limitation for order is 12
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

% $Log: pentimage.m,v $
% Revision 1.1  2007/08/20 10:53:28  schinkel
% Initial Import
%

%% debug settings
debug = 0;
if debug;warning('on','all');else warning('off','all');end


% I/O check
if (nargchk(5,5,nargin)), help(mfilename),error(nargchk(2,4,nargin)); end
if (nargchk(0,2,nargout)), help(mfilename),error(nargchk(0,2,nargout)); end


%% check input
varargin{5} = [];

if ndims(varargin{1}) > 2; 	error(help(mfilename));	else X = varargin{1}; 		end
if ~(2< varargin{2} < 13); 	error(help(mfilename));	else order = varargin{2};	end
if ~isempty(varargin{3}); 	delay = varargin{3}; 	else delay = 1;				end
if isempty(varargin{4}); 	error(help(mfilename));	else ws = varargin{4};		end
if ~isempty(varargin{5}); 	ss = varargin{5}; 		else ss = 1;				end

% allocate memory
[rows cols] = size(X);
lenOutput = size(X,2)-ws+1;
pentImage = zeros(1,lenOutput);
pentImageNorm = zeros(1,lenOutput);

for i = 1:rows;
	[pentImage(i,:) pentImageNorm(i,:) ]= pent(X(i,:),order,delay ,ws,ss);
end

if nargout
	
	varargout{1} = pentImage;
	varargout{2} = pentImageNorm;

else
%plot data
figHandle = figure;

	set(figHandle,'visible','off')
	axSurf = axes('Position',[.1 .1 .8 .8]);
	surface(pentImageNorm,'Parent',axSurf);
	shading(axSurf,'flat');
	axis(axSurf,'tight');
	xlabel(axSurf,'time');
	ylabel(axSurf,'realisations');
	title(axSurf,sprintf('H(%d) delay: %d window: %d step: %d',order,delay,ws,ss));
	colorbar('peer',axSurf);
	set(figHandle,'visible','on')
end
