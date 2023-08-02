% function [ fxmin , xmin ] = psorun( pso_options )
clear
clc
close all
%%
tt = cputime;
format long

global psoFlags;
global psoVars;
global psoSParameters;
global notifications;
global vizAxes; %Use the specified axes if using GUI or create a new global if called from command window


%Initializations
% if nargin == 0
    pso_options = get_pso_options();
% end




% Initializing variables
success = 0; % Success Flag
iter = 0;   % Iterations' counter
fevals = 0; % Function evaluations' counter
iteration=pso_options.Vars.Iterations;

% Using params---
% Determine the value of weight change
w_start = pso_options.SParams.w_start;   %Initial inertia weight's value
w_end = pso_options.SParams.w_end;       %Final inertia weight
w_varyfor = floor(pso_options.SParams.w_varyfor*pso_options.Vars.Iterations); %Weight change step. Defines total number of iterations for which weight is changed.
w_now = w_start;
inertdec = (w_start-w_end)/w_varyfor; %Inertia weight's change per iteration

% Initialize Swarm and Velocity
SwarmSize = pso_options.Vars.SwarmSize;
dim=pso_options.Vars.Dim;  % dim: Number of variables
UB=pso_options.Obj.ub;
LB=pso_options.Obj.lb;
% Vmax=UB-LB;

% Swarm = rand(SwarmSize,psoOptions.Vars.Dim)*(psoOptions.Obj.ub-psoOptions.Obj.lb) + psoOptions.Obj.lb;


% apply constraint on swarm initialization
Swarm=zeros(SwarmSize,dim);
for i=1:dim 
Swarm(:,i) = LB(i) + (UB(i)-LB(i)).*rand(SwarmSize,1);
end
%*********************************************************************


% % apply constraint on VStep initialization
Vup=1; %0.5  % speed coeficient for upper bound (Introduced BY EHSAN) 
Vlow=0.1;  % speed coeficient for lower bound (Introduced BY EHSAN) 
UB_Vinitial=Vup*(UB-LB);  %UB_Vinitial=Vup*((UB-LB)/2);
LB_Vinitial=Vlow*(UB-LB); %LB_Vinitial=Vlow*((UB-LB)/2);
VStep=zeros(SwarmSize,dim);
 for i=1:dim 
     VStep(:,i) = LB_Vinitial(i) + (UB_Vinitial(i)-LB_Vinitial(i)).*rand(SwarmSize,1);
 end
%----------------------------------------------------------------------
 %disp('%%%%%%%%%%%%%%%%%%%% initial VStep %%%%%%%%%%%%%%%%%%%%%%%%'); disp(VStep)

 
%Find initial function values.
fSwarm=zeros(SwarmSize,1);
f2eval = pso_options.Obj.f2eval; %The objective function to optimize.
  for j=1:SwarmSize
       fSwarm(j)=feval(f2eval,Swarm(j,:));
  end
%----------------------------------------------------------------------
%disp('%%%%%%%%%%%%%%%%%%%% initial fSwarm %%%%%%%%%%%%%%%%%%%%%%%%'); disp(fSwarm)
fevals = fevals + SwarmSize;      % fevals=counter(number of evaluation)

% Initializing the Best positions matrix and
% the corresponding function values
PBest = Swarm;
fPBest = fSwarm;

% Finding best particle in initial population
[fGBest, g] = min(fSwarm);
lastbpf = fGBest;
Best = Swarm(g,:); %Used to keep track of the Best particle ever
fBest = fGBest;
history = [0, fGBest];

if pso_options.Flags.Neighbor
    % Define social neighborhoods for all the particles
    for i = 1:SwarmSize
        lo = mod(i-pso_options.SParams.Nhood:i+pso_options.SParams.Nhood, SwarmSize);
        nhood(i,:) = [lo];
    end
    nhood(find(nhood==0)) = SwarmSize %Replace zeros with the index of last particle.
end

if pso_options.Disp.Interval && (rem(iter, pso_options.Disp.Interval) == 0)
    disp(sprintf('Iterations\t\tfGBest\t\t\tfevals'));
end
hwait = waitbar(0,'Finding Best Option ...');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%                  THE  PSO  LOOP                          %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
while( (success == 0) && (iter <= pso_options.Vars.Iterations) )   % &&
    iter = iter+1;
    
    % Update the value of the inertia weight w
    if (iter<=w_varyfor) && (iter > 1)
        w_now = w_now - inertdec; %Change inertia weight
    end
    
    
    %%%%%%%%%%%%%%%%%
    % The PLAIN PSO %
    
    % Set GBest
    A = repmat(Swarm(g,:), SwarmSize, 1); %A = GBest. repmat(X, m, n) repeats the matrix X in m rows by n columns.
    %disp('--------------------------------------- A Matrix -------------------------------------------'); disp(A)
        
    % use neighborhood model
    % circular neighborhood is used
    B = A ;
    if pso_options.Flags.Neighbor
        for i = 1:SwarmSize
            NH=nhood(i,:);
            [NHr,NHc]=size(NH);
            for z=1:NHc
                fNH(z)=fSwarm(NH(z));
            end
            [fNBest(i),nb]=min(fNH);
            B(i,:)=Swarm(NH(1,nb),:); %-------------- %B wil be nBest (best neighbor) matrix
        end
    end
   %----------------------------------------------------------------------     
    % Generate Random Numbers  0< R1&R2 <1
    R1 = rand(SwarmSize, pso_options.Vars.Dim);
    R2 = rand(SwarmSize, pso_options.Vars.Dim);
    %--------------------------------------------------------------------

    % Calculate Velocity
    if ~pso_options.Flags.Neighbor %Normal
        VStep = w_now*VStep + pso_options.SParams.c1*R1.*(PBest-Swarm) + pso_options.SParams.c2*R2.*(A-Swarm);
        %disp('--------------------------------------- VStep-------------------------------------------------'); disp(VStep)
    else %With neighborhood
        R3 = rand(SwarmSize, pso_options.Vars.Dim); %random nos for neighborhood
        VStep = w_now*VStep + pso_options.SParams.c1*R1.*(PBest-Swarm) + pso_options.SParams.c2*R2.*(A-Swarm) + pso_options.SParams.c3*R3.*(B-Swarm);
    end
   
    % ################ apply constraint on Velocity  ###############
    
    KV=0.1;    % usually  0.1<=KV<=0.2
    Vmax=KV*(UB-LB);
    UBV=repmat(Vmax, SwarmSize, 1);
    
    % Apply Vmax Operator for v > Vmax
    changeRows = VStep > UBV;
    [r,c,v]=find(changeRows);
    [rr,rc]=size(r);
    for k=1:rr
        VStep(r(k,1),c(k,1))=UBV(r(k,1),c(k,1));
    end
    
    % Apply Vmax Operator for v < -Vmax
    changeRows = VStep < -UBV;
    [r,c,v]=find(changeRows);
    [rr,rc]=size(r);
    for k=1:rr
        VStep(r(k,1),c(k,1))=-UBV(r(k,1),c(k,1));
    end
    % VStep   % limited VStep

% ########################################################################    
    
    % ::UPDATE POSITIONS OF PARTICLES::
    Swarm = Swarm + pso_options.SParams.Chi * VStep;   % Evaluate new Swarm
    
  % #################### apply constraint on Swarm (EHSAN) ################
    
    UBtot=repmat(UB, SwarmSize, 1);
    LBtot=repmat(LB, SwarmSize, 1);
    
    % Apply UB Operator for Swarm > UB
    changeRows = Swarm > UBtot;
    [r,c,v]=find(changeRows);
    [rr,rc]=size(r);
    for k=1:rr
        Swarm(r(k,1),c(k,1))=UBtot(r(k,1),c(k,1));
    end
    
    % Apply LB Operator for Swarm < LB
    changeRows = Swarm < LBtot;
    [r,c,v]=find(changeRows);
    [rr,rc]=size(r);
    for k=1:rr
        Swarm(r(k,1),c(k,1))=LBtot(r(k,1),c(k,1));
    end

%     Swarm    % limited Swarm

% #########################################################################


  for j=1:SwarmSize
       fSwarm(j)=feval(f2eval,Swarm(j,:));
  end
%     fSwarm 
    
    %----------------------------------------------------
    fevals = fevals + SwarmSize;
    
    % Updating the best position for each particle
    changeRows = fSwarm < fPBest;
    fPBest(find(changeRows)) = fSwarm(find(changeRows));
%     fPBest
    %----------------EHSAN-------------------------------
    
    mean= sum(fPBest)/SwarmSize;   

    %----------------------------------------------------
    
    PBest(find(changeRows), :) = Swarm(find(changeRows), :);

    
    lastbpart = PBest(g, :);
  
    % Updating index g
    [fGBest, g] = min(fPBest);

    
    %Update Best. Only if fitness has improved.
    if fGBest < lastbpf
        [fBest, b] = min(fPBest);
        Best = PBest(b,:);
    end
    
    FFGBest(iter)=fGBest;
    Mean(iter)=mean;
     

    % ####################################################
    ehstot=0;
    for i=1:SwarmSize
       ehs=(fPBest(i)-mean)^2;
       ehstot=ehstot+ehs;
    end
    stdeviation=(ehstot/SwarmSize)^0.5;
    STdeviation(iter)=stdeviation;
    Elapsed_t = (cputime-tt)/60;  
    Elapsed_time(iter)=Elapsed_t;
    


   
    %######################################################
    
 
    
    %%OUTPUT%%
    if pso_options.Save.Interval && (rem(iter, pso_options.Save.Interval) == 0)
        history((size(history,1)+1), :) = [iter, fBest];
    end
    
    if pso_options.Disp.Interval && (rem(iter, pso_options.Disp.Interval) == 0)
        disp(sprintf('%4d\t\t\t%.5g\t\t\t%5d', iter, fGBest, fevals));
    end

    if pso_options.Flags.ShowViz
        [fworst, worst] = max(fGBest);
        DrawSwarm(Swarm, SwarmSize, iter, pso_options.Vars.Dim, Swarm(g,:), vizAxes)
    end
    
    %%TERMINATION%%
    if abs(fGBest-pso_options.Obj.GM) <= pso_options.Vars.ErrGoal     %GBest
        success = 1;
    elseif abs(fBest-pso_options.Obj.GM)<=pso_options.Vars.ErrGoal    %Best
        success = 1;
    else
        lastbpf = fGBest; %To be used to find Best
    end

    %%%%%%%%%%%%%%%%%  Plot  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    waitbar(iter / pso_options.Vars.Iterations)
%     figure (1)
%     set(0,'CurrentFigure',1);
%     plot(iter,mean,'.',iter,fGBest,'*r')
%     hold on
%     xlim([0 20])
%     xlabel('iteration')
%     ylabel('Fitness value')
%     legend('mean of fPBest','Best')
%     grid off
%     pause(0.001)
    

  
end
close(hwait)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%                  END  OF PSO  LOOP                       %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




[fxmin, b] = min(fPBest);
xmin = PBest(b, :);

Elapsed_time_sec = cputime-tt;
Elapsed_time_min = Elapsed_time_sec/60;
Elapsed_time_hour = Elapsed_time_min/60;

%==================================
% t=1;
% for i=1:length(xmin)/3
% 
%     IN(i,:)=xmin(t:t+2);
%     t=t+3;
% end
% IN(:,3)=round(IN(:,3));
% IN
% %==================================
%     savefile='PSO_results';
% save(savefile,'IN')
% 
history = history(:,1);
%Comment below line to Return Swarm. Uncomment to return previous best positions.
% Swarm = PBest; %Return PBest