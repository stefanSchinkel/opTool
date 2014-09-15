function [p z] = histInt(x,nBinsX)

%histInt histogram of integer-valued data
%
% function [p z] = histInt(x,nBinsX)
% 
% Wrapper function to compute probabilites and histogram
% of integer-valued data and returns them in p and z. 
% If no output is specified, the histogram is plotted. 
%
% The bin size for X is optional. If none given, 
% it defaults to max(x)-min(x)+1. 
%
%	requires: histX.m
%
%	See also: histX.m hist.m
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


% $Log: histInt.m,v $
% Revision 1.2  2007/08/10 09:35:07  schinkel
% Added GPL note
%
% Revision 1.1  2007/08/08 13:53:39  schinkel
% Initial Import
%

debug=true;
if debug;warning('on','all');else warning('off','all');end

% check number of input arguments
error(nargchk(1,2,nargin))

% check number of out arguments
error(nargoutchk(0,2,nargout))

% check additional arguments
if nargin < 2, nBinsX = max(x)-min(x)+1;end


[p z] = histX(x,nBinsX);

if nargout == 0,
	figure; bar(z); title('Histogram of integer-valued data in X');axis tight;
end
