function combos = possibleCombos(dim)

%possibleCombos = possible relevent patterns for opsra
%
% function combos = possCombos(dim)
%
% Computes all possible combinations of relevant patterns
% available in dimension dim
%
% Input:
% 	dim = dimension (number of points)
%
% Output:
% 	combos = possible combinations of relevant patterns
%
% requires: 
%
% see also: opsra.m

% Copyright (C) 2008 Stefan Schinkel, University of Potsdam
% http://www.agnld.uni-potsdam.de/~schinkel/ 

a = (1:factorial(dim))';
combos ={};

%%% apparently all elements can form a rel. class by themselves
allCombos = possiblePatterns(dim);
%
for i=1:factorial(dim);
	combos{end+1} = allCombos(i);
end

%% now loop through combnk
%% gives any possible combination
for i=2:factorial(dim)/2-1
	tmp = nchoosek(a,i);
	for j=1:size(tmp,1)
		combos{end+1} = [allCombos(tmp(j,:))'];
	end
end


%% clear mirrored patterns
tmp = [];rej=[];
for i=factorial(dim)+1:numel(combos);
	
	%% cell2arr as logical cmp. not working otherwise
	tmp = combos{i};
	
	for j = 1:numel(tmp)/2
		if sum(tmp(j) == invertPatterns(tmp));rej(end+1) = i;end
	end
end

combos(rej) = [];

