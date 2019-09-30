restoredefaultpath, clearvars, clc

addpath('/your_fieldtrip_path');
ft_defaults
% make eeglab2fieldtrip available
addpath('/your_fieldtrip_path/external/eeglab')
% other aux funs
addpath('/your_auxfun_path')

%% pilot 1

inputdir  = '/your_data_path/data/pilot1/';
outputdir = '/your_data_path/data/frpil1/';

% subj id for filenames
subvec=9:24; % 16 subjects
subj=cellfun(@(x) sprintf('%s%02d','sub',x),num2cell(subvec),'UniformOutput',false);
fileSuffix='_elist_be_artrej';

% time window for data analyses
timelim_eeg=[.5 3.5];

spatfilt.type = 'ress'; % support for RESS and scd
%%% RESS parameters
spatfilt.peakfreq=5; % signal peak frequency
spatfilt.peakwidt=.5; % signal band width
spatfilt.neighfreq=1; % noise peak distance from signal peak
spatfilt.neighwidt=.5; % noise band width
spatfilt.regparam =.01; % noise cov regularisation

%%% scd parameters
% spatfilt.method='spline';
% spatfilt.lambda=1e-05;
% spatfilt.conductivity=0.33/1000;

for isub=1:numel(subj)
    fr=sensor_ssr_estim(inputdir,outputdir,subj{isub},...
                         fileSuffix,timelim_eeg,spatfilt);
    save([outputdir,date,'-',subj{isub},'-sensfft_tuk_ssr_ress_reg.mat'],'fr');
end

%% pilot 2

inputdir  = '/your_data_path/data/pilot2/';
outputdir = '/your_data_path/data/frpil2/';

% subj id for filenames
subvec=1:16; % 30 subjects
subj=cellfun(@(x) sprintf('%s%02d','ss',x),num2cell(subvec),'UniformOutput',false);

% time window for data analyses
timelim_eeg=[.5 3.5];

spatfilt.type = 'ress'; % support for RESS and scd
%%% RESS parameters
spatfilt.peakfreq=5; % signal peak frequency
spatfilt.peakwidt=.5; % signal band width
spatfilt.neighfreq=1; % noise peak distance from signal peak
spatfilt.neighwidt=.5; % noise band width
spatfilt.regparam =.01; % noise cov regularisation

% separate processing of high- and low var conditions
fileSuffix='_elist_be_artrej_highVar';
for isub=1:numel(subj)
    fr=sensor_ssr_estim(inputdir,outputdir,subj{isub},...
                        fileSuffix,timelim_eeg,spatfilt);
    save([outputdir,date,'-',subj{isub},'-sensfft_ress_hiVar.mat'],'fr');
end

fileSuffix='_elist_be_artrej_lowVar';
for isub=1:numel(subj)
    fr=sensor_ssr_estim(inputdir,outputdir,subj{isub},...
                        fileSuffix,timelim_eeg,spatfilt);
    save([outputdir,date,'-',subj{isub},'-sensfft_ress_loVar.mat'],'fr');
end

%% experiment 1
inputdir  = '/your_data_path/data/experiment1/';
outputdir = '/your_data_path/data/frexp1/';

% subj id for filenames
subvec=1:31; % 31 subjects
subj=cellfun(@(x) sprintf('%s%02d','ss',x),num2cell(subvec),'UniformOutput',false);

% time window for data analyses
timelim_eeg=[.5 7];

spatfilt.type = 'ress'; % support for RESS and scd
%%% RESS parameters
spatfilt.peakfreq=2; % signal peak frequency
spatfilt.peakwidt=.5; % signal band width
spatfilt.neighfreq=1; % noise peak distance from signal peak
spatfilt.neighwidt=.5; % noise band width
spatfilt.regparam =.01; % noise cov regularisation

fileSuffix='_elist_be_artrej_highVar';
for isub=1:numel(subj)
    fr=sensor_ssr_estim(inputdir,outputdir,subj{isub},...
                        fileSuffix,timelim_eeg,spatfilt);
    save([outputdir,date,'-',subj{isub},'-sensfft_ress_hiVar.mat'],'fr');
end

fileSuffix='_elist_be_artrej_lowVar';
for isub=1:numel(subj)
    fr=sensor_ssr_estim(inputdir,outputdir,subj{isub},...
                        fileSuffix,timelim_eeg,spatfilt);
    save([outputdir,date,'-',subj{isub},'-sensfft_ress_loVar.mat'],'fr');
end

%% experiment 2
inputdir  = '/your_data_path/data/experiment2/';
outputdir = '/your_data_path/data/frexp2/';

% subj id for filenames
subvec=1:30; % 30 subjects
subj=cellfun(@(x) sprintf('%s%02d','vpn',x),num2cell(subvec),'UniformOutput',false);

% time window for data analyses
timelim_eeg=[.5 7];

spatfilt.type = 'ress'; % support for RESS and scd
%%% RESS parameters
spatfilt.peakfreq=2; % signal peak frequency
spatfilt.peakwidt=.5; % signal band width
spatfilt.neighfreq=1; % noise peak distance from signal peak
spatfilt.neighwidt=.5; % noise band width
spatfilt.regparam =.01; % noise cov regularisation

fileSuffix='_elist_be_artrej_highVar';
for isub=1:numel(subj)
    fr=sensor_ssr_estim(inputdir,outputdir,subj{isub},...
                        fileSuffix,timelim_eeg,spatfilt);
    save([outputdir,date,'-',subj{isub},'-sensfft_ress_hiVar.mat'],'fr');
end

fileSuffix='_elist_be_artrej_lowVar';
for isub=1:numel(subj)
    fr=sensor_ssr_estim(inputdir,outputdir,subj{isub},...
                        fileSuffix,timelim_eeg,spatfilt);
    save([outputdir,date,'-',subj{isub},'-sensfft_ress_loVar.mat'],'fr');
end
