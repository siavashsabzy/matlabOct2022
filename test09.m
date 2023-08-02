clear
clc
%%
tic
sat = [[2022 11 1 0 03 24],7078,0,60,0,0,0];
% sats = ss_walker(15, 11, 1, sat);
epheci = ss_coe_to_eci(sat);
ephvec_ecef = ss_sft_eci_to_ecef(epheci(:,7:12),epheci(:,1:6));
Rpoints = [6378.137 0 0];
for i = 1: size(Rpoints,1)
    for j = 1:size(ephvec_ecef,1)
        [ E(i,j) , ~ , ~ ] = ss_user_az_el_ra( Rpoints(i,:) , ephvec_ecef(j,1:3) );
    end
end
toc