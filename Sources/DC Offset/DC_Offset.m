classdef DC_Offset < audioPlugin
    properties
        Shift = 0;
        Fade_Time = 0.05;
        n_t = 0;
        flag = 0;
        n_Samples = 1000;
        Threshold = 0;
        buff = zeros(2000,2);
    end
    
    properties (Constant)
        PluginInterface = audioPluginInterface( ...
            audioPluginParameter('Shift', ...
                'Label','%', ...
                'Mapping',{'lin',-200,200}), ...
            audioPluginParameter('Fade_Time', ...
                'Label','s', ...
                'Mapping',{'lin',0,0.1}),...
            audioPluginParameter('n_Samples', ...
                'Label','sample', ...
                'Mapping',{'int',1,1000}),...
            audioPluginParameter('Threshold', ...
                'Label','%', ...
                'Mapping',{'lin',0,100}))
    end
    
    methods
        function out = process(p,in)
            setLatencyInSamples(p,p.n_Samples-1);
            left = in(:,1) + p.Shift/100;
            right = in(:,2) - p.Shift/100;
            
            dc_shifted = [left right];
            
            out = zeros(size(in));
            Fs =  getSampleRate(p);
            
            f = @(x) sum(abs(x-mean(x)))/length(x);
            
            for i = 1:length(in)
                p.buff(2:end,:) = p.buff(1:end-1,:);
                p.buff(1,:) = dc_shifted(i,:);
                
                L_forward = p.buff(1:p.n_Samples,1);
                R_forward = p.buff(1:p.n_Samples,2);
                
                L_back = p.buff(p.n_Samples:p.n_Samples*2,1);
                R_back = p.buff(p.n_Samples:p.n_Samples*2,2);
                

                change_forward = max(f(L_back),f(R_back));
                change_back = max(f(L_back),f(R_back));

                if change_forward < p.Threshold/100+eps
                    if p.flag == 0
                        p.flag = 1;
                        p.n_t = 0;
                    end
                    
                    if p.n_t/Fs < p.Fade_Time
                        t = (p.Fade_Time - p.n_t/Fs)/p.Fade_Time;
                        
                        fade_func = @(t) (2-t)^2*t^2;
                        
                        out(i,:) = p.buff(p.n_Samples,:)*fade_func(t);
                        p.n_t = p.n_t + 1;
                    else
                        out(i,:) = zeros(1,2);
                    end
                elseif change_back < p.Threshold/100+eps
                    p.flag = 0;
                    out(i,:) = zeros(1,2);
                else
                    p.flag = 0;
                    out(i,:) = p.buff(p.n_Samples,:);
                end
            end
        end
    end
end