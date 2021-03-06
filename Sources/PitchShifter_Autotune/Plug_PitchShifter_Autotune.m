classdef Plug_PitchShifter_Autotune < audioPlugin
    %#codegen
    properties
        %% Audio Setting
        
        % Sampling Freq
        Fs = 44100;
        
        %% PitchShifting variables
        % Buffer Size
        N = 1024;
        
        % Loop Length
        L = 512;
        
        % Main Buffer
        BF
        
        % Reader Positions
        reader_pos
        
        % Crossfade Ratio
        cross_rate = 0.1;
        
        %% F0 Estimation variables
        
        % Lowpass
        LPBF
        LPZ
        LPCoeff
        
        % T0
        T0 = 512
        
        % f0 duration
        f0_duration = 128;
        f0_count = 0;
        
        % f0 filter
        LPZ_F0;
        LPCoeff_F0;
       
        %% Parameter
        
        % shift amount
        pre_shift = 0
        
        % post shift
        post_shift = 0
        
        % autotune
        autotune = true;
        
        % autotune key data
        key = 'C';
        key_list = {'C','C# / Db','D','D#','E','F',...
                    'F#','G','G#','A','A#','B'}
        key_pow  = [-9, -8, -7, -6, -5, -4, -3, -2, -1, 0, 1, 2]
        
        % autotune scale data
        scale = 'Major'
        scale_list = {'Root','Chromatic','Major','Minor'};
        scale_pow  = {[0],...
                      [0,1,2,3,4,5,6,7,8,9,10,11],...
                      [0,2,4,5,7,9,11],...
                      [0,2,3,5,7,8,10]};
                  
        % autotune depth
        depth = 1;
                  
        fmin = 100;
        fmax = 500;
        
        %% Visualization variables
        do_plot = false;
        
        F0Buff;
        OutBuff;
        
        lastACF;
        lastLocACF;
    end
    
    %% User Interface
    properties (Constant)
        PluginInterface = audioPluginInterface(...
            audioPluginParameter('pre_shift','DisplayName','Pre Shift',...
                                 'Label','cent',...
                                 'Mapping',{'lin',-24,24}),...
            audioPluginParameter('autotune','DisplayName','Autotune',...
                                 'Mapping',{'enum','off','on'},...
                                 'Style','checkbox'), ...
            audioPluginParameter('depth','DisplayName','Depth',...
                                 'Mapping',{'lin',0,1}), ...
            audioPluginParameter('key','DisplayName','Key',...
                                 'Mapping',{'enum','C','C#','D','D#','E','F',...
                                                   'F#','G','G#','A','A#','B'}),...
            audioPluginParameter('scale','DisplayName','Key',...
                                 'Mapping',{'enum','Root','Chromatic','Major','Minor'}),...
            audioPluginParameter('post_shift','DisplayName','Post Shift',...
                                 'Label','cent',...
                                 'Mapping',{'lin',-24,24})...
                                 );
    end
    %% Methods
    methods
        %% Constructor
        function obj = Plug_PitchShifter_Autotune()
            %% Initialize buffers with zeros
            obj.BF = Module_Ringbuffer(obj.N,1,1);
            obj.reader_pos = obj.N/2;

            obj.LPBF = Module_Ringbuffer(obj.N,1,1);

            % visualization bariables
            obj.F0Buff = Module_Buffer(obj.N,1);
            obj.OutBuff =Module_Buffer(obj.N,1);
            
            %% Initialize Filters
            obj.LPCoeff = [1 1 1 1 1 1 1 -0.96]/6;
            obj.LPZ  = zeros(length(obj.LPCoeff)-1,1);
            
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
                
                %% f0 estimation
                if rem(obj.f0_count,obj.f0_duration) == 0

                    obj.LPBF = obj.LPBF.rearrange();
                    
                    % calc Autocorrelation Function
                    ACF = xcorr(obj.LPBF.buff.*blackman(obj.N));
                    ACF = ACF(floor(end/2):floor(end/4*3));
                    ACF = ACF/ACF(1);

                    % find peaks
                    [peaks,peakIdxs] = findpeaks(ACF,'MinPeakProminence',0.1);
                    
                    % 
                    if ~isempty(peaks)
                     %% find peak
                        
                        % find maximum peak
                        [~, Idx] = max(peaks);
                        loc = peakIdxs(Idx);
                        
                        % temporary T0
                        
                        T0_tmp = loc;
                        
                     %% F0 Validation & Correction
                        
                        % if F0 is too high (ex.noise)
                        % ...ignore & use old value
                        if T0_tmp < obj.Fs/obj.fmax
                            T0_tmp = obj.T0;
                        end
                        
                        % Correct T0
                        obj.T0 = T0_tmp;
                    else
                        loc = 1;
                    end
                    
                    % save current ACF (for visualizaiton)
                    if obj.do_plot
                        obj.lastACF = ACF;
                        obj.lastLocACF = loc;
                    end
                    
                    % reset counter
                    obj.f0_count = 0;
                end
                
                % save to buffer (for visualization)
                if obj.do_plot
                    obj.F0Buff = obj.F0Buff.put_sample(obj.Fs/obj.T0);
                end
                
                % update counter
                obj.f0_count = obj.f0_count + 1;

                %% Set loop length
                obj.L = obj.T0;
                
                %% Calc Shift Amount
                
                % pre shift
                rate = 2^(obj.pre_shift/12);
                
                % autotune
                if obj.autotune
                    % Create Scale Map
                    scale_idx = find(strcmp(obj.scale,obj.scale_list));
                    key_oct_map = obj.scale_pow{scale_idx};
                    key_map = reshape(repmat(key_oct_map.',[1,7])+...
                              repmat(12*(-3:3),[length(key_oct_map),1]),...
                              1,[]);
                    
                    % Get key index
                    key_idx = find(strcmp(obj.key,obj.key_list));
                    
                    % Calc Root Freq
                    rootfreq = 440*2.^(obj.key_pow(key_idx)/12);
                    
                    % Calc Freq Map
                    key_freq_map = rootfreq*2.^(key_map/12);
                    
                    % Find near key
                    voice_freq = (obj.Fs/obj.T0)*rate;
                    [~,nearkey_idx] = min(abs(log(key_freq_map/voice_freq)));
                    target_freq = key_freq_map(nearkey_idx);
                    
                    % Update Rate
                    rate = rate*(target_freq/voice_freq).^obj.depth;
                end
                
                % pre shift
                rate = rate * 2^(obj.post_shift/12);
                
                % calc step length
                step = rate - 1;
                
                %% Update Readers
               
                % set loop range
                bf_left = (obj.N - obj.L)/2;
                bf_right = bf_left + obj.L - 1;
                
                % step position
                obj.reader_pos = obj.reader_pos + step;
                
                % loop
                if obj.reader_pos < bf_left
                    obj.reader_pos = obj.reader_pos + obj.L;
                elseif bf_right < obj.reader_pos
                    obj.reader_pos = obj.reader_pos - obj.L;
                end
                
                %% CrossFade

                % get sample from Buffer
                y_R = obj.BF.get_sample(obj.reader_pos+obj.L,"local");
                y_C = obj.BF.get_sample(obj.reader_pos,"local");
                y_L = obj.BF.get_sample(obj.reader_pos-obj.L,"local");

                % calc mix rate
                clip = @(x) min(1,max(0,x));
                faderange = obj.L*obj.cross_rate;
                mix_R = @(pos) 1-clip((pos-(obj.N-obj.L)/2)/faderange+1/2);
                mix_L = @(pos) clip((pos-(obj.N+obj.L)/2)/faderange+1/2);
                mix_C = @(pos) 1-max(mix_R(pos),mix_L(pos));
                
                y = y_L*mix_L(obj.reader_pos) + ...
                    y_R*mix_R(obj.reader_pos) + ...
                    y_C*mix_C(obj.reader_pos);
                
                %% Signal Output
                out(i,:) = y;
                
                % save for visualization
                if obj.do_plot
                    obj.OutBuff = obj.OutBuff.put_sample(y);
                end
            end
            
            %% Modify output sig
            out = [out, out];
            
            %% Plot
            
            %{
            if obj.do_plot
                clf;

                % Buffer
                subplot(2,2,1);
                hold on;
                plot(obj.BF.buff,'color','#888888');
                plot(obj.reader_pos, y, 'o','color', 'r');
                fadecol = [1,0,0];
                xline(obj.reader_pos,'color',fadecol);
                yline(y,':','color','r');

                xline(bf_left);
                xline(bf_right);

                xlim([1 obj.N]);
                ylim([-1 1]);
                xticks([]);

                ylabel('Amplitude')

                title('Input Signal')

                % Output
                subplot(2,2,2);
                hold on;
                plot(obj.OutBuff.buff,'color','#888888');
                ylabel('Amplitude')
                title('Output Signal')
                plot(obj.N, y, 'o','color', 'r');

                xlim([-inf inf]);
                ylim([-1 1]);
                xticks([]);

                yline(y,':','color','r');

                % Autocorrelation Function
                subplot(2,2,3);
                plot(obj.lastACF);
                hold on;

                if ~isempty(obj.lastLocACF)
                    plot(obj.lastLocACF,...
                         obj.lastACF(obj.lastLocACF(1)),'o');
                end

                xlim([-inf inf]);ylim([-1 1]);
                xticks([]);

                ylabel('Autocorrelation')

                title('Autocorrelation Function')

                % Pitch
                subplot(2,2,4);
                plot(obj.F0Buff.buff);
                xlim([-inf inf]);
                xticks([]);
                ylim([0 1000]);

                ylabel('Frequency [Hz]');
                title('Pitch')

                drawnow;
            end
            %}
        end
    end
end
