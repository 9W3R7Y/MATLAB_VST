function [out,ZMat,idxMat] = seriesAllpass(~,X, N, ZMat, idxMat, mMat)

    for i = 1:N
        % 変数の初期化
        Z = ZMat(:,i);
        idx = idxMat(i);
        m   = mMat(i);
        g   = 0.7;

        % filter
        [X,ZMat(:,i),idxMat(i)] = allpass(NaN,X,Z,idx,m,g);
    end
    
    % 出力
    out = X;
end