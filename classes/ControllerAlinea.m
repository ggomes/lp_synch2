classdef ControllerAlinea 
    
    properties
        target
        gain
        u
    end
    
    methods
        
        function [obj]=ControllerAlinea(net)
            obj.gain = [1;1];
            obj.target = [net.f1_bar/net.v1 ; net.f2_bar/net.v2];
            obj.u = [0;0];
        end
        
        function [u,obj]=get_control(obj,k,X)
            obj.u = obj.u + obj.gain .* ( obj.target - X.n(:,k) );
            u = obj.u;
        end
        
    end
    
end

