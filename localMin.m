function index = localMin(x)

%localMin Find local minima and return indices.
%

% $Log$

index = find( diff( sign( diff([0; x(:); 0]) ) ) > 0 );
