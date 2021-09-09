function [out,ZMat,idxMat] = parallelComb(~, X, N, ZMat, idxMat, mMat, gMat)

    % 出力用変数の用意
    [L,nchannel] = size(X);
    out = zeros(N,L,nchannel);

    for i = 1:N
        % 変数の初期化
        Z   = ZMat(:,i);
        idx = idxMat(i);
        m   = mMat(i);
        g   = gMat(i);

        % Comb フィルタを適用
        [Y,ZMat(:,i),idxMat(i)] = comb(NaN,X,Z,idx,m,g);
        
        out(i,:,:) = Y;
    end

    % 音量のノーマライズ
    out = out/sqrt(N);
    
end