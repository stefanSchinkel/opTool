function varargout = relevantPatterns(varargin)

%relevantPatterns Extract relevant patterns from opgram
%
% function [R+ R0 R-] = relevantPatterns(X,dim,m,t0,t1)
%
% The function extracts relevant patterns from a opgram.
% Relevance is definded as occurrence of the patterns 
% m-times more often than is probable if a random distribution
% of patterns is assumed i.e. p(pi) = 1/dim!.
% By default the whole time (EEG-frames) covered by the opgram 
% is considered. If given a window t0 to t1 is applied.
%
%
% Input:
% X 	= opgram (cf. opgram)
% dim	= dimension used for opgram
% m 	= probability multiplier (def: 1)
% t0	= start of window (def: 1)
% t1	= end of window (def: size(X,2))
%
% Output:
% R+	= relevant patterns in R+
% R0	= "undecided" patterns
% R-	= relevant patterns in R-
%
% requires: opTool
%
% see also: opgram.m opsra.m wordstatN.m 
%

% Copyright (C) 2008 Stefan Schinkel, University of Potsdam
% http://www.agnld.uni-potsdam.de/~schinkel/ 

% $Log:$

%% debug settings
debug = 1;

% check number of input arguments
error(nargchk(2,5,nargin))

% check number of out arguments
error(nargoutchk(0,3,nargout))

%% prevent indexation error
varargin{6} = [];

%% assign input

X = varargin{1};
dim = varargin{2};
if ~isempty(varargin{3}), m = varargin{3}; else m = 1; end
if ~isempty(varargin{4}), t0 = varargin{4}; else t0 = 1; end
if ~isempty(varargin{5}), t1 = varargin{5}; else t1 = size(X,2); end

% compute wordstat 
wStat = wordstatN(X,dim);

if debug
	figure;hold all;plot(1:size(X,2),wStat);
	plot(1:size(X,2),1/factorial(dim)*m);
	plot(t0,0:.005:.4,'--k');plot(t1,0:.005:.4,'--k');
end

% indices of relevant pattern in window
temp=[];
for i=1:factorial(dim);
	temp(i) = any(wStat(t0:t1,i) > m*(1/factorial(dim)));
end;

% extract patterns
pats = possiblePatterns(dim);
hits = pats(find(temp));

%% split patterns 

% allocate out
Rplus = [];
Rminus = [];

% search loop 
for i=1:length(hits);
	for j=1:length(hits);
		
		if ~isnan(hits(i)) & ~isnan(hits(j)),
		if hits(i) == mirrorPatterns(hits(j));
			
			Rplus(end+1) = hits(i);	
			Rminus(end+1) = hits(j); 
			
			% 'cos NaN ~= NaN
			pats(pats == hits(i)) = NaN;hits(i) = NaN;
			pats(pats == hits(j)) = NaN;hits(j) = NaN;

			break			
		end
		end
	end
end


varargout{1} = Rplus;
varargout{2} = pats(~isnan(pats));
varargout{3} = Rminus;
