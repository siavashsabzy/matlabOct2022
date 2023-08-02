clear
clc
%%
fid = fopen('ss_iran_boundaries.txt','r');
my_iran = fscanf(fid,'%f %f \n');
fclose(fid);
iranboundaries  = [my_iran(1:2:end) my_iran(2:2:end)];