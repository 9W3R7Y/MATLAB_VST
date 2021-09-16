classdef Plug_SimplePitchShifter < audioPlugin
    %#codegen
    properties
        Fs
        N = 512
        RB1
        RB2
        pos = 0
        pitch = 0
        cross_coeff=128
    end
    
    properties (Constant)
        PluginInterface = audioPluginInterface(...
            audioPluginParameter('pitch','DisplayName','Shift',...
                                 'Label','cent',...
                                 'Mapping',{'lin',-24,24}),...
            audioPluginParameter('cross_coeff','DisplayName','Crossfade',...
                                 'Label','%',...
                                 'Mapping',{'lin',1,512})...
            )
    end
    
    methods
        function obj = Plug_SimplePitchShifter()
            obj.RB1 = Module_Ringbuffer(obj.N,1,1);
            obj.RB2 = Module_Ringbuffer(obj.N,1,obj.N/2+1);
        end
        
        function out = process(obj, in)
            % monolize
            in = mean(in,2);
            
            % get the size of input
            [framesize,nchannel] = size(in);
            
            % create output matrix
            out = zeros(framesize, nchannel);
            
            % main loop
            for i = 1:framesize
                % get x from input 
                x = in(i,:);
                
                % put x in RB
                obj.RB1 = obj.RB1.put_sample(x);
                obj.RB2 = obj.RB2.put_sample(x);
                
                % update pos
                obj.pos = obj.pos + 2^(obj.pitch/12);
                obj.pos = mod(obj.pos,obj.N);
                
                % get sample from RB
                y1 = obj.RB1.get_sample(obj.pos);
                y2 = obj.RB2.get_sample(obj.pos);
                
                % crossfade
                clip = @(x) min(1,max(0,x));
                calc_d = @(i,pos,N) min(N-max(i-pos,pos-i),...
                                          max(i-pos,pos-i));
                calc_a = @(i,pos,N,alpha) clip((calc_d(i,pos,N)-N/4)...
                                               /alpha+0.5);

                fade_coeff = calc_a(obj.RB1.i,obj.pos,...
                                    obj.N,obj.cross_coeff);
                
                y = fade_coeff*y1 + (1-fade_coeff)*y2;
                    
                % output
                out(i,:) = y;
            end
            
            out = [out, out];
        end
    end
end
