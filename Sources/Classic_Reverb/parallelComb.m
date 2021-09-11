function [out,ZMat,idxMat, varargout] = parallel(~, X, N, ZMat, idxMat, mMat, gMat, varargin)

    % 出力用変数の用意
    [L,nchannel] = size(X);
    out = zeros(N,L,nchannel);
    
    % フィードバックの一次フィルタの有無
    if isempty(varargin)
        FeedbackFilt = false;
        filtZMat = NaN;
    else
        FeedbackFilt = true;
        g1Mat = gMat;
        g2Mat = varargin{1};
        filtZMat = varargin{2};
    end

    for i = 1:N
        % 変数の初期化
        Z   = ZMat(:,i);
        idx = idxMat(i);
        m   = mMat(i);
        
        if ~FeedbackFilt
            g   = gMat(i);
            [Y,ZMat(:,i),idxMat(i)] = comb(NaN,X,Z,idx,m,g);
            
        else
            g1  = g1Mat(i);
            g2  = g2Mat(i);
            filtZ  = filtZMat(:,i);
            
            [Y,ZMat(:,i),idxMat(i),filtZMat(:,i)] = comb(NaN,X,Z,idx,m,g1,g2,filtZ);
        end
        
        out(i,:,:) = Y;
    end

    varargout = {filtZMat};
    
    % 音量のノーマライズ
    out = out/sqrt(N);
    
end