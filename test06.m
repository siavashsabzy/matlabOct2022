clear
clc
%%
sat1 = [[2022 10 1 0 03 24],7000,0,90,0,0,0];
sats = ss_walker(11, 30, 5, sat1);
epheci = ss_coe_to_eci(sats);
ephvec_ecef = ss_sft_eci_to_ecef(epheci(:,7:12),epheci(:,1:6));
Rpoints = ss_grid_ecef(500);
%%
figure(1)
[x,y,z] = sphere;
hold on
mesh(x*6337,y*6337,z*6337)
plot3(ephvec_ecef(:,1),ephvec_ecef(:,2),ephvec_ecef(:,3),'k*') 
% plot3(Rpoints(:,1),Rpoints(:,2),Rpoints(:,3),'ro') 
axis square
% for i = 1:size(ephvec_ecef,1)
%    
% end