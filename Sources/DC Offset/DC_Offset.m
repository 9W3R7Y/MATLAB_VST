classdef DC_Offset < audioPlugin
    properties
        Shift = 0;
    end
    
    properties (Constant)
        PluginInterface = audioPluginInterface( ...
            audioPluginParameter('Shift', ...
                'Label','%', ...
                'Mapping',{'lin',-200,200}))
    end
    
    methods
        function out = process(p,in)
            left = in(:,1) + p.Shift/100;
            right = in(:,2) - p.Shift/100;
            out = [left right];
        end
    end
end