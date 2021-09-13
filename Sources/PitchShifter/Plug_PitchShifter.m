classdef Plug_PitchShifter < audioPlugin
    %#codegen
    properties
        %% Audio Setting
        
        % Sampling Freq
        Fs = 44100;
        
        %% PitchShifting variables
        % Buffer Size
        N = 2048;
        
        % Loop Length
        L = 512;
        
        % Main Buffer
        BF
        
        % Reader Positions
        pos1
        pos2
        
        % Crossfade Coefficieant
        cross_coeff = 1;
        
        %% F0 Estimation variables
        
        % Lowpass
        LPBF
        LPZ
        LPCoeff
        
        %%　
        % f0 duration
        f0_duration = 128;
        f0_count = 0;
        
        %% Parameter
        pitch = 0
        
        adaptive_loop_length = true
        
        fmin = 100;
        fmax = 1000;
        
        %% Visualization variables
        
        F0Buff;
        FFTBuff;
        lastACF;
        lastLocsACF;
    end
    
    %% User Interface
    properties (Constant)
        PluginInterface = audioPluginInterface(...
            audioPluginParameter('pitch','DisplayName','Shift',...
                                 'Label','cent',...
                                 'Mapping',{'lin',-24,24}),...
            audioPluginParameter('adaptive_loop_length','DisplayName','Adaptive Loop Length',...
                                 'Mapping',{'enum','on','off'},...
                                 'Style','checkbox' ...
                                 ));
    end
    
    %%
    methods
       function obj = Plug_PitchShifter()
            %% Initialize buffers with zeros
            obj.BF = Module_Buffer(obj.N,1);
            obj.pos1 = obj.N/2;
            obj.pos2 = (obj.N-obj.L)/2;
            
            obj.LPBF = Module_Buffer(obj.N,1);
            obj.LPZ  = zeros(5,1);
            obj.LPCoeff = [1 1 1 1 1 -0.96]/6;
            
            obj.F0Buff = Module_Buffer(obj.N,1);
            obj.FFTBuff = zeros(obj.N/2,1);
       end
       
        %% Main Process
        function out = process(obj, in)
            %% Modify input signal
            
            % monolize
            in = mean(in,2);
            
            % get the size of input
            [framesize,nchannel] = size(in);
            
            % create output matrix
            out = zeros(framesize, nchannel);
            
            %% Filtering (for f0 estimation)
            [in_filted,obj.LPZ] = filter(obj.LPCoeff,1,in,obj.LPZ);
            
            %% main loop
            for i = 1:framesize
                %% Put input signal in buffer
                % get x from input 
                x = in(i,:);
                x_filted = in_filted(i,:);
                
                % put x in Buffer
                obj.BF = obj.BF.put_sample(x);
                obj.LPBF = obj.LPBF.put_sample(x_filted);
                
                %% Calc L
                
                if rem(obj.f0_count,obj.f0_duration) == 0

                    % calc Autocorrection Function
                    ACF = xcorr(obj.LPBF.buff.*blackman(obj.N));
                    ACF = ACF(floor(end/2):end);
                    ACF = ACF/ACF(1);

                    % find peaks
                    [~,locsACF] = findpeaks(ACF,'MinPeakProminence',0.3);

                    % 
                    if ~isempty(locsACF)
                        T0 = locsACF(1);
                        obj.L = T0*2;
                        obj.F0Buff = obj.F0Buff.put_sample(obj.Fs/T0);
                    else
                        obj.F0Buff = obj.F0Buff.put_sample(0);
                    end
                    
                    % reset counter
                    obj.f0_count = 0;
                    
                    % save current ACF
                    obj.lastACF = ACF;
                    obj.lastLocsACF = locsACF;
                    
                else
                    obj.F0Buff = obj.F0Buff.put_sample(obj.Fs/obj.L*2);
                end
                
                if ~obj.adaptive_loop_length
                    obj.L = 512;
                end
                
                % update counter
                obj.f0_count = obj.f0_count + 1;
                
               %% Update Readers
               
                % set loop range
                bf_left = (obj.N - obj.L)/2;
                bf_right = bf_left + obj.L - 1;
                
                % calc step length
                step = 2^(obj.pitch/12) - 1;
                
                % step position
                obj.pos1 = obj.pos1 + step;
                obj.pos2 = obj.pos2 + step;
                
                % looper
                if obj.pos1 < bf_left
                    obj.pos1 = obj.pos1 + obj.L;
                elseif bf_right < obj.pos1
                    obj.pos1 = obj.pos1 - obj.L;
                end
                
                if obj.pos2 < bf_left
                    obj.pos2 = obj.pos2 + obj.L;
                elseif bf_right < obj.pos2
                    obj.pos2 = obj.pos2 - obj.L;
                end
                
                %% CrossFade
                
                % get sample from Buffer
                y1 = obj.BF.get_sample(obj.pos1);
                y2 = obj.BF.get_sample(obj.pos2);
                
                % crossfade func
                clip = @(x) min(1,max(0,x));
                calc_d = @(pos) abs(pos-obj.N/2);
                calc_a = @(pos) clip((calc_d(pos)-obj.L/4)...
                                     /obj.cross_coeff+1/2);
                % calc mix value
                fade_mix = calc_a(obj.pos1);
                
                y = y1;%fade_mix*y1 + (1-fade_mix)*y2;
                
                %% Signal Output
                out(i,:) = y;
            end
            
            out = [out, out];
            
            %% Plot
            
            %%{
            figure(1);
            clf;
            hold on;

            % Buffer
            subplot(3,1,1);
            plot(obj.LPBF.buff,'color','#999999');
            fadecol1 = [1,fade_mix,fade_mix];
            fadecol2 = [1-fade_mix,1-fade_mix,1];

            xline(obj.pos1,'color',fadecol1);
            xline(obj.pos2,'color',fadecol2);

            xline(bf_left);
            xline(bf_right);
            
            xlim([-inf inf]);
            ylim([-1 1]);
            xticks([]);
            
            ylabel('Amptitude')
            
            title('Buffer')

            % Autocorrection Function
            ax = subplot(3,1,2);
            plot(obj.lastACF);
            hold on;
            
            if ~isempty(obj.lastLocsACF)
                plot(obj.lastLocsACF(1),...
                     obj.lastACF(obj.lastLocsACF(1)),'o');
            end
            
            xlim([-inf inf]);ylim([-1 1]);
            xticks([]);
            
            ylabel('Autocorrection')
            
            title('Autocorrection Function')
            
            % Pitch
            subplot(3,1,3);
            plot(obj.F0Buff.buff);
            xlim([-inf inf]);
            xticks([]);
            ylim([0 1000]);

            ylabel('Frequency [Hz]');
            title('Pitch')
            
            drawnow;
            
            %}
        end
    end
end
