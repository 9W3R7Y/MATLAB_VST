function [Y,Z,i] = allpass(~, X, Z, i, m, g)

    % 変数の初期化
    [nsample,~] = size(X); % サンプル数
    Y = zeros(size(X));  % 出力用の行列
    N = length(Z); % バッファの大きさ

    % インデックスの変換
    ringInd = @(i) mod(i-1+N,N)+1;

    % サンプル毎の処理
    for j = 1:nsample

        % 入力
        x = X(j);

        % mサンプル前の値を取得
        z  = Z(ringInd(i-m),:);

        % 出力
        y = (1-g^2)*z - g*x;
        Y(j,:) = y; 

        % 入力のバッファへの格納とフィードバック
        Z(ringInd(i),:) = x + g*z;

        % バッファのインデックスを進める
        i = ringInd(i+1);
    end
end