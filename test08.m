%% Plotting Two constellation  % Test
clear
clc
%%
sat1 = [[2022 10 1 0 03 24],7878,0,89,0,0,0];
sat2 = [[2022 10 1 0 03 24],6878,0,70,0,0,0];
sats1 = ss_walker(11, 13, 7, sat1);
sats2 = ss_walker(10, 17, 9, sat2);
epheci1 = ss_coe_to_eci(sats1);
epheci2 = ss_coe_to_eci(sats2);
ephvec_ecef1 = ss_sft_eci_to_ecef(epheci1(:,7:12),epheci1(:,1:6));
ephvec_ecef2 = ss_sft_eci_to_ecef(epheci2(:,7:12),epheci2(:,1:6));
Rpoints = ss_grid_ecef(10);
%%
figure(1)
[x,y,z] = sphere;
hold on
mesh(x*6378.137,y*6378.137,z*6378.137)
plot3(ephvec_ecef1(:,1),ephvec_ecef1(:,2),ephvec_ecef1(:,3),'k*') 
plot3(ephvec_ecef2(:,1),ephvec_ecef2(:,2),ephvec_ecef2(:,3),'g*') 
%plot3(Rpoints(:,1),Rpoints(:,2),Rpoints(:,3),'ro') 
axis equal