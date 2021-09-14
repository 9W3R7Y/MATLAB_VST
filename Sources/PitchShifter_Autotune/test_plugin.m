function [T, X, Y] = test_plugin(p, X, Fs, BFSIZE)
    p.Fs = Fs;
    
    nloop = floor((length(X)-1)/BFSIZE)+1;
    X((nloop)*BFSIZE,:) = [0;0];
    
    % output matrix
    Y = zeros(size(X));
    
    % wait bar
    wb = waitbar(0,"processing...");
    
    % main loop
    for i = 1:nloop
        % read buffer
        idxs = ((i-1)*BFSIZE+1):(i*BFSIZE);
        in = X(idxs,:);
        
        % process
        out = p.process(in);
        
        % wait bar
        waitbar(i/nloop,wb,"processing");
        
        Y(idxs,:) = out;
    end
    
    close(wb);
    
    T = linspace(0,Fs*length(X),length(X));
    
    % Plot 
    %{
    figure();clf;
    tiledlayout("flow");
    nexttile;plot(T,X);title("Iput");
    nexttile;plot(T,Y);title("Output");
    xlim([-inf inf]);linkaxes;    
    %}
end