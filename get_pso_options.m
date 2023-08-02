function psoOptions = get_pso_options()
psoOptions = struct( ...
    ... %Option FLAGS
    'Flags', struct(...
    'ShowViz',          0, ...      %Show visualization of the particles
    'Neighbor',         0), ...     %Use neighborhood acceleration (in addition to global acceleration)
    ... %Variables of the PSO
    'Vars', struct(...    
    'SwarmSize',   100, ...     %Swarm Size
    'Iterations',  20,...    %Maximum Iterations 
    'ErrGoal',     1e-6, ...  %Error goal
    'Dim',         3), ...   %Dimensions of the problem   10 % Number of variables
    ...  %Stratergy Parameters
    'SParams', struct(... 
    'c1',       1.5, ...      %Cognitive Acceleration
    'c2',       1.5, ...      %Social Acceleration
    'c3',       1, ...      %Neighborhood Acceleration
    'w_start',  0.9, ...   %Value of velocity Weight at the begining
    'w_end',    0.4, ...    %Value of velocity Weight at the end of the pso iterations
    'w_varyfor',0.7,...     %The fraction of maximum iterations, for which w is linearly varied
    'Vmax',     0.2,...     %Maximum velocity step
    'Chi',      1, ...      %Constriction factor
    'Nhood',    0 ), ...    %Neighborhood size (nhood=1 ==> 2 neighbors, one on each side)
    ...  %Objective Function Options
    'Obj', struct(...    
    'f2eval',      'costfunction_temp2', ...%Function/System to optimize   %Ehsanpso
    'GM',           0, ...      %Value of Global Minima (Required if Error goal is a termination criteria).
    'lb',           [5,5,0], ...    %Lower bounds of Initialization 
    'ub',          [15,15,1]), ...  % , ...      %Upper bounds of Initialization
    ... %Termination Options
    'Terminate', struct(...
    'Iters',        1, ...      %Use Vars.MaxIt for termination
    'Err',          1), ...     %Use Vars.ErrGoal for termintion
    ... %Display Options
    'Disp', struct( ...
    'Interval',    10, ...     %Notify about the progress after these many iterations
    'Header',      0,  ...     %Display the PSO Options header. 0 = hide, 1 = show
    'Progress',    0,  ...     %Display the progress of the Algorithm. 0 = hide, 1 = show
    'Footer',      0 ),  ...   %Display Footer (contains experimental results). 0 = hide, 1 = show
    ... %Saving Options
    'Save', struct(...
    'File',        'Results', ...  %Base name of the Output Text File. (see options below for automation options)
    'IncludeFnName',    1, ...     %Prefix the name of the name of the Objective function to the file name e.g. DeJong_Results
    'IncludeDim',       1, ...     %Suffix the number of dimensions. DeJong_Results_10d
    'IncludeSwarmSize', 1, ...     %Suffix the size of swarm. DeJong_Results_10d20p
    'Interval',         10,...     %Save after this number of iterations
    'Header',           1, ...     %Save the header information (see Disp)
    'Footer',           1 ) , ...  %Save the Footer information (see Disp)
    ... %info: the PSO Toolbox can used to tune the membership functions of an FIS. Set the options below.
    ... %Fuzzy Options 
    'Fuzzy', struct( ...
    'FIS',          'tipper', ...       %FIS file that contains the system to be optimize. (note: The file should end with a .fis extension)
    'DataFile',     'tipperData', ...   %An Excel File containing Training Data. The FIS will be tuned to match this data.
    'InitFunc',     @initfuzzy, ...     %A function to initialize the Swarm using the FIS
    'ValidateFunc', @validatefuzzy, ... %A function to Validate the Swarm each time particles are moved. This is required to change the co-ordinates of the particles which have bad value of membership function parameters.
    'ErrorFunc',    @fuzEvalFitness,... %A function to evaluate the fitness of the fuzzy system. (note: Fitness is expressed in terms of mean square error. So, more fit functions would return a lower value of error)
    'TuneInputs',    1, ...             %Tune the input membership functions
    'TuneOutputs',   1) ...             %Tune the output membership functions
    );