restoredefaultpath, clearvars, clc

%% store data for reg / stim freq in csv's for further analyses in R

expid='pil2'; % 'pil1', 'pil2', 'exp1', 'exp2'
stimVar='hiVar'; % leave empty for pil1, choose 'hiVar' / 'loVar' othw
inputDir='/your_data_path/data/fr';
outputDir='/your_data_path/export2R/';
currentfile='/13-Mar-2019-'; %% use if data date-tagged or else

condidx=1:6;

switch expid
    case 'pil1'
    freqoi=5*[1,3];
    subvec=9:24; % 16 subjects
    subj=cellfun(@(x) sprintf('%s%02d','sub',x),num2cell(subvec),'UniformOutput',false);
    fileSuffix='-sensfft_tuk_ssr_ress_reg.mat';
    fileOutPre=sprintf('%s%s',outputDir,expid);
    case 'pil2'
    freqoi=5*[1,3];
    subvec=1:16; % 16 subjects
    subj=cellfun(@(x) sprintf('%s%02d','ss',x),num2cell(subvec),'UniformOutput',false);
    fileSuffix=['-sensfft_ress_' stimVar '.mat'];
    fileOutPre=sprintf('%s%s_%s',outputDir,expid,stimVar);
    case 'exp1'
    freqoi=2*[1,3];
    subvec=1:31; % 31 subjects
    subj=cellfun(@(x) sprintf('%s%02d','ss',x),num2cell(subvec),'UniformOutput',false);
    fileSuffix=['-sensfft_ress_' stimVar '.mat'];
    fileOutPre=sprintf('%s%s_%s',outputDir,expid,stimVar);
    case 'exp2'
    freqoi=2*[1,3];
    subvec=1:30; % 30 subjects
    subj=cellfun(@(x) sprintf('%s%02d','vpn',x),num2cell(subvec),'UniformOutput',false);
    fileSuffix=['-sensfft_ress_' stimVar '.mat'];
    fileOutPre=sprintf('%s%s_%s',outputDir,expid,stimVar);
end

chanSel=65; % chan ID of RESS component - optimal SSR weight
for isub=1:numel(subj)
    % for pilot 1
    if isempty(stimVar)
    load([inputDir,expid,currentfile,subj{isub},fileSuffix],'fr');
    % for all other exp
    else
    load([inputDir,expid,currentfile,'-sensfft_tuk_ssr_ress_' stimVar '.mat'],'fr')
    end
    % Note: These data are still in fieldtrip format. Hence standard
    % fieldtrip plotting functions can be used to plot scalp topographies
    % and spectra (see ft_topoplot.m, ft_singleplotER.m)
    
    % % conversions - use if not looking into cosine sim index
    % for icell=1:numel(fr)
    %     fr{icell}.logspctrm=10*log10(fr{icell}.evospctrm);
    %     fr{icell}.itczspctrm=fr{icell}.ntrial*fr{icell}.itcspctrm.^2;
    % end
    
    for icond=1:numel(fr)
        if isub+icond==2
            spec=zeros([numel(subj),numel(fr),numel(chanSel),size(fr{1}.cosspctrm,2)]);
        end
        spec(isub,icond,:)=fr{icond}.cosspctrm(chanSel,:);
    end
end

% pick data for freq of interest (and avg across chans if not RESS comp)
data=squeeze(mean(spec(:,:,:,dsearchn(fr{1}.freq.',freqoi(1))),3));

% set up design matrix
factlvl=[2 3];
nsub=size(data,1);
dsgn(:,1)=repmat(1:nsub,[1 size(data,2)]).';
dsgn(:,2)=sort(repmat((1:factlvl(1))',[numel(data)/factlvl(1) 1]));
dsgn(:,3)=repmat(sort(repmat((1:factlvl(2))',[numel(data)/prod(factlvl(1:2)) 1])),[factlvl(1) 1]);

% convert to table object
tablehd={'data','subj','face_dir','emo'};
fdata=table(data(:),dsgn(:,1),dsgn(:,2),dsgn(:,3),'VariableNames',tablehd);

% save as .csv
writetable(fdata,sprintf('%s_%dHz_cos.csv',fileOutPre,freqoi(1)));
