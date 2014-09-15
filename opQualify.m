function [out] = opQualify(X,theiler,minL,minV)

%opQualify Compute measures of complexity from an RP.
%
% function rqa = opQualify(X,theiler,minL,minV)
%
% Input:
% 	RP = Recurrence Plot
% 	theiler = size of theiler window
% 	minL = minimal length of diagonal line
% 	minV = minimal length of vertical line
%
% Output:
% 	rqa(1) = RR	(recurrence rate)
% 	rqa(2) = DET	(determinism)
% 	rqa(3) = L	(mean diagonal line length)
% 	rqa(4) = Lmax	(longest diagonal line)
% 	rqa(5) = ENT	(entropy of the diagonal line lengths)
% 	rqa(6) = LAM	(laminarity)
% 	rqa(7) = TT	(trapping time)
% 	rqa(8) = Vmax	(longest vertical line)
%
% requires: opDl.m opVl.m
%
% see also: opcrqa opcrp.m
%

% $Log: opQualify.m,v $
% Revision 1.3  2007/07/31 12:11:24  schinkel
% Properly adjusted for Doc for m2html
%
% Revision 1.2  2007/07/31 12:01:59  schinkel
% Adjusted for Doc for m2html
%
% Revision 1.1  2007/07/24 14:39:34  schinkel
% Initial import
%

%% debug settings
debug = 0;
if debug;warning('on','all');else warning('off','all');end


%% theiler window exclusion 
if theiler == 0
	RP = double(X);
else
	RP = double(triu(X,theiler))+double(tril(X,-theiler));
end

%% recurrence rate
RR = sum(sum(RP)) / numel(X);

	
[DET L Lmax ENT] = opDl(RP,minL);
[LAM TT Vmax] = opVl(RP,minV);

out(1,1) = RR;
out(1,2) = DET;
out(1,3) = L;
out(1,4) = Lmax;
out(1,5) = ENT;
out(1,6) = LAM;
out(1,7) = TT;
out(1,8) = Vmax;

