function [Y,z] = FOIIR(~, X, z, g1, g2)
    % 変数の初期化
    nsample = length(X); % サンプル数
    Y = zeros(size(X));  % 出力用の行列

    % サンプル毎の処理
    for j = 1:nsample
        % 入力
        x = X(j,:);
       
        % 出力
        y = g2*(x + g1*z);
        Y(j,:) = y; 

        % フィードバック
        z = (x + g1*z);
    end
end