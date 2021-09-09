function [Y] = applyMixMat(~,X)
    [N,L] = size(X);
    Y = zeros(L,2);
    
    for i = 1:N
        Y = Y + [X(i,:); X(i,:)*(2*rem(i,2)-1)].';
    end
end