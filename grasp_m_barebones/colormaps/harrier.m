function [cmap] = cejet2(maplength);
% ColEdit function [cmap] = cejet2(maplength);
%
% colormap m-file written by ColEdit
% version 1.1 on 15-Feb-2002
%
% input  :	[maplength]	[64]	- colormap length
%
% output :	cmap			- colormap RGB-value array
 
% set red points
r = [ [];...
    [0 0.25];...
    [0.375 0.25];...
    [0.625 1];...
    [0.875 1];...
    [1 0.5];...
    [] ];
 
% set green points
g = [ [];...
    [0 0.35];...
    [0.375 1];...
    [0.625 1];...
    [0.875 0];...
    [1 0];...
    [] ];
 
% set blue points
b = [ [];...
    [0 0.7];...
    [0.125 1];...
    [0.25 1];...
    [0.625 0];...
    [1 0];...
    [] ];
% ColEditInfoEnd
 
% get colormap length
if nargin==1 
  if length(maplength)==1
    if maplength<1
      maplength = 64;
    elseif maplength>256
      maplength = 256;
    elseif isinf(maplength)
      maplength = 64;
    elseif isnan(maplength)
      maplength = 64;
    end
  end
else
  maplength = 64;
end
 
% interpolate colormap
np = linspace(0,1,maplength);
rr = interp1(r(:,1),r(:,2),np,'linear');
gg = interp1(g(:,1),g(:,2),np,'linear');
bb = interp1(b(:,1),b(:,2),np,'linear');
 
% compose colormap
cmap = [rr(:),gg(:),bb(:)];
