function [Y,Z,i,varargout] = comb(~, X, Z, i, m, g, varargin)

    % フィードバックの一次フィルタの有無
    if isempty(varargin)
        feedbackFilt = false;
        filtZ = NaN;
    else
        feedbackFilt = true;
        g1 = g;
        g2 = varargin{1};
        filtZ = varargin{2};
    end
        
    fy = @(~,z) z;
    fz = @(x,z) x + g*z;
    
    if ~feedbackFilt
        [Y,Z,i] = FBC([], X, Z, i, m, fy, fz);
    else
        [Y,Z,i,filtZ] = FBC([], X, Z, i, m, fy, fz, g1, g2, filtZ);
    end
        
    varargout = {filtZ};
    
end