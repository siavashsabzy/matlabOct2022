clear
clc
%%
sat1 = [[2022 10 1 0 03 24],7000,0,69,0,0,0];
x = ss_coe_to_eci(sat1);
%%
ephvec_out = ss_j2_propagator([2022 10 1 0 03 24],[2022 10 1 4 03 24],x(1,7:12),1440);
%%
ephvec_ecef = ss_sft_eci_to_ecef(ephvec_out(:,7:12),ephvec_out(:,1:6));
%%
Rpoints = ss_grid_ecef(2500);
% %%
[x,y,z] = sphere;
figure(1)
mesh(x*6372,y*6372,z*6372)
hold on
axis([-8000 8000 -8000 8000 -8000 8000])
h = scatter3(Rpoints(:,1)',Rpoints(:,2)',Rpoints(:,3)','r*');
c = h.CData;
% c is now a 1x3, meaning a RGB color that's used for all of the points
c = repmat(c,[size(Rpoints,1) 1]);
% c is now a 5x3 containing 5 copies of the original RGB
E = zeros(size(ephvec_out,1),size(Rpoints,1));
axis square
for i = 1:size(ephvec_out,1)
    plot3(ephvec_ecef(i,1),ephvec_ecef(i,2),ephvec_ecef(i,3),'k.')
    for j = 1: size(Rpoints,1)
        [ E(i,j) , ~ , ~ ] = ss_user_az_el_ra( Rpoints(j,:) , ephvec_ecef(i,1:3) );
        if E(i,j) > 10
            c(j,:) = [0 0 1];
            % c now contains red, followed by 4 copies of the original color
        else
            c(j,:) = [1 0 0];
            % c now contains red, followed by 4 copies of the original color
        end
        pause(0)
    end
    h.CData = c;
end