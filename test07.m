clear
clc
%%
Rpoints = ss_grid_ecef(10000);
d = ecef2lla(Rpoints);
diff1 = zeros(1,size(Rpoints,1));
diff2 = zeros(size(Rpoints,1),2);
for i = 2:size(Rpoints,1)
   diff2(i,:) = abs(d(1,1:2) - d(i,1:2));
   diff1(i) =  norm(Rpoints(1,:) - Rpoints(i,:));
end
diff1(1) = max(diff1);
diff2(1,:) = max(diff2)';
%%
min(diff1)
min(diff2)