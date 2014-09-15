function [varargout] = opDl(varargin)

%opDl Quantify diagonal structures in an RP.
%
% function [DET L Lmax ENT] = opDl(RP,minLen)
%
% Input:
% 	X = recurrence plot
% 	minLen = minimal length for diagonals
%
% Output:
%
% 	DET = percent determinism
% 	L = mean length of diagonal lines
% 	Lmax = length of longest diagonal line
% 	ENT = Entropy of diagonal line lengths
%
% requires: 
%
% see also: opcrp.m opcrqa.m CRPtool

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


% $Log: opDl.m,v $
% Revision 1.7  2008/01/23 09:39:06  schinkel
% Now returns distribution of lines as well
%
% Revision 1.6  2007/08/10 09:35:07  schinkel
% Added GPL note
%
% Revision 1.5  2007/08/07 10:13:07  schinkel
% Fixed bug no lines longer minLen occur
%
% Revision 1.4  2007/08/07 08:58:15  schinkel
% Fixed bug when RP is empty
%
% Revision 1.3  2007/07/31 12:11:24  schinkel
% Properly adjusted for Doc for m2html
%
% Revision 1.2  2007/07/31 12:01:59  schinkel
% Adjusted for Doc for m2html
%
% Revision 1.1  2007/07/24 09:13:04  schinkel
% Moved to opTool

%% debug settings
debug = 0;
if debug;warning('on','all');else warning('off','all');end

%% check input

if nargin>2 || nargout >5
	error('Usage:[DET L Lmax ENT] = opDl(X,[minLen])');
end

X = varargin{1};

if nargin == 2;
	minLen = varargin{2};
else
	minLen = 2;
end

%% compute

%% find all non-zero diagonals
%% note: this converts from uint8 to double

%% needed for shannon to be compatible with CRPtool
N = size(X);

diagLines = spdiags(X);

%% pre-select data, given minLen is rather huge
%% for smaller values this doesn't increase speed
if minLen > 9,
	lenI = sum(diagLines) >= minLen;
	diagLines = diagLines(:,lenI);
end

%% pad diagonal lines with zeros to not alter result

diagLines = [zeros(1,size(diagLines,2)) ; diagLines ; zeros(1,size(diagLines,2))];

%% padding done, concat and feed to maxConsElements
index = diagLines(:);

%% find the length of consecutive elements
tmp = diff(index);
ind1 = find(tmp == 1);
ind2 = find(tmp == -1);

%% store length of lines
kramor = ind2-ind1;

% return line distribution 
% of all lines
if nargout == 5;
	varargout{5} = kramor;
end

%% exclude diagonal which are too short
kramor(kramor < minLen) = [];

if any(kramor(:)),

	%% compute DET,<L>,Lmax, ENT
	varargout{1} = sum(kramor)/sum(sum(X));
	varargout{2} = mean(kramor);
	varargout{3} = max(kramor);
	
	%% needed for compatibility with CRPtool - if not wished use 
	% varargout{4} = shannon(kramor)
	varargout{4} = shannon(kramor,min(N));

	
else
	varargout{1} = NaN;
	varargout{2} = NaN;
	varargout{3} = NaN;
	varargout{4} = NaN;
	if nargout == 5;
		varargout{5} = NaN;
	end
end
