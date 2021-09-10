function test_reverb(p, X, Fs)
    Impulse = zeros(size(X));
    Impulse(1,:) = [1 1];
    
    [X, Y] = test_plugin(p,X,Fs);
    T = ((1:length(X))-1)/Fs;figure;t = tiledlayout(4,2,"TileSpacing","tight");
    
    p.resetBuffers();
    p.wetmix = 1;
    [~, Resp] = test_plugin(p,Impulse,Fs);
    
    
    nexttile;plot(T,X(:,1));
    subtitle("Input (Left)");xlim([-inf,inf]);ylim([-2,2]);
    
    nexttile;plot(T,X(:,2));
    subtitle("Input (Right)");xlim([-inf,inf]);ylim([-2,2]);
    
    nexttile;plot(T,Y(:,1));
    subtitle("Output (Left)");xlim([-inf,inf]);ylim([-2,2]);
    
    nexttile;plot(T,Y(:,2));
    subtitle("Output (Right)");xlim([-inf,inf]);ylim([-2,2]);
    
    nexttile;plot(T,Resp(:,1));
    subtitle("Inpulse Response (Left)");xlim([0,inf]);ylim([-1,1]);
    
    nexttile;plot(T,Resp(:,2));
    subtitle("Inpulse Response (Right)");xlim([0,inf]);ylim([-1,1]);
    
    nexttile;    
    [S,F,T] = stft(Resp(:,1),Fs,"FFTLength",256,"OverlapLength",64);
    title(t,p.name);imagesc(T,F,abs(S).^2);set(gca,'ColorScale','log');
    xlim([-inf,inf]);ylim([0,inf]);axis xy;
    subtitle("STFT of Inpulse Response (Left)");
    
    nexttile;
    [S,F,T] = stft(Resp(:,2),Fs,"FFTLength",256,"OverlapLength",64);
    title(t,p.name);imagesc(T,F,abs(S).^2);set(gca,'ColorScale','log');
    xlim([-inf,inf]);ylim([0,inf]);axis xy;
    subtitle("STFT of Inpulse Response (Right)");
    
    % sound
    % soundsc(X,Fs);
    % pause(1);
    soundsc(Y,Fs);
    % pause(2);
    % soundsc(Resp,Fs);
end
