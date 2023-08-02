clear
clc
%%
aa = datevec(now);
% x = [5956643.97078590 3439070 0.000 -2017.03342114598 3493.60436598931 6455.85646017942].*1e-3;
sat1 = [[2022 10 1 0 03 24],7000,0,39.285,0,0,0];
x = ss_coe_to_eci(sat1);
%%
ephvec_out = ss_j2_propagator([2022 10 1 0 03 24],[2022 10 1 4 03 24],x(1,7:12),1440);
%%
ephvec_ecef = ss_sft_eci_to_ecef(ephvec_out(:,7:12),ephvec_out(:,1:6));
%%
[x,y,z] = sphere;
figure(1)
Rcv = ss_user_geodetic_ecef([37 52 10]);
plot3(Rcv(1),Rcv(2),Rcv(3),'r*')
hold on
mesh(x*6337,y*6337,z*6337)
axis([-8000 8000 -8000 8000 -8000 8000])
axis square
rotate3d on
for i = 1 : 1440
    [ E , A , D ] = ss_user_az_el_ra( Rcv , ephvec_ecef(i,1:3) );
    if E > 10 * pi /180
        plot3(ephvec_ecef(i,1),ephvec_ecef(i,2),ephvec_ecef(i,3),'og')
    else
        plot3(ephvec_ecef(i,1),ephvec_ecef(i,2),ephvec_ecef(i,3),'or')
    end
    pause(0.01)
end
% plot3(ephvec_out(:,9),ephvec_out(:,8),ephvec_out(:,9))
%%
% [E,A,D]=ss_user_az_el_ra(Rcv,ephvec_ecef(1,1:3));