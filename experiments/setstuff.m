function []=setstuff(K,KdemAll,ss)
grid
ylim = get(gca,'YLim');
axis([0 K ylim])
vline(KdemAll,'--')
if(nargin>2)
    hline(ss,'--')
end
