function index = localMax(x)

%localMax find local maxima and return indices.
% 

% $Log$

index = find( diff( sign( diff([0; x(:); 0]) ) ) < 0 );
