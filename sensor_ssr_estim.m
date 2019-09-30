function fr=sensor_ssr_estim(inputdir,outputdir,subj,fileSuffix,timelim_eeg,spatfilt)

%% run SSR analyses - sensor weights

% read in EEGLAB .set file to gather some info on triggers
EEG=getfield(ft_read_header(sprintf('%s%s%s.set',inputdir,subj,fileSuffix)),'orig');
EEG.data=ft_read_data(sprintf('%s%s%s.set',inputdir,subj,fileSuffix));

% read in actual EEG data and convert to Fieldtrip-style data structure
data=eeglab2fieldtrip(EEG,'preprocessing');

% do some preprocessing & immediately convert to convenient format
cfg=[];
cfg.bpfilt='yes';
cfg.bpfreq=[.1 30];
cfg.reref='yes';
cfg.refchannel='all';
data=ft_timelockanalysis(struct('keeptrials','yes'),ft_preprocessing(cfg,data));

% keep triggers for trial identification
%data.trialinfo=[EEG.event.type].';
data.trialinfo=cell2mat({EEG.event.type}.');
% sometimes trial info is kept as chars instead of numbers, fix:
if ischar(data.trialinfo),data.trialinfo=str2num(data.trialinfo); end
cond=unique(data.trialinfo);
fprintf('\n### Dataset contains %d conditions!\n',numel(cond));

% add to the trialinfo a column of running indices for future ref
data.trialinfo(:,2)=1:EEG.trials;

fsample=EEG.srate; % keep sampling info

cfg=[];
cfg.latency=[timelim_eeg(1),timelim_eeg(2)-1/fsample];
data=ft_selectdata(cfg,data);

if strcmp(spatfilt.type,'scd')
    %%% convert to scalp current densities
    %data.elec=ft_convert_units(data.elec,'mm');
    data=ft_scalpcurrentdensity(spatfilt,data);
    %data.elec.unit='dm';
end

if strcmp(spatfilt.type,'ress')
    data=ress_apply(data,cond,spatfilt);
end

cfg=[];
cfg.method='mtmfft';
cfg.output='fourier';
cfg.taper='tukeywin'; % use cosine taper
cfg.pad=10; % pad to 10 seconds, i.e. spectral res of 0.1 Hz
cfg.polyremoval=1;
tmp=ft_freqanalysis(cfg,data);

tmp.dimord='chan_freq';

% separate data of different conditions
for icond=1:numel(cond)
    trlidx=tmp.trialinfo(:,1)==cond(icond);
    % "induced" power
    tmp.powspctrm=squeeze(mean(abs(tmp.fourierspctrm(trlidx,:,:)).^2));
    % "evoked" power - classical SSR
    tmp.evospctrm=squeeze(abs(mean(tmp.fourierspctrm(trlidx,:,:)).^2));
    % inter-trial phase coherence (phase-locking)
    tmp.itcspctrm=squeeze(abs(mean(tmp.fourierspctrm(trlidx,:,:)./abs(tmp.fourierspctrm(trlidx,:,:)),1)));
    % inter-trial linear coherence (...)
    
    %%% cosinus similarity index, see https://doi.org/10.1016/j.jneumeth.2017.12.007
    fspec=tmp.fourierspctrm(trlidx,:,:);
    ntrial=size(fspec,1);
    denom=2./(ntrial.*(ntrial-1));
    % step-by-step
    numer=zeros(size(fspec(1,:,:)));
    for itrial=1:(ntrial-1)
        for jtrial=(itrial+1):ntrial
            numer=numer+cos(diff(angle(fspec([itrial,jtrial],:,:))));
        end
    end
    tmp.cosspctrm=squeeze(numer).*denom;
    %%% cos end
    tmp.ntrial=ntrial;
    fr{icond}=rmfield(tmp,'fourierspctrm');
    % keep only cond-spec chanweights
    fr{icond}.elec.chanweights=tmp.elec.chanweights(:,icond);
end

clear tmp EEG

