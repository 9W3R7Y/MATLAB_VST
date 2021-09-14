function test_plugin_realtime(p, Fs, BFSIZE, TIME_END, PLOT)
    %% preparation
    
    % validate arguments
    arguments
        p;
        Fs;
        BFSIZE;
        TIME_END = 10;
        PLOT = 0;
    end
    
    % create audio device objects
    adr = audioDeviceReader(Fs, BFSIZE,...
                            'NumChannels', 1);
    adw = audioDeviceWriter(Fs, ...
                           'SupportVariableSizeInput', true,...
                           'BufferSize', BFSIZE);
    
    % set plugin sampling frequency
    p.Fs = Fs;
    
    % start loop
    tic
    
    %% plot preparation
    if PLOT
        % create figure
        f = figure(1);
        set(f,"Visible",true);
        
        % create buffer
        vis_timerange = 0.5;
        vis_in = zeros(1,vis_timerange*Fs);
        vis_out = zeros(1,vis_timerange*Fs);
        vis_t = linspace(toc-vis_timerange,toc,Fs*vis_timerange);

        % time duration for plot
        dt = 1/5;
        t_lastplot = 0;
    end
    
    %% main loop
    while toc < TIME_END
        %% audio processing
        
        % read buffer;
        in = adr();
        
        % process
        out = p.process(in);
        
        % write buffer
        adw(out);
                
        %% visualize
        if PLOT
            %% update buffer
            vis_in(1:end-BFSIZE) = vis_in(BFSIZE+1:end);
            vis_in(end-BFSIZE+1:end) = in;
            vis_out(1:end-BFSIZE) = vis_out(BFSIZE+1:end);
            vis_out(end-BFSIZE+1:end) = out;
            
            %% plot
            if toc - t_lastplot> dt
                tiledlayout("flow");
                nexttile;line(1:BFSIZE,in,"Color","k");
                title("Current Input Buffer");
                xlim([-inf inf]);ylim([-1 1]);yline(0);

                nexttile;line(1:BFSIZE,out,"Color","k");
                title("Current Output Buffer");
                xlim([-inf inf]);ylim([-1 1]);yline(0);

                nexttile;line(vis_t,vis_in,"Color","k");
                title("Recent Input");xlim([-inf inf]);ylim([-1 1]);yline(0);

                nexttile;line(vis_t,vis_out,"Color","k");
                title("Recent Output");xlim([-inf inf]);ylim([-1 1]);yline(0);

                drawnow;

                t_lastplot = toc;
            end
        end
    end
end