function [varargout]= pent(varargin)

%PENT  compute permutation entrop 
%
% function [pEnt pEntNorm] = pent(X,order[,lag, ws,ss])
%
% Compute the windowed permutation entropy of a
% time series or the spatial permutation entropy 
% of an ensemble.
% 
%For timeseries windowing is supported.
%
% For an MxN ensemble with M should correspond to 
% the realisations and N to time timeline of a 
% process. The entropy is computed for every time
% point and along the spatial extent of the data.
%
% pop_pent provides a GUI for the function.
%
% Input: 
%	X = vector or MxN matrix
%	order = order of entropy
% 	lag = time delay (def: 1)
%	ws = window size (def: length(X))
%	ss = step size (def: 1);
%
% Output:
%	pEnt = permutation entropy
%	pEntNorm = normalized permutation entropy
%
% requires: opTool
%
% see also: pop_pent.m pentimage.m opTool
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


% $Log: pent.m,v $
% Revision 1.5  2007/08/10 14:24:11  schinkel
% Faster algorithm.
%
% Revision 1.4  2007/08/10 10:15:04  schinkel
% Fixed bug in window mode
%
% Revision 1.3  2007/08/10 09:35:06  schinkel
% Added GPL note
%
% Revision 1.2  2007/08/10 09:20:19  schinkel
% Added windowing support. Updated Doc.
%
% Revision 1.1  2007/08/08 13:56:10  schinkel
% Initial Import
%

debug=true;
if debug;warning('on','all');else warning('off','all');end

% I/O check
if (nargchk(2,5,nargin)), help(mfilename),error(nargchk(2,4,nargin)); end
if (nargchk(0,2,nargout)), help(mfilename),error(nargchk(0,2,nargout)); end

%% assing stuff
varargin{6} = [];

X = varargin{1};
order = varargin{2};
if ~isempty(varargin{3});delay = varargin{3};else delay = 1;end
% adjust window size to size of pattern sequence, if none given
if ~isempty(varargin{4});ws = varargin{4};else ws = numel(X) - (order-1) *delay;end
if ~isempty(varargin{5});ss = varargin{5};else ss = 1;end

%switch temporal/spatiotemporal
% regular vector routine
if  xor(size(X,1) > 1,size(X,2) > 1)

	%ensure row vector 
	X = X(:);

	ops = opCalc(X,order,delay);
	
	% loop through data
	for i = 1:ss:size(ops,1) - (ws-1)

		%slice out patters
		pies = ops(i:i+ws-1);
		
		% all patterns in there
		uniquePies = unique(pies);

		% relative frequencies of occuring pies
		for j = 1:length(uniquePies);
			pieFreq(j) = sum(pies == uniquePies(j))  / length(pies);
		end

		pEnt(i)  = -sum(pieFreq .* log(pieFreq));
		pEntNorm(i) = pEnt(i) / (order - 1);
	end
else
	% symbolic encoding
	opgramX = opgram(X,order,delay);
	[rows cols] = size(opgramX);
	
	% allocate memory
	pEnt = zeros(1,cols);
	pEntNorm = zeros(1,cols);
	
	% calculate
	for i = 1:cols
		uniquePies = unique(opgramX(:,i));
		for j = 1:length(uniquePies);
			pieFreq(j) = sum(opgramX(:,i) == uniquePies(j))  / rows;
		end
		pEnt(i)  = -sum(pieFreq .* log(pieFreq));
		pEntNorm(i) = pEnt(i) / (order-1);
	end
end

varargout{1} = pEnt;
varargout{2} = pEntNorm;

