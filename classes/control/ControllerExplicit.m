classdef ControllerExplicit 
    
    properties
        u_given
    end
    
    methods
        
        function [obj]=ControllerExplicit(u_given)
            obj.u_given = u_given;
        end
        
        function [u]=get_control(obj,k,X)
            u = obj.u_given;
        end
           
        
    end
    
end

