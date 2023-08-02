clear
clc
%%
sat1 = [[2022 10 1 0 03 24],7000,0,20,0,0,0];
sats = ss_walker(15, 11, 1, sat1);
epheci = ss_coe_to_eci(sats);
ephvec_ecef = ss_sft_eci_to_ecef(epheci(:,7:12),epheci(:,1:6));
Rpoints = ss_grid_ecef(1000);
for i = 1: size(Rpoints,1)
    for j = 1:size(ephvec_ecef,1)
        [ E(i,j) , ~ , ~ ] = ss_user_az_el_ra( Rpoints(i,:) , ephvec_ecef(j,1:3) );
    end
end