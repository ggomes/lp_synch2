classdef MPLP
    
    properties
        
        % setup
        net
        lp
        stngs
        
        % mpt toolbox
        opt
        sol
        N
        F
        g
        F11
        F12
        F21
        F22
        g11
        g21
        R_equal
        R_equal_indx
        
    end
    
    methods
        
        % constructor
        function [obj] = MPLP(net,lp,stngs)
            obj.net = net;
            obj.lp = lp;
            obj.stngs = stngs;
            obj.opt = Opt(lp.cnst,lp.cost,lp.n(:,1),lp.r(:,1));
        end
        
        % solve
        function [obj] = solve(obj)
            obj.sol = obj.opt.solve();
            obj.N = obj.sol.xopt.Num;
            for k=1:obj.N
                obj.F = obj.sol.xopt.Set(k).Functions('primal').F;
                obj.g = obj.sol.xopt.Set(k).Functions('primal').g;
                obj.F11(k) = obj.F(1,1);
                obj.F12(k) = obj.F(1,2);
                obj.F21(k) = obj.F(2,1);
                obj.F22(k) = obj.F(2,2);
                obj.g11(k) = obj.g(1,1);
                obj.g21(k) = obj.g(2,1);
            end
            
            
            for k=1:obj.N
                obj.R_equal{k} = find( ...
                      abs( obj.F11 - obj.F11(k) ) < 1e-3 ...
                    + abs( obj.F12 - obj.F12(k) ) < 1e-3 ...
                    + abs( obj.F21 - obj.F21(k) ) < 1e-3 ...
                    + abs( obj.F22 - obj.F22(k) ) < 1e-3 ...
                    + abs( obj.g11 - obj.g11(k) ) < 1e-3 ...
                    + abs( obj.g21 - obj.g21(k) ) < 1e-3  == 6 );
            end;
            obj.R_equal_indx = [1:obj.N; ones(1,obj.N)];
            
        end
        
        % plot
        function [obj] = plot(obj)
            
            figure
            
            subplot(2,3,1)
            plot(obj.F11)
            title('F_{11}')
            grid
            xlim([1 obj.N])
            h = findobj(gcf,'type','line');
            set(h,'linewidth',2)
            
            subplot(2,3,2)
            plot(obj.F12)
            title('F_{12}')
            grid
            xlim([1 obj.N])
            h = findobj(gcf,'type','line');
            set(h,'linewidth',2)
            set(h,'linewidth',2)
            
            subplot(2,3,4)
            plot(obj.F21)
            title('F_{21}')
            grid
            xlim([1 obj.N])
            h = findobj(gcf,'type','line');
            set(h,'linewidth',2)
            
            subplot(2,3,5)
            plot(obj.F22)
            title('F_{22}')
            grid
            xlim([1 obj.N])
            h = findobj(gcf,'type','line');
            set(h,'linewidth',2)
            set(h,'linewidth',2)
            
            figure
            subplot(2,1,1)
            plot(obj.g11)
            title('g_{1}')
            grid
            xlim([1 obj.N])
            h = findobj(gcf,'type','line');
            set(h,'linewidth',2)
            
            subplot(2,1,2)
            plot(obj.g21)
            title('g_{2}')
            grid
            xlim([1 obj.N])
            h = findobj(gcf,'type','line');
            set(h,'linewidth',2)
            
%             j = 1; counter = 0;
%             while j<=obj.N
%                 counter = counter+1;
%                 comb_reg.set(counter).r = obj.R_equal{j};
%                 comb_reg.set(counter).region = solution.xopt.Set(obj.R_equal{j});
%                 comb_reg.set(counter).F = solution.xopt.Set(obj.R_equal{j}(1)).Functions('primal').F;
%                 comb_reg.set(counter).g = solution.xopt.Set(obj.R_equal{j}(1)).Functions('primal').g;
%                 for k=1:size(obj.R_equal{j},2)
%                     obj.R_equal_indx(2,obj.R_equal{j}(k)) = 0;
%                 end;
%                 %         j = R_equal{j}(end)+1;
%                 j = min(find(obj.R_equal_indx(2,:)>0));
%                 figure; comb_reg.set(counter).region.plot;
%             end;
%             comb_reg.N = counter;
%             
%             figure;
%             for k = 1:counter
%                 if mod(counter,3) == 0 N_plt = (counter-mod(counter,3))/3;
%                 else
%                     N_plt = (counter-mod(counter,3))/3+1;
%                 end;
%                 subplot(3,N_plt,k); comb_reg.set(k).region.plot;
%             end;
%             %
%             for k = 1:counter
%                 clear temp_Xmin temp_Xmax temp_Ymin temp_Ymax
%                 N_r = size(comb_reg.set(k).region,1);
%                 for j = 1:N_r
%                     V = comb_reg.set(k).region(j).V;
%                     temp_Xmin(j) = min(V(:,1)); temp_Xmax(j) = max(V(:,1));
%                     temp_Ymin(j) = min(V(:,2)); temp_Ymax(j) = max(V(:,2));
%                 end;
%                 Xmin(k) = min(temp_Xmin); Xmax(k) = max(temp_Xmax);
%                 Ymin(k) = min(temp_Ymin); Ymax(k) = max(temp_Ymax);
%             end;
%             Regions = 1:counter;
%             region_sel = find(abs(Xmin-min(Xmin))<1e-3 & abs(Ymin-min(Ymin))<1e-3);
%             Regions(region_sel) = 0;
%             % Orders = [5; 3; 1; 7; 4; 2; 8; 6];
%             % Orders = Orders(end:-1:1)
%             % %% figures (sorted)
%             %     figure;
%             %     for i = 1:counter
%             %         k = Orders(i);
%             %         subplot(3,mod(counter,3)+1,i); comb_reg.set(k).region.plot;
%             %     end;
%             
%             %%
%             % finding V represntation of the whole region
%             clear R F_cnt g_cnt R_cnt
%             for k = 1:counter
%                 nV0 = 0;
%                 clear V
%                 for j = 1:size(comb_reg.set(k).region,1)
%                     nV1 = nV0+size(comb_reg.set(k).region(j).V,1);
%                     V(nV0+1:nV1,:) = comb_reg.set(k).region(j).V;
%                     nV0 = nV1;
%                 end;
%                 R(k) = Polyhedron('V',V);
%                 F_cnt(:,:,k) = comb_reg.set(k).F;
%                 g_cnt(:,:,k) = comb_reg.set(k).g;
%                 R_cnt(k) = F_cnt(:,:,k)*R(k)+g_cnt(:,:,k);
%             end;
%             %%%%%%%%
%             ncr = obj.net.f1_bar / obj.net.v1;
%             %%%%%%%%
%             
%             figure; hold on; R.plot; line([ncr;ncr],[0;ncr]); line([ncr,n1_jam],[ncr,ncr]); line([0,ncr],[n2_jam, ncr]); h = findobj(gcf,'type','line'); set(h,'linewidth',2); set(h,'color','k'); set(h,'LineStyle','-.');
%             figure; R_cnt.plot;
%             figure;
%             for k = 1:size(R,2)
%                 R_size = size(R,2);
%                 if mod(R_size,3) == 0 N_plt = (R_size-mod(R_size,3))/3;
%                 else
%                     N_plt = (R_size-mod(R_size,3))/3+1
%                 end;
%                 subplot(3,N_plt,k); R(k).plot; xlim([0 n1_jam]); ylim([0 n1_jam]);
%             end;
%             
%             figure;
%             for k = 1:size(R,2)
%                 R_cnt_size = size(R_cnt,2);
%                 if mod(R_cnt_size,3) == 0 N_plt = (R_cnt_size-mod(R_cnt_size,3))/3;
%                 else
%                     N_plt = (R_cnt_size-mod(R_cnt_size,3))/3+1
%                 end;
%                 subplot(3,N_plt,k); R_cnt(k).plot; xlim([-0.1 1.2*r1_bar]); ylim([-0.1 1.2*r1_bar]);
%             end;
%             
%             %%
%             
%             %%%%%
%             figure; hold on; for k=1:comb_reg.N comb_reg.set(k).region.plot; end;
%             % Cost
%             F_obj = solution.xopt.Set(k).Functions('obj').F;
%             g_obj = solution.xopt.Set(k).Functions('obj').g;
%             F11_obj(k) = F_obj(1,1);    F12_obj(k) = F_obj(1,2);    %F13_obj(i) = F_obj(1,3);
%             g11_obj(k) = g_obj(1,1);
%             %     end;
%             figure;
%             subplot(1,2,1); plot(F11_obj); grid; xlim([1 N]); h = findobj(gcf,'type','line'); set(h,'linewidth',2);
%             subplot(1,2,2); plot(F12_obj); grid; xlim([1 N]); h = findobj(gcf,'type','line'); set(h,'linewidth',2);
%             %subplot(1,3,3); plot(F13_obj); grid; xlim([1 N]); h = findobj(gcf,'type','line'); set(h,'linewidth',2);
%             figure;
%             plot(g11_obj); grid; xlim([1 N]); h = findobj(gcf,'type','line'); set(h,'linewidth',2);
            
            
            
            
        end
    
    end
    
end

