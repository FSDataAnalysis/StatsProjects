%%% Choose Folder with Images 
% fPath = uigetdir('.', 'Select directory containing the files');
% if fPath==0, error('no folder selected'), end
% fNames = dir(fullfile(fPath,'*.txt') );
% fNames = strcat(fPath, filesep, {fNames.name});


Remove_outliers_on=1;

%%% Prepare vectors, structures, etc. 
% GetMydata_DMIN;

values_ag={ddm_clean_ag, distance_dWA_ag, height_dWA_ag}; 
values_an={ddm_clean_an, distance_dWA_an, height_dWA_an}; 

labels={'ddm', 'dAW', 'dAH'};
Diff_mean=struct;
Diff_std=struct;
Diff_data=struct;
Diff_z=struct;

Diff_conf_int_min=struct;
Diff_conf_int_max=struct;

how_many=length(values_ag);

for ccc=1:how_many
    
    values_in_ag=values_ag{ccc};
    values_in_an=values_an{ccc};
    
    [result_old, result_new, flag0]=GetDoneTriple(values_in_ag, values_in_an, Remove_outliers_on);
       
    Mydata=[];
    Mydata(:,1)=result_old;
    Mydata(:,2)=result_new;
    %% Data cointained in Matrix Mydata 
    %%(for now one file only, to be updated to many)

    % Mydata=load(fNames{1})

    N=length(Mydata(:,1));

    %%% calculate differences (this should be normally distributed presumably)
    %%% Large would be row 1 and Small row 2. %%%%%%%%%% Pair-wise 
    D_indexed=Mydata(:,1)-Mydata(:,2);
    D=mean(D_indexed);
    mu_D=std(D_indexed);


    %%% verify the distribution shape

    %% Normalize 

    D_n_indexed=(D_indexed-D)/mu_D;

    figure(1000);
    histfit(D_n_indexed, 10, 'normal');
    figure(1001);
    boxplot(D_n_indexed);
    %%% Confidence Interval for 99% (p-value of 0.005)
    %% (Minimum_dFA, Maximum_dFA)

    Minimum_dFA=D-2.58*mu_D/sqrt(N);
    Maximum_dFA=D+2.58*mu_D/sqrt(N);


    %% Test at alfa=0.005 (two sided)



    %% Hypothesis

    %%% Null Hypothesis is H0: mu_D=0 versus H1: mu_D > 0
    %% Rejection of NULL HYPOTHESIS Z >= z_0_005=2.58 
    %% (for 99% alfa=0.005 )  two-sided)

    %% N distribution (from the central-limit theorem applied to the difference D):
    %% test statistic is z

    z=D/mu_D*sqrt(N);

    %%%% In R-R studio
    %%%% pnorm(z)= ZZ
    %%%% p_value=1-ZZ
    
    
    %%%%%% Save structures %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    foo=labels{ccc};
    Diff_mean.(foo)=D;
    Diff_data.(foo)=D_indexed;
    Diff_std.(foo)=mu_D;
    Diff_z.(foo)=z;
    Diff_conf_int_min.(foo)=Minimum_dFA;
    Diff_conf_int_max.(foo)=Maximum_dFA;

end

save mydata;

