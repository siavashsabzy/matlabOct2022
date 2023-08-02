function access_time = cost_function_temp(input)
% a = input(1);
i = input(1);
%%
Rcv = ss_user_geodetic_ecef([37 52 10]);
[X,V] = COE2RV(7000,0,i*pi/180,0,0,0);
x = [X',V'];
ephvec_out = ss_j2_propagator([2022 10 1 0 03 24],[2022 10 1 4 03 24],x,1440);
%%
ephvec_ecef = ss_sft_eci_to_ecef(ephvec_out(:,7:12),ephvec_out(:,1:6));
access_time = 1440;
for ii = 1 : 1440
    [ E , A , D ] = ss_user_az_el_ra( Rcv , ephvec_ecef(ii,1:3) );
    if E > 10 * pi /180
       access_time = access_time - 1;
    end
end
end