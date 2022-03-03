[X,Fs] = audioread("loop.wav");

% reverse
X = [X;flipud(X)];

% octove up
X = resample(X,1,4);

L = length(X);
T = linspace(0,(L-1)/Fs,L);

Buffsize = 1024;
audioOut = audioDeviceWriter(Fs,"BufferSize",Buffsize);

hide_pos = -1000;

% finder
fi.rate   = 0.1;  % finderの速度比
fi.pos    = 0;    % finderの現在位置
fi.time   = 0.05; % grainの期間
fi.npart  = 8;   % particleの数

fi.dur  = 0;  % 前回のgrainからの期間

fi.g_pos   = hide_pos*ones(fi.npart,1); % grainの位置
fi.g_alive = zeros(fi.npart,1); % grainの生存
fi.g_age   = zeros(fi.npart,1); % grain生成からの期間
fi.g_pan   = zeros(fi.npart,1);
fi.g_pan_coeff = zeros(fi.npart,2);

fi.A = 0.1;
fi.S = 0.1;
fi.R = 0.1;

fi.pan      = 0;
fi.pan_rand = 1;

fi.time_rand =1;

pan_coeff = @(pan) [cos(pi*(pan+1)/2),sin(pi*(pan+1)/2)];

%%{
f = figure;
plot(T,X,Color="#666666");
axis tight;
hold on;
fi.xline  = xline(fi.pos/Fs,"r");
fi.scatter= scatter(fi.g_pos/Fs,fi.g_pan,"filled","r");
hold off;
xlim([0,inf]);
ylim([-1.1,1.1]);
%}

while(1)
    % 出力を初期化
    y = zeros(Buffsize,2);

    % finder を進める
    for i = 1:Buffsize
        fi.pos = mod(fi.pos + fi.rate,L);
        fi.dur = fi.dur + 1/Fs;

        % grain の獲得
        if fi.dur > fi.time && sum(fi.g_alive)<fi.npart
            fi.dur = 0;

            for j = 1:fi.npart
                if fi.g_alive(j) == 0
                    fi.g_alive(j) = 1;
                    fi.g_age(j) = 0;
                    fi.g_pos(j) = floor(fi.pos+fi.time_rand*L*(2*rand-1));
                    fi.g_pan(j) = max(min(fi.pan/2+fi.pan_rand*(2*rand-1),1),-1);
                    fi.g_pan_coeff(j,:) = pan_coeff(fi.g_pan(j));
                    break
                end
            end
        end

        % grain の再生

        % 時間と位置を進める
        fi.g_age = fi.g_age + 1/Fs;
        fi.g_pos = mod(fi.g_pos,L)+1;
        
        % 再生
        for j = 1:fi.npart
            if fi.g_alive(j) == 1
                % 再生
                if fi.g_age(j) < fi.A+fi.S+fi.R
                    if fi.g_age(j) < fi.A
                        amp = fi.g_age(j)/fi.A;
                    elseif fi.g_age(j) < fi.A+fi.S
                        amp = 1;
                    else
                        amp = max(0,1-(fi.g_age(j)-(fi.A+fi.S))/fi.R);
                    end

                    y(i,:) = y(i,:) + amp*fi.g_pan_coeff(j,:).*X(fi.g_pos(j),:);

                    % 死
                else 
                    fi.g_alive(j) = 0;
                end
            end
        end
    end
    
    %%{
    fi.xline.Value = fi.pos/Fs;
    fi.scatter.XData = fi.g_pos(fi.g_alive==1)/Fs;
    fi.scatter.YData = fi.g_pan(fi.g_alive==1);
    drawnow;
    %}
    
    audioOut(y);
end
release(audioOut);

