function mini = costfunction_temp2(np)
sat1 = [[2022 10 1 0 03 24],7000,0,90,0,0,0];
faz = ( np(3) * ( np(1) - 1 ) );
sats = ss_walker(floor(np(1)), floor(np(2)), faz, sat1);
epheci = ss_coe_to_eci(sats);
ephvec_ecef = ss_sft_eci_to_ecef(epheci(:,7:12),epheci(:,1:6));
Rpoints = ss_grid_ecef(500);
covt = zeros(1,size(Rpoints,1));
for i = 1: size(Rpoints,1)
    for j = 1:size(ephvec_ecef,1)
        [ E , ~ , ~ ] = ss_user_az_el_ra( Rpoints(i,:) , ephvec_ecef(j,1:3) );
        if E > 10
            covt(i) = 1;
            break;
        else
            
        end
    end
end
    if min(covt) == 0
        mini = 1e10;
    else
        mini = np(1)*np(2);
    end
end