function rp = opcrp(varargin)

%opcrp Compute (Cross) recurrence plot based on order patterns
%
% function [rp] = opcrp(X,[Y],dim,tau)
%
% Input:
%	X = time series (vector)
%	Y = time series (vector)
%	dim = dimension (number of points)
%	tau = time delay (distance between points)
%
% Output:
%	rp = (cross) recurrence plot based on orderpatterns
%
% requires: opCalc.m
%
% see also: pop_crp.m opcrqa.m 
%
% Note: The maximal supported dimension is 13.
%
% Due to memory limitiations the size of X/Y is limited.
% opcrp usually faster than the CRPtoolbox plugin when
% length(X) <= 5000
%
% Speed Comparison :
%
% >> a = randn(1,5000)
% >> tic,opcrp(a,3,3);toc  
% Elapsed time is 1.975831 seconds.
% >> tic,crp(a,3,3,'opattern','non','sil');toc %% using plugin
% Elapsed time is 4.281478 seconds.

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


% $Log: opcrp.m,v $
% Revision 1.3  2007/08/10 09:35:06  schinkel
% Added GPL note
%
% Revision 1.2  2007/07/31 12:11:24  schinkel
% Properly adjusted for Doc for m2html
%
% Revision 1.1  2007/07/24 09:13:05  schinkel
% Moved to opTool
%
% Revision 1.5  2007/07/20 14:01:00  schinkel
% Fixed bug in CRP routine
%
% Revision 1.4  2007/07/19 15:20:00  schinkel
% Switch to local debug mode for speed reasons
%
% Revision 1.3  2007/07/19 08:51:57  schinkel
% Updated Doc. Changed output routine
%
% Revision 1.2  2007/07/17 10:04:04  schinkel
% Added Doc
%
% Revision 1.1  2007/07/17 08:55:30  schinkel
% Initial Import
%

%% debug settings
debug = 0;
if debug;warning('on','all');else warning('off','all');end

%% check number of input arguments
error(nargchk(1,4,nargin))

%% check number of out arguments
error(nargoutchk(0,1,nargout))

%% check && assign input

%% prevent indexation errors
varargin{5}=[];	

%% for sure
X = varargin{1};

if length(varargin{2}) == 1  % RP
	calcMode = 1;	
	dim = varargin{2};
	tau = varargin{3};
else % CRP
	calcMode = 2; 
	Y = varargin{2};
	dim = varargin{3};
	if isempty(varargin{4}),
		error('No time delay(tau) supplied');
	else	
		tau = varargin{4};
	end
end

%% all set, let's get cracking

%% RP routine
if calcMode == 1 

	if debug, disp('Computing Recurrence Plot');end

	symX = opCalc(X,dim,tau);
	%% reshape Y for matching procedure
	symY = symX';
	
	
%% CRP routine
elseif calcMode == 2 

	if debug, disp('Computing Cross Recurrence Plot');end

	lenX = length(X);
	lenY = length(Y);
	if lenX ~= lenY, error('X and Y must have the same length');end
	
	symX = opCalc(X,dim,tau);
	symY = opCalc(Y,dim,tau);
	%% reshape Y for matching procedure
	symY = symY';
end


%% match pattern and build (C)RP 
if debug,	size(symX),size(symY),length(symX),length(symY),end

rp =  uint8(symX(:,ones(1,length(symX)),:) == symY(ones(1,length(symY)),:,:))';	

%% plot rp in no output wanted
if nargout < 1;
	imagesc(rp);
	set(gca,'YDir','normal');
	c = colormap('gray');
	colormap(flipud(c));
end
