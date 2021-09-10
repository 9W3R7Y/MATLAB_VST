function [Y,Z,i,varargout] = FBC(~, X, Z, i, m, fy, fz, varargin)

    % 変数の初期化
    [nsample,~] = size(X); % サンプル数
    Y = zeros(size(X));  % 出力用の行列
    N = length(Z); % バッファの大きさ

    % フィードバックの一次フィルタの有無
    if isempty(varargin)
        feedbackFilt = false;
        filtZ = NaN;
    else
        feedbackFilt = true;
        g1 = varargin{1};
        g2 = varargin{2};
        filtZ = varargin{3};
    end
    
    % インデックスの変換
    ringInd = @(i) mod(i-1+N,N)+1;

    % サンプル毎の処理
    for j = 1:nsample

        % 入力
        x = X(j);

        % mサンプル前の値を取得
        z  = Z(ringInd(i-m),:);

        % 出力
        y = fy(x,z);
        Y(j,:) = y; 

        % 入力のバッファへの格納とフィードバック
        if ~feedbackFilt
            Z(ringInd(i),:) = fz(x,z);
        else
            [z,filtZ] = FOIIR([], z, filtZ, g1, g2);
            Z(ringInd(i),:) = fz(x,z);
        end

        % バッファのインデックスを進める
        i = ringInd(i+1);
    end
    
    varargout = {filtZ};
    
end