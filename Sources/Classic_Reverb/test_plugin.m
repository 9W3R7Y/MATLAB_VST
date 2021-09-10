function [X, Y] = test_plugin(p, X, Fs)
    p.Fs = Fs;

    BFSIZE = 1024;
    
    nloop = floor(length(X)/BFSIZE)+1;
    X((nloop)*BFSIZE,:) = [0;0];
    
    % output matrix
    Y = zeros(size(X));
    
    % main loop
    for i = 1:nloop
        % read buffer
        idxs = ((i-1)*BFSIZE+1):(i*BFSIZE);
        in = X(idxs,:);
        
        % process
        out = p.process(in);
        
        Y(idxs,:) = out;
    end
end