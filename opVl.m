function [varargout] = opVl(varargin)

%opVl Quantify diagonal structures in an RP.
%
% function [LAM TT Vmax] = opVl(RP,minLen)
%
% Input:
% 	X = recurrence plot
% 	minLen = minimal length for verticals
%
% Output:
% 	LAM = laminarity
% 	TT = trapping time
% 	Vmax = length of longest vertical line
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


% $Log: opVl.m,v $
% Revision 1.7  2008/01/23 09:39:06  schinkel
% Now returns distribution of lines as well
%
% Revision 1.6  2007/08/10 09:35:06  schinkel
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
%
% Revision 1.1  2007/07/20 09:02:24  schinkel
% Initial Import
%

%% debug settings
debug = 1;
if debug;warning('on','all');else warning('off','all');end

%% check input

if nargin>2 
	error('Usage:[] = opVl(X,[minLen])');
end

X = varargin{1};

if nargin == 2;
	minLen = varargin{2};
else
	minLen = 2;
end
	%% compute

%% pad the RP with zeros & convert to double
vertLines = double([zeros(1,length(X)) ; X ; zeros(1,length(X))]);

%% padding done, concat and feed to maxConsElements
index = vertLines(:);

%%% find the length of consecutive elements
tmp = diff(index);
ind1 = find(tmp == 1);
ind2 = find(tmp == -1);

%%% store length of lines
kramor = ind2-ind1;

% return ALL vertical lines, if requested
if nargout == 4;
	varargout{4} = kramor;
end
	

%% exclude vertical which are too short
kramor(kramor < minLen) = [];

if any(kramor(:)),
	%% compute LAM,TT,Vmax
	varargout{1} = sum(kramor)/sum(sum(X));
	varargout{2} = mean(kramor);
	varargout{3} = max(kramor);

else
	varargout{1} = NaN;
	varargout{2} = NaN;
	varargout{3} = NaN;
	if nargout == 4;
		varargout{4} = NaN;
	end
end
