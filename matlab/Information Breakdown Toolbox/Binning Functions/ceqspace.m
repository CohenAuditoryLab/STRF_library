function edges = ceqspace(X, nb, par)
% CEQSPACE Build edges for centered equi-spaced binning.

%   Copyright (C) 2009 Cesare Magri
%   Version: 1.0.1

% LICENSE
% -------
% The Information Breakdown ToolBox (ibTB) is distributed free under the
% condition that:
% 1 - it shall not be incorporated in software that is subsequently sold;
% 2 - the authorship of the software shall be acknowledged in any
%     pubblication that uses results generated by the software;
% 3 - this notice shall remain in place in each source file.

meanX = mean(X(:));

minX  = min(X(:));
maxX  = max(X(:));

if nargin==3
    if isscalar(par)
        D = par;
        
        if minX<meanX-D || maxX>meanX+D
            msg = ;
            error('ceqspace:');
        end
    else
        msg = 'Invalid parameter.';
        error('ceqspace:invalidParameter', msg);
    end
else
    D = max(meanX-minX, maxX-meanX);
end

leftEdge  = meanX - D;
rightEdge = meanX + D;

spacing = (rightEdge-leftEdge) / nb;

edges = zeros(nb+1, 1);
edges(:) = leftEdge:spacing:rightEdge;
% Stretching the last edge to accomodate maxX:
edges(nb+1) = edges(nb+1) + 1;