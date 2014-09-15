function rp = opcrp2(varargin)

%opcrp2 Compute spatiotemporal (Cross) recurrence plot based symbols
%
% function [rp] = opcrp(X,[Y],dim,tau)
%
% opcrp2 computes a (cross) recurrence plot from a set of 
% column vectors given in  X and Y by first symbolising the
% data in terms of order patterns and then matching for 
% co-occurence of patterns. 
%
% Input:
%	X = time series (vector)
%	Y = time series (vector)
%	dim = dimension (3 or 4)
%	tau = time delay (distance between points)
%
% Output:
%	rp = (cross) recurrence plot 
%
% requires: opTool
%
% see also: opcrp.m opcrqa.m 
%

% Copyright (C) 2008 Stefan Schinkel, University of Potsdam
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


% $Log$

%% debug settings
debug = 0;
if debug;warning('on','all');else warning('off','all');end

%% check input/output args
error(nargchk(1,4,nargin))
%error(nargoutchk(0,1,nargout))

%% assign input
varargin{5}=[];	

X = varargin{1};

if length(varargin{2}) == 1  % RP
	calcMode = 1;
	Y = X;
	dim = varargin{2};
	tau = varargin{3};
else % CRP
	calcMode = 2;
	Y = varargin{2};
	dim = varargin{3};
	if isempty(varargin{4}),error('No time delay(tau) supplied');else tau = varargin{4};end
end

%brute force size matching

if size(X,1) < size(X,2),
	disp('Illogical data format. Reshaping');
	X = X';
	Y = Y';
end

% some params
dataLength = size(X,1);
opLength = dataLength - (dim-1)*tau;
nColumns = size(X,2);

if calcMode == 1;
	%symbolise columns individually
	for i=1:nColumns
		opsX(:,i) = opCalc(X(:,i),dim,tau);
	end
	opsY = opsX;
else
	for i=1:nColumns
		opsX(:,i) = opCalc(X(:,i),dim,tau);
		opsY(:,i) = opCalc(Y(:,i),dim,tau);
	end
end



% match patterns for (C)RP in for loop
% a vectorised routine is below, disencouraged
for i=1:opLength
	for j=1:opLength
		%all comparisons must match, i.e sum == nColumns
		rp(i,j) = uint8(sum(opsX(i,:) == opsY(j,:))	== nColumns);
	end
end


% plot rp in no output wanted
if nargout < 1;
	figure;
	imagesc(rp);
	set(gca,'YDir','normal');
	c = colormap('gray');
	colormap(flipud(c));
end


%
% a vectorised way to construct the (C)RP
% for some reason it is way slower than looping
% over i and j. Takes about 2-3 times longer
%
%for i=1:opLength
%		rp1(i,:) = sum( (repmat(opsX(i,:),opLength,1) == opsY)' ) == nColumns ;
%end
