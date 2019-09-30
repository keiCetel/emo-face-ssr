function data=ress_apply(data,cond,sfs)
% sfs = spatial filter settings
% cond = conditions markers in the trialinfo field

% v1 - Jan 2019
% TO DO:
% - allow concatenating conditions for common spatial filter
% - output maps (weights) - improve

ncond=numel(cond);
nchan=numel(data.label);

%tmpTrial=[]; keepTrlInd=[]; weights=[];
tmpTrial=zeros(size(data.trial)-[0,nchan-1,0]);
weights =zeros(nchan,ncond);
for icond=1:ncond
    condTrl=data.trialinfo(:,1)==cond(icond);
    tmpdat=ft_selectdata(struct('trials',condTrl),data);
%    keepTrlInd=cat(1,keepTrlInd,data.trialinfo(condTrl,2));

    % RESS ##############################################################
    % a la Cohen & Gulbinaite (2017, NeuroImage)
    % https://doi.org/10.1016/j.neuroimage.2016.11.036
    % original code downloaded from mikexcohen.com (10.12.2017)
    
    % FFT parameters
    %tidx=dsearchn(tmpdat.time.',timelim_eeg.');
    tidx=[1,length(data.time)];
    fsample=round(1/diff(data.time([1,2]),[],2));
    
    % extract EEG data
    tsFFT = permute(tmpdat.trial,[2 3 1]);
    
    % compute covariance matrix at peak frequency
    fdatAt = filterFGx(tsFFT,fsample,sfs.peakfreq,sfs.peakwidt);
    fdatAt = reshape(fdatAt(:,tidx(1):tidx(2),:),nchan,[]);
    fdatAt = bsxfun(@minus,fdatAt,mean(fdatAt,2));
    covAt  = (fdatAt*fdatAt')/diff(tidx);
    
    % compute covariance matrix for lower neighbor
    fdatLo = filterFGx(tsFFT,fsample,sfs.peakfreq+sfs.neighfreq,sfs.neighwidt);
    fdatLo = reshape( fdatLo(:,tidx(1):tidx(2),:),nchan,[] );
    fdatLo = bsxfun(@minus,fdatLo,mean(fdatLo,2));
    covLo  = (fdatLo*fdatLo')/diff(tidx);
    
    % compute covariance matrix for upper neighbor
    fdatHi = filterFGx(tsFFT,fsample,sfs.peakfreq-sfs.neighfreq,sfs.neighwidt);
    fdatHi = reshape( fdatHi(:,tidx(1):tidx(2),:),nchan,[] );
    fdatHi = bsxfun(@minus,fdatHi,mean(fdatHi,2));
    covHi  = (fdatHi*fdatHi')/diff(tidx);
    
    % perform generalized eigendecomposition
    ncovm=(covHi+covLo)/2; % combined noise cov matrix
    lambda = sfs.regparam * trace(ncovm)/size(ncovm,1);
    % regularisation of noise covariance applied similar to
    % Gulbinaite et al. (2019, NeuroImage)
    % https://doi.org/10.1016/j.neuroimage.2019.116146
    
    % note: trace(cov) = sum(eig(cov))
    [evecs,evals] = eig(covAt,ncovm+lambda*eye(size(ncovm)));
    [~,comp2plot] = max(diag(evals)); % find maximum component
       
    % reconstruct RESS component time series
    sf_ts1 = zeros(size(tsFFT,2),size(tsFFT,3));
    for ti=1:size(tsFFT,3)
        sf_ts1(:,ti) = evecs(:,comp2plot)'*squeeze(tsFFT(:,:,ti));
    end
    tmpTrial(tmpdat.trialinfo(:,2),1,:)=permute(sf_ts1,[2,3,1]);
        
    %%%% this last bit is only for keeping the spatial filter + plot it
    % extract components and force sign
    maps = covAt * evecs / (evecs' * covAt * evecs);
    [~,idx] = max(abs(maps(:,comp2plot))); % find biggest component
    maps = maps * sign(maps(idx,comp2plot)); % force max to positive sign
    weights(:,icond)=maps(:,comp2plot);
    %################################################### END OF RESS #####
end

% re-package | FT friendly
data=rmfield(data,{'avg','var','dof'});
data.label{end+1}='RESS';
data.trial=cat(2,data.trial,tmpTrial);

% keep ress channel weights
data.elec.chanweights=weights;
