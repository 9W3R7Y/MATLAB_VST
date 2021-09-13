function [T, X, Y] = test_plugin(p, X, Fs, BFSIZE)
    p.Fs = Fs;
    
    nloop = floor((length(X)-1)/BFSIZE)+1;
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
    
    T = linspace(0,Fs*length(X),length(X));
end