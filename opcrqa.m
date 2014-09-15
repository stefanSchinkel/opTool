function varargout = opcrqa(varargin)

%opcrqa Compute measures of complexity from order patterns RP.
%
% function [rqa] = opcrqa(X,[Y],dim,tau[,ws,ss,theiler,minLenDiag,minLenVert,windowMode])
%
% Compute measures of complexity from order patterns
% (cross) recurrence plot . The plot is computed
% from X and X (RP) or X and Y (CRP) using embedding
% dimension dim and delay tau.
% 
% Note: Current limitation for dimension is 13.
%
% Input:
%
% X = time series (vector)
% Y = time series (vector)
% dim = dimension (number of points)
% tau = time delay (distance between points)
% ws = window size
% ss = step size
% theiler = size of theiler window (default = 1), ignored if crp
% minLenDiag = minimal length of diagonal lines (default = 2)
% minLenVert = minimal length of diagonal lines (default = 2)
% windowMode = 'small'/'full' when windowing use full or small plot 
%	a) small plot x(i:i+ws) 'small' (default)
%	b) full plot x(i:i+ws+dimension*delay) 'full'
% stretchMode = 'norm'/'squeeze'/'stretch' when ws > 1 choose if:
%	a) produce output with zeros like CRPtool ('norm') == default
%	b) sparse zeros are squeezed out ('squeeze')
%	c) intermediat zeros are set to value of preceeding window ('stretch')
%
% Output:
%
% rqa(1) = RR (recurrence rate)
% rqa(2) = DET (determinism)
% rqa(3) = L (mean diagonal line length)
% rqa(4) = Lmax (longest diagonal line)
% rqa(5) = ENT (entropy of the diagonal line lengths)
% rqa(6) = LAM (laminarity)
% rqa(7) = TT (trapping time)
% rqa(8) = Vmax (longest vertical line)
%
% requires: opcrp.m opQualify.m
%
% see also: opcrp.m 
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


% $Log: opcrqa.m,v $
% Revision 1.7  2008/03/05 09:31:48  schinkel
% Fixed bug in handling singles
%
% Revision 1.6  2007/08/17 13:40:13  schinkel
% Added parameter check
%
% Revision 1.5  2007/08/10 09:35:06  schinkel
% Added GPL note
%
% Revision 1.4  2007/07/31 12:11:24  schinkel
% Properly adjusted for Doc for m2html
%
% Revision 1.3  2007/07/25 14:07:54  schinkel
% Bug fixed in argument passing routines
%
% Revision 1.2  2007/07/25 13:50:28  schinkel
% Added windowed plot & choice for theiler/minLenDiag/minLenVert
%
% Revision 1.1  2007/07/24 09:13:04  schinkel
% Moved to opTool
%
% Revision 1.4  2007/07/20 14:01:00  schinkel
% Fixed bug in CRP routine
%
% Revision 1.3  2007/07/20 09:13:23  schinkel
% Added LAM,TT,Vmax
%
% Revision 1.2  2007/07/19 15:20:00  schinkel
% Switch to local debug mode for speed reasons
%
% Revision 1.1  2007/07/19 14:49:02  schinkel
% Initial Import
%

%% debug settings
debug = 0;
if debug;warning('on','all');else warning('off','all');end

%% prevent indexation errors
varargin{11}=[];

%% sort varargin by strings and numbers
numArgs=[];for i=1:11;if isnumeric(varargin{i});numArgs=[numArgs i];end;end
stringArgs = find(cellfun('isclass',varargin,'char'));

%% handle numArgs
X = varargin{numArgs(1)};

if length(varargin{numArgs(2)}) == 1
	Y = X;
	if isempty(varargin{numArgs(2)}),error('No dimension supplied');else dim = varargin{numArgs(2)};end
	if isempty(varargin{numArgs(3)}),error('No time delay(tau) supplied');else tau = varargin{numArgs(3)};end
	if isempty(varargin{numArgs(4)}),ws = [];else ws = varargin{numArgs(4)};end
	if isempty(varargin{numArgs(5)}),ss = [];else ss = varargin{numArgs(5)};end
	if isempty(varargin{numArgs(6)}),theiler = 1;else theiler = varargin{numArgs(6)};end
	if isempty(varargin{numArgs(7)}),minLenDiag = 2;else minLenDiag = varargin{numArgs(7)};end
	if isempty(varargin{numArgs(8)}),minLenVert = 2;else minLenVert = varargin{numArgs(8)};end
else
	Y = varargin{numArgs(2)};
	if isempty(varargin{numArgs(3)}),error('No dimension supplied');else dim = varargin{numArgs(3)};end
	if isempty(varargin{numArgs(4)}),error('No time delay(tau) supplied');else tau = varargin{numArgs(4)};end
	if isempty(varargin{numArgs(5)}),ws = [];else ws = varargin{numArgs(5)};end
	if isempty(varargin{numArgs(6)}),ss = [];else ss = varargin{numArgs(6)};end
	%if isempty(varargin{numArgs(7)}),theiler = 1;else theiler = varargin{numArgs(7)};end
	theiler = 0;
	if isempty(varargin{numArgs(8)}),minLenDiag = 2;else minLenDiag = varargin{numArgs(8)};end
	if isempty(varargin{numArgs(9)}),minLenVert = 2;else minLenVert = varargin{numArgs(9)};end
end

% set calcMode/stretchmode
calcMode = 0;	stretchMode = 0;

for i = 1:length(stringArgs),
	if strmatch('ful',varargin{stringArgs(i)}); calcMode = 1;end
end

if ss > 1
	for i = 1: length(stringArgs),
		if strmatch('squ',varargin{stringArgs(i)}); stretchMode = 1;end
		if strmatch('str',varargin{stringArgs(i)}); stretchMode = 2;end
	end
end

%% parameter check
if ( (dim-1)*tau ) > length(X);error('Bad parameters. Time series shorter than patterns');end
if ~calcMode
	if ws < (dim+1)*tau;
		error('Window size too small');
	end
end
if ws > length(X); error('Window size too large');end
if theiler > length(X)/2;error('Theiler window larger than RP');end
if calcMode,if ws+dim*tau > length(X);error('Bad parameters. Time series shorter than patterns');end,end

%% compute

if isempty(ws) || isempty(ss) ||  ws == length(X)

	RP = opcrp(X,Y,dim,tau);
	varargout{1} = opQualify(RP,theiler,minLenDiag,minLenVert);

else
	nX = numel(X);
	if calcMode == 1; %% full sized plot
		for i=1:ss:nX-ws-dim*tau;
			RP = opcrp(X(i:i+ws+dim*tau),Y(i:i+ws+dim*tau),dim,tau);

			% adjust output
			if stretchMode == 2 %stretch 
				out(i:i+ss-1,:) = repmat(opQualify(RP,theiler,minLenDiag,minLenVert),ss,1);
			else
				out(i,:) = opQualify(RP,theiler,minLenDiag,minLenVert);				
			end 

		end %for 

	else %% small plot
		for i=1:ss:nX-ws;
			RP = opcrp(X(i:i+ws-1),Y(i:i+ws-1),dim,tau);

			% adjust output
			if stretchMode == 2 %stretch 
				out(i:i+ss-1,:) = repmat(opQualify(RP,theiler,minLenDiag,minLenVert),ss,1);
			else
				out(i,:) = opQualify(RP,theiler,minLenDiag,minLenVert);				
			end 

		end %for
	
	end %calcMode
	
	if stretchMode == 1 % squeeze
		varargout{1} = out(1:ss:end,:);
	else
		varargout{1} = out;
	end

end % window if


