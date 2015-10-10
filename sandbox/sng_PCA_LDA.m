% function sng_PCA_LDA()
% looking for directions along which to segregate responses from combo rods
% clear

expts = {'ttm1_30C',...
    'wt_ames_30C',...
    'ttm4rhohet_30C',...
    };
%'ttm1_30C',...
%'ttm4rhohet_30C',...
%'wt_ames_30C',...

% Get all the data, need time, too
for s=1:length(expts)
    expt = expts{s};
    
    ind = regexp(expt,'_');
    gen = expt(1:ind(1)-1);
    
    datafolder = sprintf('~/Analysis/Ovation-index/%s/%s/data/',gen,expt);
    cd(datafolder)
    
    a = dir;
    c = 0;
    files = {};
    cells = {};
    for i = 1:length(a);
        if ~isempty(strfind(a(i).name,'frstsng'))
            c = c+1;
            files{c} = a(i).name;
            ind = regexp(a(i).name,'_');
            cells{c} = a(i).name(1:ind-1);
        end
    end
    
    epochs = 0;
    tlims = [-inf, inf];
    tpnts = inf;
    for c = 1:length(cells)
        data = load(files{c},'data');
        data = data.data;
        epochs = epochs+size(data,1);
        t = load(sprintf('%s_time',cells{c}),'data');
        t = t.data;
        tlims = [max(t(1),tlims(1)),min(t(end),tlims(end))];
        tpnts = min(length(t),tpnts);
    end
    
    exptdata = zeros(epochs,sum(t>=tlims(1) & t<=tlims(end)));
    normexptdata = zeros(epochs,sum(t>=tlims(1) & t<=tlims(end)));
    start = 0;
    for c = 1:length(cells)
        data = load(files{c},'data');
        data = data.data;
        t = load(sprintf('%s_time',cells{c}),'data');
        t = t.data;
        
        exptdata(start+1:start+size(data,1),:) = data(:,t>=tlims(1) & t<=tlims(end));
        
        % normalize cells
        data = data/max(mean(data,1));
        normexptdata(start+1:start+size(data,1),:) = data(:,t>=tlims(1) & t<=tlims(end));
        
        cellintervals.(expt)(c,:) = [start+1,start+size(data,1)];
        start = start+size(data,1);
    end
    time = t(t>=tlims(1) & t<=tlims(end));
    
    exptdata = basetimeSubtract(exptdata,time);
    normexptdata = basetimeSubtract(exptdata,time);
    
    singlescollection.(expt) = exptdata;
    normsinglescollection.(expt) = normexptdata;
    timecollection.(expt) = time;
end
 

%% Get individual ttmrho cells for fitting with p*ttm and (1-p)*rho

expt = 'ttm4rhohet_30C';

ind = regexp(expt,'_');
gen = expt(1:ind(1)-1);

datafolder = sprintf('~/Analysis/Ovation-index/%s/%s/data/',gen,expt);
cd(datafolder)

a = dir;
c = 0;
files = {};
cells = {};
for i = 1:length(a);
    if ~isempty(strfind(a(i).name,'frstsng'))
        c = c+1;
        files{c} = a(i).name;
        ind = regexp(a(i).name,'_');
        cells{c} = a(i).name(1:ind-1);
    end
end

combocelldata = java.util.HashMap;
combocellnormdata = java.util.HashMap;
for c = 1:length(cells)
    data = load(files{c},'data');
    data = data.data;
    t = load(sprintf('%s_time',cells{c}),'data');
    t = t.data;
    
    data = basetimeSubtract(data,t);
    data = data(:,t>=0 & t<=1.8);
    
    combocelldata.put(cells{c},data);
    
    data = data/max(mean(data,1));
    combocellnormdata.put(cells{c},data);
end


%%
toothdist = 1;

wtdata = normsinglescollection.('wt_ames_30C')';
time = timecollection.('wt_ames_30C');    
comb = time;
comb = mod(round(comb*1000),toothdist)==0;
wtdata = wtdata(time>=0&comb & time<=1.8,:);

ttmdata = normsinglescollection.('ttm1_30C')';
time = timecollection.('ttm1_30C');    
comb = time;
comb = mod(round(comb*1000),toothdist)==0;
ttmdata = ttmdata(time>=0&comb & time<=1.8,:);

%% PCA
n(1) = size(wtdata,2);
n(2) = size(ttmdata,2);

R = [wtdata ttmdata];
Rmean = mean(R,2);
R = bsxfun(@minus,R,mean(R,2));

[U,sigma,V] = svd(R,0); 


%% % project the responses into a lower dimensional space that captures 99%
% of the energy.  the projections are then a D x N matrix in the space
% spaned by the orthonormal column vectors of U (the operation performed by
% U'M).

% M = U sig V';
% U'M = U'U sig V';
% U'M = sig V';

AX = sigma*V';

variances = diag(sigma).^2;
energyfrac = cumsum(variances)/sum(variances);

negligE = -2:.5:-1;
negligE = -3:.5:-1;
negligE = 10.^negligE;

efracs = fliplr(1-negligE);
%efracs = .99;
for j = 1:length(efracs)
    clear m
    efrac = efracs(j);
    fprintf('Using %g of Energy\n',efrac);
    D = find(energyfrac<efrac,1,'last');
    
    proj = AX(1:D,:);
    
    % LDA
    % Fisher criterion: J(w) = (m2proj-m1proj)^2/(S1^2 + S2^2) where
    % S = <w'x - m>
    % or J(w) = w'*Sb*w/w'*Sw*w
    wtproj = proj(:,1:n(1));
    ttmproj = proj(:,n(1)+1:end);
    
    m(:,1) = mean(wtproj,2);
    m(:,2) = mean(ttmproj,2);
    
    % Sb is the between class scatter matrix
    % multiply distance from m1 to m2 by itself;
    Sb = (m(:,2) - m(:,1))*(m(:,2) - m(:,1))';
    
    [dim N] = size(proj);
    
    % Sw is the within class scatter matrix
    Sw = zeros(dim);
    for i = 1:N
        if i <= n(1);
            new = (proj(:,i)-m(:,1))*(proj(:,i)-m(:,1))';
        else
            new = (proj(:,i)-m(:,2))*(proj(:,i)-m(:,2))';
        end
        Sw = Sw + new;
    end
    
    % solve generalized eigenvalue
    % problem Sb*w = lambda*Sw*w
    SwI = pinv(Sw);
    S = SwI*Sb;
    [Unew,sigmanew,Vnew] = svd(S,0);
    w = Unew(:,1);
    w2 = Unew(:,2);
    
    fprintf('Top two eigenvalues: %e, %e\n',sigmanew(1,1),sigmanew(2,2));
    
    % project the pca components onto w
    % w now represents the linear combination of orthonormal vectors in U that
    % puts the means of wt and ttm projections along w as far apart as
    % possible.
    
    wtwproj  = w'*wtproj;
    ttmwproj = w'*ttmproj;
    wtyproj  = w2'*wtproj;
    ttmyproj = w2'*ttmproj;
    
    % calculate a threshold along w
    alphac = (mean(wtwproj)+mean(ttmwproj))/2;
    
    
    % Estimate WT distr
    
    Pwt = fitdist(wtwproj','logistic');
    [h,p,stats] = chi2gof(wtwproj,'cdf',Pwt);
    [h,p,stats] = kstest(wtwproj,Pwt);
    fprintf('WT distribution is different: %d, %.3f\n',h,p);
    
    
    % Estimate TTM distr
    
    Pttm = fitdist(ttmwproj','normal');
    [h,p,stats] = chi2gof(ttmwproj,'cdf',Pttm);
    [h,p,k,c] = kstest(ttmwproj,Pttm);
    fprintf('TTM distribution is different: %d, %.3f\n',h,p);
    
    % Calculate a bayes error?
    BEfun = @(x) (Pwt.cdf(x)+(1-Pttm.cdf(x)))/2;
    bthresh = fminsearch(BEfun,alphac);
    be(j) = BEfun(bthresh);
end

%% now try the same projections with ttmrho

ttmrhodata = normsinglescollection.('ttm4rhohet_30C')';
time = timecollection.('ttm4rhohet_30C');    
comb = time;
comb = mod(round(comb*1000),toothdist)==0;
ttmrhodata = ttmrhodata(time>=0&comb & time<=1.8,:);

% subtract off the same mean as for the WT and TTM data
ttmrhodata_resid = bsxfun(@minus,ttmrhodata,Rmean);

ttmrhoproj = U'*ttmrhodata_resid;

ttmrhoproj = ttmrhoproj(1:D,:);

ttmrhowproj = w'*ttmrhoproj;
ttmrhoyproj = w2'*ttmrhoproj;

%% cummulative distributions
d1x = sort(ttmwproj);
d1y = (1:length(d1x))/length(d1x);

d2x = sort(wtwproj);
d2y = (1:length(d2x))/length(d2x);

d3x = sort(ttmrhowproj);
d3y = (1:length(d3x))/length(d3x);

d1_95 = d1x(find(d1y>.95,1));
d2_5 = d2x(find(d2y>=.05,1));

%%  Estimate mixture
comboprojpdf = @(x,p)...
    (p*Pwt.pdf(x) +...
    (1-p)*Pttm.pdf(x));
comboprojcdf = @(x,p)...
    (p*Pwt.cdf(x) +...
    (1-p)*Pttm.cdf(x));
start = .45;

[comboprojp,comboprojpci] = mle(ttmrhowproj,...
    'pdf',comboprojpdf,'cdf',comboprojcdf,'start',start);

[h,p,k,c] = kstest(ttmrhowproj,[d3x',comboprojcdf(d3x',comboprojp)])


%% plot the distributions and average responses
figure(1)
clf

% plot the distribution along w
ax = subplot(2,2,1);
set(ax,'tag','pdfs')
hold on
[bins,deltax] = subOptimalBinWidth(wtwproj);
[n,bins] = hist(wtwproj,subOptimalBinWidth(wtwproj));
n = n/length(wtwproj)/deltax;
% b1 = bar(bins,n,'b');
% set(b1,'barwidth',1,'edgecolor',[0 0 1],'displayname','wtpdf');
% set(get(b1,'children'),'facealpha',.5,'edgealpha',.5);
b1 = stairs(bins-deltax/2,n, 'Color',[0 0 1]); 
plot(sort(wtwproj),Pwt.pdf(sort(wtwproj)),'b','displayname','wtpdffit');
set(b1,'displayname','wtpdf');

[bins,deltax] = subOptimalBinWidth(ttmwproj);
[n,bins] = hist(ttmwproj,subOptimalBinWidth(ttmwproj));
n = n/length(ttmwproj)/deltax;
% b2 = bar(bins,n,'r');
% set(b2,'barwidth',1,'edgecolor',[1 0 0],'displayname','ttmpdf');
% set(get(b2,'children'),'facealpha',.5,'edgealpha',.5);
b2 = stairs(bins-deltax/2,n, 'Color',[1 0 0]);
plot(sort(ttmwproj),Pttm.pdf(sort(ttmwproj)),'r','displayname','ttmpdffit');
set(b2,'displayname','ttmpdf');

[bins,deltax] = subOptimalBinWidth(ttmrhowproj);
[n,bins] = hist(ttmrhowproj,bins);
n = n/length(ttmrhowproj)/deltax;
stairs(bins-deltax/2,n, 'Color',[.4 .4 .4],'displayname','combopdf'); hold on
plot(sort(ttmrhowproj),comboprojpdf(sort(ttmrhowproj),comboprojp),'k','displayname','ttmrhopdffit');
axis tight

%set(gca,'Xlim',get(subplot(2,2,1),'Xlim'));
plot([d1_95 d1_95],get(gca,'ylim'),'b--','DisplayName','ttm95');
plot([d2_5 d2_5],get(gca,'ylim'),'r--','DisplayName','wt05');


% plot the cdfs along w
ax = subplot(2,2,3);
set(ax,'tag','cdfs')
hold on
% plot(wtwproj,wtyproj,'+b')
% plot(ttmwproj,ttmyproj,'+r')
% plot(ttmrhowproj,ttmrhoyproj,'+k')
% plot([alphac alphac],get(gca,'Ylim'),'--','Color',[.8 .8 .8]);
plot(d1x,d1y,'r','displayname','ttmcdf');
plot(d1x,Pttm.cdf(d1x),'b','displayname','ttmfit');
plot(d2x,d2y,'b','displayname','wtcdf');
plot(d2x,Pwt.cdf(d2x),'b','displayname','wtfit');
plot(d3x,d3y,'k','displayname','ttmrhocdf');
plot(d3x,comboprojcdf(d3x,comboprojp),'b','displayname','combofit');

plot([d1_95 d1_95],get(gca,'ylim'),'b--','DisplayName','ttm95');
plot([d2_5 d2_5],get(gca,'ylim'),'r--','DisplayName','wt05');
plot([alphac alphac],get(gca,'ylim'),'--','Color',[1 1 1]*.7,'DisplayName','alphac');
set(gca,'Xlim',get(subplot(2,2,1),'Xlim'));

% wt like
ax = subplot(2,2,2);
set(ax,'tag','wt_like')
hold on
%plot(mean(ttmdata(:,ttmwproj>alphac),2),'Color',[1 .8 .8],'DisplayName','ttm pos proj');
%plot(mean(ttmrhodata(:,circshift(ttmrhowproj',1)>alphac),2),'k--','DisplayName','Pos proj shifted');
wtd1tail = mean(wtdata(:,wtwproj>d1_95),2);
ttmrhod1tail = mean(ttmrhodata(:,ttmrhowproj>d1_95),2);

plot(wtd1tail/max(wtd1tail),'b','DisplayName','defwt');
plot(ttmrhod1tail/max(ttmrhod1tail),'k','DisplayName','combodefwt');
plot(get(gca,'xlim'),[0 0],'--','Color',[1 1 1]*.8,'DisplayName','base');

%legend show

% ttm like
ax = subplot(2,2,4);
set(ax,'tag','ttm_like')
hold on
ttmd2tail = mean(ttmdata(:,ttmwproj<d2_5),2);
ttmrhod2tail = mean(ttmrhodata(:,ttmrhowproj<d2_5),2);
% plot(mean(wtdata(:,wtwproj<=alphac),2),'Color',[.8 .8 1],'DisplayName','wt pos proj');
% plot(mean(ttmrhodata(:,circshift(ttmrhowproj',1)<=alphac),2),'k--','DisplayName','Neg proj shifted');
plot(ttmd2tail/max(ttmd2tail),'r','DisplayName','defttm');
plot(ttmrhod2tail/max(ttmrhod2tail),'k','DisplayName','combodefttm');
plot(get(gca,'xlim'),[0 0],'--','Color',[1 1 1]*.8,'DisplayName','base');

%legend show

%%  Store the numbers associated with ttm like epochs
ttm1_ttm_like = find(ttmwproj<d2_5);
ttm4rhohet_ttm_like = find(ttmrhowproj<d2_5);

for s = [1 3];
    expt = expts{s};
    ind = regexp(expt,'_');
    gen = expt(1:ind(1)-1);
    datafolder = sprintf('~/Analysis/Ovation-index/%s/%s/data/',gen,expt);
    cd(datafolder)
    a = dir;
    c = 0;
    files = {};
    cells = {};
    eval(sprintf('tl = %s_ttm_like',gen));
    for i = 1:length(a);
        if ~isempty(strfind(a(i).name,'frstsng'))
            c = c+1;
            files{c} = a(i).name;
            ind = regexp(a(i).name,'_');
            cells{c} = a(i).name(1:ind-1);
        end
    end
    for c = 1:length(cells)
        nums = tl(...
            tl>=cellintervals.(expt)(c,1) ...
            & tl<=cellintervals.(expt)(c,2));
        nums = nums-(cellintervals.(expt)(c,1)-1);
        eval(sprintf('save %s_%s nums',cells{c},'ttm_likesngs'));
    end
end

%% How good is the classification of the TTM/rhos?  How likely is the error
% you get between pure strain and actual classifications, given the errors
% between pure strain responses and averages of permuted classifications?

% ***** Expensive computation ******

% wtresp = mean(wtdata(:,wtwproj>alphac),2);
% ttmresp = mean(ttmdata(:,ttmwproj<=alphac),2);
% 
% ttm_resp = mean(ttmrhodata(:,ttmrhowproj<=alphac),2);
% rho_resp = mean(ttmrhodata(:,ttmrhowproj>alphac),2);
% 
% TTM_mse = mean((ttmresp-ttm_resp).^2);
% WT_mse = mean((wtresp-rho_resp).^2);
% 
% simN = 10000;
% 
% ttmmse = zeros(simN,1);
% wtmse = ttmmse;
% 
% rightofthd = ttmrhowproj<=alphac;
% for i = 1:simN;
%     rindx = randperm(length(rightofthd));
%     
%     permutedwtresp = mean(ttmrhodata(:,rightofthd(rindx)),2);
%     permutedttmresp = mean(ttmrhodata(:,~rightofthd(rindx)),2);
%     
%     ttmmse(i) = mean((ttmresp-permutedttmresp).^2);
%     wtmse(i) = mean((wtresp-permutedwtresp).^2);
% end

% Plot shuffling statistics
% figure(4)
% subplot(1,2,1)
% [n,bins] = hist(ttmmse,subOptimalBinWidth(ttmmse));
% n = n/sum(n)/(bins(2)-bins(1));
% b1 = bar(bins,n,'r');
% set(b1,'barwidth',1,'edgecolor',[1 0 0]);
% % [mu, sig] = normfit(ttmmse);
% % hold on
% % plot(sort(ttmmse),normpdf(sort(ttmmse),mu,sig),'k');
% 
% line([TTM_mse TTM_mse], get(gca,'Ylim'),...
%     'Linestyle','--',...
%     'Color',[.6 .6 .6],...
%     'DisplayName',sprintf('p < %d/%d',1+sum(ttmmse<TTM_mse),simN));
% legend show
% 
% subplot(1,2,2)
% [n,bins] = hist(wtmse,subOptimalBinWidth(wtmse));
% n = n/sum(n)/(bins(2)-bins(1));
% b2 = bar(bins,n,'b');
% set(b2,'barwidth',1,'edgecolor',[0 0 1]);
% % [mu, sig] = normfit(wtmse);
% % hold on
% % plot(sort(wtmse),normpdf(sort(wtmse),mu,sig),'k');
% 
% line([WT_mse WT_mse], get(gca,'Ylim'),...
%     'Linestyle','--',...
%     'Color',[.6 .6 .6],...
%     'DisplayName',sprintf('p < %d/%d',1+sum(wtmse<WT_mse),simN));
% legend show


%%  What is w?  
% The orignal responses (N vectors) have been projected into the D
% dimensional column space of U(:,1:D) through U'*M (D x N).  They were
% then projected onto the unit vector w.  Another way to look at this is
% R acting on a column vector of V (vi) is U*sigma * vi' such that the
% directions of maximal variance are stretched (sigma) and rotated(U).  
% We can think of w as the coeficients for the linear combination of
% stretched basis vectors U*sigma (


% Each original response is represented by a point (D-dim vector) in space
% spanned by vi.  The points in {vi} form a round cloud, and the
% eigenvalues stretch that round cloud along vi into the column space of
% sigma*V'.  There is also a direction (w) that separates the two
% populations comprising R in {v1}.  w is one vector in an orthonormal
% space that would 

basis = U*sigma;
basis = basis(:,1:D);
optbasis = basis*w;

rightofthd = ttmrhowproj>alphac;

figure(2)
clf
ax = subplot(2,2,1); set(ax,'tag','leftproj'), hold on
% plot(ttmrhodata_resid(:,~rightofthd),'Color',[.8 .8 .8]);
plot(optbasis/mean(ttmrhowproj(~rightofthd)),'b','Linewidth',1);
title('Negative projection values')

ax = subplot(2,2,3); set(ax,'tag','rightproj'), hold on
% plot(ttmrhodata_resid(:,rightofthd),'Color',[.8 .8 .8]);
plot(optbasis/mean(ttmrhowproj(rightofthd)),'b','Linewidth',1);
title('Positive projection values')

% subplot(2,2,2), hold on
% for i = D:-1:1
%     plot(basis(:,i)*w(i),'Color',[1 1 1]*(i-1)/D)
% end

% subplot(2,2,4), hold on
% plot(optbasis/mean(ttmrhowproj(rightofthd))+Rmean,'b','Linewidth',1);
% plot(Rmean,'k','Linewidth',1);

%% PCA clusters
% TTM appeared clustered.  Using this protocol was able to determine that
% zeros had been initially included
figure(3), clf

[idx,c] = kmeans(ttmproj',2);

for i = 1:2
subplot(2,2,1)
hold on
plot(ttmwproj(idx==i),ttmyproj(idx==i),'+','Color',[.5 0 0] + [.5 0 0]*(i-1)/3)
subplot(2,2,i+1)
hold on
plot(ttmdata(:,idx==i),'Color',([.5 0 0] + [.5 0 0]*(i-1)/3)+[0 1 1]*.8)
plot(mean(ttmdata(:,idx==i),2),'Color',([.5 0 0] + [.5 0 0]*(i-1)/3),'Linewidth',2)
end

%% Load response durations

cdrs = 0;
celldrs = {};
cellnames = {};
exptnames = {};
for s=1:length(expts)
    expt = expts{s};
    ind = regexp(expts{s},'_');
    gen = expt(1:ind(1)-1);
    mp = load(sprintf('~/Analysis/Ovation-index/%s/%s/data/responseDurMap.mat',gen,expt));
    
    mp = mp.rspdrmp;
    
    cells = cell(mp.keySet.toArray);
%     if s == 3
%         a = strfind(cells,'083011');
%         for k = 1:length(a)
%             l(k) = isempty(a{k})
%         end
%         cells = cells(logical(l));
%     end
    durs = [];
    for c = 1:length(cells)
        drs = mp.get(cells{c});
        % durs = [durs;nanmean(drs(:,2:end),2)]; % use means
        durs = [durs;min(drs(:,2:end),[],2)]; % use mins
        cdrs = cdrs+1;
        celldrs{cdrs} = mean(drs(:,2:end),2);
        cellnames{cdrs} = cells{c};
        exptnames{cdrs} = expt;
    end
    rspdrs.(expt) = durs;
    celldstr.(expt) = celldrs;
end


%% Combo distributions (Gamma)  Do logarithmic display

% Parameterize the distributions
figure(6)
clf
ax = subplot(2,2,1);
set(ax,'tag','combo_distr','xscale','log','ylim',[-.1 1.1]);
hold on

ttmrhox = sort(rspdrs.ttm4rhohet_30C);
ttmrhoy = (1:length(ttmrhox))/length(ttmrhox);

plot(ttmrhox,ttmrhoy,'o','color',[.8 .8 .8]);

wtx = sort(rspdrs.wt_ames_30C);
wty = (1:length(wtx))/length(wtx);
wthat = gamfit(wtx);

[wthat2,wthat2ci] = mle(wtx,'pdf',@slidegampdf,'cdf',@slidegamcdf,'start',[min(wtx),wthat]);

hold on
plot(wtx,wty,'o','color',[.8 .8 1]);
plot(wtx,slidegamcdf(wtx,wthat2(1),wthat2(2),wthat2(3)),'color',[0 0 1],'displayname','wt_gamcdf');
text(10,.55,sprintf('(%.3f, %.3f, %.3f)',wthat2),'Color',[0 0 1]);

ttmx = sort(rspdrs.ttm1_30C);
ttmy = (1:length(ttmx))/length(ttmx);
ttmhat = gamfit(ttmx);

[ttmhat2,ttmhat2ci] = mle(ttmx,'pdf',@slidegampdf,'cdf',@slidegamcdf,'start',[min(ttmx),ttmhat]);

hold on
plot(ttmx,ttmy,'o','color',[1 .8 .8]);
plot(ttmx,slidegamcdf(ttmx,ttmhat2(1),ttmhat2(2),ttmhat2(3)),'color',[1 0 0],'displayname','ttm_gamcdf');
text(10,.45,sprintf('(%.3f, %.3f, %.3f)',ttmhat2),'Color',[1 0 0]);


combo1 = @(p,x)...
    (p*slidegampdf(x,wthat2(1),wthat2(2),wthat2(3)) +...
    (1-p)*slidegampdf(x,ttmhat2(1),ttmhat2(2),ttmhat2(3)));
combo1cdf = @(p,x)...
    (p*slidegamcdf(x,wthat2(1),wthat2(2),wthat2(3)) +...
    (1-p)*slidegamcdf(x,ttmhat2(1),ttmhat2(2),ttmhat2(3)));

p = (0:.001:1);
likelihood = p;
for i = 1:length(p)
    % likelihood(i) = sum(log(combo1(p(i),ttmrhox)))/length(ttmrhox);
    likelihood(i) = prod(combo1(p(i),ttmrhox));
end

likelihood = likelihood/trapz(p,likelihood);
trapz(p,likelihood);

p_mle = p(likelihood==max(likelihood));
plot(ttmrhox,combo1cdf(p_mle,ttmrhox),'color',[0 0 0],'displayname','combo_gamcdf');

testingfunc = @(x)slidegamcdf(x,ttmhat2(1),ttmhat2(2),ttmhat2(3))
[h,p,stats] = chi2gof(ttmx,'cdf',testingfunc)

%% Stat test of fits - so far not so good, what to do
% choose c, choose bins, draw in proportion from red and blue, combine,
% take mean and std,
% ask how different they are from the grey.
% ask andrew again.

% make a vector 299x1000 (length of ttmrhox by arbitrary number)
N = 1000;
testmat = zeros(length(ttmrhox),N);
% c_good = .5:.005:.6;
% c_set = [.1 .2 .25 .3 .35 .4 .425 .45 .475 .5 .525 .55 .575 .6 .65 .7  .75 .8 .9];
c_good = .57;
c_set = []
p = c_set;
c_set = sort([c_set,c_good]);
h_ind = zeros(1,N);
p_ind = h_ind;
for c = c_set
    rhoN = round(c*size(testmat,1));
    ttmN = size(testmat,1)-rhoN;
    for col = 1:size(testmat,2)
        rhodraws = round((length(wtx)-1)*rand(rhoN,1))+1; 
        ttmdraws = round((length(ttmx)-1)*rand(ttmN,1))+1; 
        testmat(1:rhoN,col) = wtx(rhodraws);
        testmat(rhoN+1:end,col) = ttmx(ttmdraws);
        testmat(:,col) = sort(testmat(:,col));
        [h_ind(col),p_ind(col),ksstat(col)] = kstest2(ttmrhox,testmat(:,col),.05);
    end
    c
    [h,p(find(c_set==c)),ksstat] = kstest2(ttmrhox,testmat(:),.05);
%     semilogx(testmat,1:length(ttmrhox),'linestyle','none','marker','+','markersize',.5,'markerfacecolor',[1 1 1]*c,'markeredgecolor',[1 1 1]*c)
%     hold on
%     plot(ttmrhox,1:length(ttmrhox));
%     pause
%     clf
end

%
internal_h = zeros(1,N);
internal_p = internal_h;
allbut = testmat(:,1:N-1);
for col = 2:N-1
    allbut = testmat(:,[1:col-1,col+1:N]);
    [internal_h(col),internal_p(col)] = kstest2(testmat(:,col),allbut(:),.05);
end


%% % The above is all shit.  What to do:  draw in proportion, keeping the numbers
% the same (ie min(length(wtx),length(ttmx))

c_good = .4:.005:.6;
c_set = [0:.025:1];
c_set = sort([c_set,c_good]);
i = 0;
figure(10)
constant_length = 1;
p = zeros(1000,1);
for c = c_set
    i = i+1;
    
    [l,j] = min([length(wtx)/c,length(ttmx)/(1-c)]);
    if constant_length
        rhoN = round(c*length(ttmrhox));
        ttmN = length(ttmrhox)-rhoN;
    else
        if j == 1
            rhoN = length(wtx);
            ttmN = floor(l)-length(wtx);
        elseif j == 2
            ttmN = length(ttmx);
            rhoN = floor(l)-length(ttmx);
        end
    end
        
    ttmN+rhoN;
    testdist = zeros(ttmN+rhoN,1); % 450- 
    
    for r = 1:1000
        testdist(1:rhoN) = wtx(randi(length(wtx),rhoN,1));
        testdist(rhoN+1:end) = ttmx(randi(length(ttmx),ttmN,1));
        [h,p(r),ksstat(i)] = kstest2(ttmrhox,testdist,.05);
    end
    ps{i} = p;
    semilogx(sort(testdist),(1:length(testdist))/length(testdist),...
        'linestyle','none',...
        'marker','+','markersize',.5,...
        'markerfacecolor',[1 1 1]*c,...
        'markeredgecolor',[1 1 1]*c)
    hold on
    plot(ttmrhox,(1:length(ttmrhox))/length(ttmrhox));
end

%% plot the histograms
b = 20;
p = cell2mat(ps);
p = -log10(p);
dbins = max(max(p))/b;
bins = dbins/2:dbins:max(max(p));
x = c_set;
y = zeros(b,length(c_set));
for c = 1:length(ps)
    y(:,c) = hist(p(:,c),bins);
end  
    
figure(11);
surf(c_set,-bins,y,'FaceColor','interp',...
    'EdgeColor','none') %,...    'FaceLighting','phong')
figure(12);
clf
mix = .1;
[n_good,bins_good] = hist(p(:,y(1,:)==max(y(1,:))),b);
[n_low,bins_low] = hist(p(:,c_set<mix+eps & c_set>mix-eps),b);
[n_high,bins_high] = hist(p(:,c_set==1-mix),b);

stairs(-(bins_good-diff(bins_good([1 2]))/2),n_good,'k')
hold on
stairs(-(bins_low-diff(bins_low([1 2]))/2),n_low,'b')
stairs(-(bins_high-diff(bins_high([1 2]))/2),n_high,'r')
stairs([log10(.01),log10(.01)],[0 160],'--k')
text(-19.5,140,sprintf('c_{max} = %g',c_set(y(1,:)==max(y(1,:)))))

% 
% surf(fftshift(acChopped),'FaceColor','interp',...
%     'EdgeColor','none') %,...    'FaceLighting','phong')

% plot(c_set,ksstat)
% 

%% histogram version of the same
ax = subplot(2,2,2);
set(ax,'tag','combo_hist','xscale','linear','ylim',[-.1 1.1]);
hold on

[bins,deltax] = subOptimalBinWidth(ttmx);
[n,bins] = hist(ttmx,bins);
n = n/length(ttmx)/deltax;
stairs(bins-deltax/2,n, 'Color',[1 0 0],'displayname','ttmhist'); hold on
plot(ttmx,slidegampdf(ttmx,ttmhat2(1),ttmhat2(2),ttmhat2(3)),'r','displayname','ttmpdffit');
axis tight

[bins,deltax] = subOptimalBinWidth(wtx);
[n,bins] = hist(wtx,bins);
n = n/length(wtx)/deltax;
stairs(bins-deltax/2,n, 'Color',[0 0 1],'displayname','wthist'); hold on
plot(wtx,slidegampdf(wtx,wthat2(1),wthat2(2),wthat2(3)),'b','displayname','wtpdffit');
axis tight

[bins,deltax] = subOptimalBinWidth(ttmrhox);
[n,bins] = hist(ttmrhox,bins);
n = n/length(ttmrhox)/deltax;
stairs(bins-deltax/2,n, 'Color',[0 0 0],'displayname','ttmrhohist'); hold on
plot(ttmrhox,combo1(p_mle,ttmrhox),'b','displayname','ttmrhopdffit');
axis tight


%% linear combination of Normalized responses

ttmrho_norm = mean(ttmrhodata,2);
ttmrho_norm = ttmrho_norm/max(ttmrho_norm);

ttm_norm = mean(ttmdata,2);
wt_norm = mean(wtdata,2);
ttm_norm = ttm_norm/max(ttm_norm);
wt_norm = wt_norm/max(wt_norm);


fakecombo = @(p)(p*ttm_norm + (1-p)*wt_norm);

fakemse = @(p)(mean((fakecombo(p)-ttmrho_norm).^2));

p_mse = fminsearch(fakemse,p_mle);

combocells = cell(combocelldata.keySet.toArray);

ps_mse = zeros(size(combocells));
n_epochs = ps_mse;

for c = 1:length(combocells)
    ttmrhocell_norm = combocelldata.get(combocells{c});
    n_epochs(c) = size(ttmrhocell_norm,1);
    ttmrhocell_norm = mean(ttmrhocell_norm,1);
    ttmrhocell_norm = ttmrhocell_norm/max(ttmrhocell_norm);
    
    fakecellmse = @(p)(mean((fakecombo(p)-ttmrhocell_norm').^2));
    ps_mse(c) = fminsearch(fakecellmse,p_mse);
end

figure(6)
ax = subplot(4,2,5);
hold on
cla
plot(p,likelihood)
set(ax,'ylim',[-1 11],'tag','p_mle');
linewdths = log2(n_epochs/min(n_epochs))+1;
for c = 1:length(ps_mse);
    plot(ps_mse(c),-0.5,'+k','linewidth', linewdths(c),'DisplayName',cells{c});
end
plot(p_mse,1,'+b','linewidth', log2(sum(n_epochs)/min(n_epochs))+1,'DisplayName','all epochs');

ax = subplot(2,2,4);
set(ax,'tag','front_end_kinetics');
hold on
plot(ax,ttm_norm,'r','Displayname','ttm_norm');
plot(ax,wt_norm,'b','Displayname','rho_norm');
plot(ax,ttmrho_norm,'k','Displayname','ttmrho_norm');
plot(ax,fakecombo(p_mse),'g','Displayname',sprintf('fake_p_mse_%.0f',p_mse*1000));
plot(ax,fakecombo(p_mle),'m','Displayname',sprintf('fake_p_mle_%.0f',p_mle*1000));

ax = subplot(4,4,13);
set(ax,'tag','min_ps_mse');
hold on
ttmrhocell_norm = combocelldata.get(combocells{ps_mse==min(ps_mse)});
ttmrhocell_norm = mean(ttmrhocell_norm,1);
ttmrhocell_norm = ttmrhocell_norm/max(ttmrhocell_norm);
plot(ax,ttmrhocell_norm,'k','Displayname','ttmrho_norm');
plot(ax,fakecombo(ps_mse(ps_mse==min(ps_mse))),'Displayname','min_ps_mse_mixed')

ax = subplot(4,4,14);
set(ax,'tag','max_ps_mse');
hold on
ttmrhocell_norm = combocelldata.get(combocells{ps_mse==max(ps_mse)});
ttmrhocell_norm = mean(ttmrhocell_norm,1);
ttmrhocell_norm = ttmrhocell_norm/max(ttmrhocell_norm);
plot(ax,ttmrhocell_norm,'k','Displayname','ttmrho_norm');
plot(ax,fakecombo(ps_mse(ps_mse==max(ps_mse))),'Displayname','max_ps_mse_mixed')


%% **** 2) keep p fixed, vary dtheta1, dtheta2
delta1 = .001;
delta2 = .005;

combo2 = @(tht1,tht2,x)...
    (p_mle*slidegampdf(x,wthat2(1),wthat2(2),wthat2(3)+tht1) +...
    (1-p_mle)*slidegampdf(x,ttmhat2(1),ttmhat2(2),ttmhat2(3)+tht2));

Dtheta_wt = (2*(wthat2ci(1,3)-wthat2(3)): delta1: 2*(wthat2ci(2,3)-wthat2(3)));
Dtheta_ttm = (2*(ttmhat2ci(1,3)-ttmhat2(3)): delta2 : 2*(ttmhat2ci(2,3)-ttmhat2(3)));

likelihood = zeros(length(Dtheta_wt),length(Dtheta_ttm));

for i = 1:length(Dtheta_wt)
    for j = 1:length(Dtheta_ttm)
        % likelihood(i) = sum(log(combo1(p(i),ttmrhox)))/length(ttmrhox);
        likelihood(i,j) = prod(combo2(Dtheta_wt(i),Dtheta_ttm(j),ttmrhox));
    end
end

likelihood = likelihood/(trapz(trapz(likelihood))*delta1*delta2);

figure(7)
ax = subplot(2,2,2);
% h = surf(Dtheta_ttm+ttmhat2(3),Dtheta_wt+wthat2(3),likelihood,'edgecolor','none');
h = contour(Dtheta_ttm+ttmhat2(3),Dtheta_wt+wthat2(3),likelihood);
xlabel('ttm');
ylabel('wt');

[r,c] = find(likelihood==max(max(likelihood)));
wthat_mle(3) = Dtheta_wt(r)+wthat2(3);
ttmhat_mle(3) = Dtheta_ttm(c)+ttmhat2(3);

%% **** 3) keep p and q fixed, vary dk1, dk2
delta1 = .1;
delta2 = .01;

combo3 = @(dk1,dk2,x)...
    (p_mle*slidegampdf(x,wthat2(1),wthat2(2)+dk1,wthat2(3)) +...
    (1-p_mle)*slidegampdf(x,ttmhat2(1),ttmhat2(2)+dk2,ttmhat2(3)));

Dk_wt = (2*(wthat2ci(1,2)-wthat2(2)): delta1: 2*(wthat2ci(2,2)-wthat2(2)));
Dk_ttm = (2*(ttmhat2ci(1,2)-ttmhat2(2)): delta2 : 2*(ttmhat2ci(2,2)-ttmhat2(2)));

likelihood = zeros(length(Dk_wt),length(Dk_ttm));

for i = 1:length(Dk_wt)
    for j = 1:length(Dk_ttm)
        % likelihood(i) = sum(log(combo1(p(i),ttmrhox)))/length(ttmrhox);
        likelihood(i,j) = prod(combo3(Dk_wt(i),Dk_ttm(j),ttmrhox));
    end
end

likelihood = likelihood/(trapz(trapz(likelihood)*delta1)*delta2);

figure(7)
ax = subplot(2,2,3);
%h = surf(Dk_ttm+ttmhat2(3),Dk_wt+wthat2(2),likelihood,'edgecolor','none')
h = contour(Dk_ttm+ttmhat2(2),Dk_wt+wthat2(2),likelihood);
xlabel('ttm');
ylabel('wt');

[r,c] = find(likelihood==max(max(likelihood)));
wthat_mle(2) = Dk_wt(r)+wthat2(2);
ttmhat_mle(2) = Dk_ttm(c)+ttmhat2(2);


%% **** 4) find mle for fullmodel
wthat_mle(1) = wthat2(1);
ttmhat_mle(1) = ttmhat2(1);

combo4pdf = @(x,p,sl1,k1,tht1,sl2,k2,tht2)...
    (p*slidegampdf(x,sl1,k1,tht1) +...
    (1-p)*slidegampdf(x,sl2,k2,tht2));
combo4cdf = @(x,p,sl1,k1,tht1,sl2,k2,tht2)...
    (p*slidegamcdf(x,sl1,k1,tht1) +...
    (1-p)*slidegamcdf(x,sl2,k2,tht2));

start = [p_mle,...
    wthat_mle(1),wthat_mle(2),wthat_mle(3),...
    ttmhat_mle(1),ttmhat_mle(2),ttmhat_mle(3)];

[combo_mle,combo_ci] = mle(ttmrhox,'pdf',combo4pdf,'cdf',combo4cdf,...
    'start',start);

figure(8)
hold on
plot(ttmrhox,ttmrhoy,'o','color',[1 1 1]*.8)
plot(ttmrhox,combo4cdf(ttmrhox,...
    combo_mle(1),...
    combo_mle(2),...
    combo_mle(3),...
    combo_mle(4),...
    combo_mle(5),...
    combo_mle(6),...
    combo_mle(7)),...
    'color',[0 0 0])
set(gca,'xscale','log')



%%
figure(7)
subplot(1,3,[1 2]);
hold on
plot(ttm_norm,'Color',[1 0 0]);
plot(wt_norm,'Color',[1 0 0]);
plot(ttmrho_norm,'Color',[1 1 1]*.8);
plot(fakecombo_norm,'k');

% what's the probability of an error this small?
subplot(1,3,3);
hold on
plot(p,fakemse)
% 
% rightofthd = ttmrhowproj>alphac;
% c_ttm = sum(~rightofthd)/length(rightofthd);
% c_wt = sum(rightofthd)/length(rightofthd);
% combo_norm = c_ttm*ttm_norm + c_wt*wt_norm;
% combo_norm = combo_norm/max(combo_norm);
% mse = mean((combo_norm-ttmrho_norm).^2);
% 
% subplot(1,3,[1 2]);
% plot(combo_norm,'m');
% subplot(1,3,3);
% plot(c_ttm,mse,'+')





%%

ttmrhox = sort(rspdrs.ttm4rhohet_30C);
ttmrhoy = (1:length(ttmrhox))/length(ttmrhox);

rightofthd = ttmrhowproj>alphac;

c_ttm = sum(~rightofthd)/length(rightofthd);
c_wt = sum(rightofthd)/length(rightofthd);

% c_xxx are the mixtures pulled from the descriminant
% xxx_mixture is the mixture created the coeficients that gave the smallest
% mse for the mean comparison.  
ttmfrac = c_ttm;
% ttmfrac = ttm_mixture;
wtfrac = c_wt;
% wtfrac = wt_mixture;

N = size(R,2);
N = min([length(ttmx)/ttmfrac, length(wtx)/wtfrac, N]);
N_wt = floor(wtfrac*N);
N_ttm = floor(ttmfrac*N);

wtindx = randperm(length(wtx))<=N_wt;
ttmindx = randperm(length(ttmx))<=N_ttm;
combox = sort([wtx(wtindx); ttmx(ttmindx)]);
comboy = (1:length(combox))/length(combox);

durdistr = {wtx,ttmx,ttmrhox,combox};
durp = NaN(length(durdistr));
for i = 1:length(durdistr)
    for j = i+1:length(durdistr)
        [temp,durp(i,j)] = kstest2(durdistr{i},durdistr{j});
    end
end

p = (0:.01:1);
q = 1-p;

comparisonp = q;
for e = 1:length(p)
    ttmfrac = p(e);
    wtfrac = q(e);
    N = size(R,2);
    N = min([length(ttmx)/ttmfrac, length(wtx)/wtfrac, N]);
    N_wt = floor(wtfrac*N);
    N_ttm = floor(ttmfrac*N);
    
    wtindx = randperm(length(wtx))<=N_wt;
    ttmindx = randperm(length(ttmx))<=N_ttm;
    combox = sort([wtx(wtindx); ttmx(ttmindx)]);
    [temp,comparisonp(e)] = kstest2(ttmrhox,combox);
end
comboy = (1:length(combox))/length(combox);

figure(6)
subplot(1,3,[2,3]);
set(gca,'XScale','log')
hold on
plot(wtx,wty,'b');
plot(ttmx,ttmy,'r');
plot(ttmrhox,ttmrhoy,'k');
plot(combox,comboy,'m')


figure(7)
hold on
plot(p,comparisonp)
set(gca,'Yscale','log')
plot(get(gca,'Xlim'),[.025 .025]);

%% Load response durations

expts = {'ttm1_30C',...
    'wt_ames_30C',...
    'stm_30C',...
    };

cdrs = 0;
celldrs = {};
cellnames = {};
exptnames = {};
for s=1:length(expts)
    expt = expts{s};
    ind = regexp(expts{s},'_');
    gen = expt(1:ind(1)-1);
    mp = load(sprintf('~/Analysis/Ovation-index/%s/%s/data/responseDurMap.mat',gen,expt));
    
    mp = mp.rspdrmp;
    
    cells = cell(mp.keySet.toArray);
    durs = [];
    for c = 1:length(cells)
        drs = mp.get(cells{c});
        durs = [durs;nanmean(drs(:,2:end),2)];
        cdrs = cdrs+1;
        celldrs{cdrs} = mean(drs(:,2:end),2);
        cellnames{cdrs} = cells{c};
        exptnames{cdrs} = expt;
    end
    rspdrs.(expt) = durs;
    celldstr.(expt) = celldrs;
end


%% Combo distributions (Gamma)  Do logarithmic display

% Parameterize the distributions
figure(6)
clf
ax = subplot(2,2,1);
set(ax,'tag','combo_distr','xscale','log','ylim',[-.1 1.1]);
hold on

stmx = sort(rspdrs.stm_30C);
% stmy = (1:length(stmx))/length(stmx);
% stmhat = gamfit(stmx);
% [stmhat2,stmhat2ci] = mle(stmx,'pdf',@slidegampdf,'cdf',@slidegamcdf,'start',[min(stmx),stmhat]);
logdelta = .1;

stmy = histc(stmx,bins);

stairs(stmx,stmy,'o','color',[.8 .8 .8]); hold on
% plot(stmx,slidegamcdf(stmx,stmhat2(1),stmhat2(2),stmhat2(3)),'color',[0 0 1],'displayname','wt_gamcdf');
% text(10,.65,sprintf('(%.3f, %.3f, %.3f)',stmhat2),'Color',[0 0 0]);

wtx = sort(rspdrs.wt_ames_30C);
wty = (1:length(wtx))/length(wtx);
wthat = gamfit(wtx);

[wthat2,wthat2ci] = mle(wtx,'pdf',@slidegampdf,'cdf',@slidegamcdf,'start',[min(wtx),wthat]);

hold on
plot(wtx,wty,'o','color',[.8 .8 1]);
plot(wtx,slidegamcdf(wtx,wthat2(1),wthat2(2),wthat2(3)),'color',[0 0 1],'displayname','wt_gamcdf');
text(10,.55,sprintf('(%.3f, %.3f, %.3f)',wthat2),'Color',[0 0 1]);

ttmx = sort(rspdrs.ttm1_30C);
ttmy = (1:length(ttmx))/length(ttmx);
ttmhat = gamfit(ttmx);

[ttmhat2,ttmhat2ci] = mle(ttmx,'pdf',@slidegampdf,'cdf',@slidegamcdf,'start',[min(ttmx),ttmhat]);

hold on
plot(ttmx,ttmy,'o','color',[1 .8 .8]);
plot(ttmx,slidegamcdf(ttmx,ttmhat2(1),ttmhat2(2),ttmhat2(3)),'color',[1 0 0],'displayname','ttm_gamcdf');
text(10,.45,sprintf('(%.3f, %.3f, %.3f)',ttmhat2),'Color',[1 0 0]);

%% log histograms distributions (Gamma) Do logarithmic display

figure(6)
clf
ax = subplot(1,1,1);

wtx = sort(rspdrs.wt_ames_30C);
wtlogdelta = 5e-2;
wtbins = min(wtx)*10.^(0:wtlogdelta:log10(max(stmx))+wtlogdelta);
wty = histc(wtx,wtbins)/length(wtx)*length(stmx);
stairs(ax,wtbins,wty,'color',[0 0 1]); hold on

stmx = sort(rspdrs.stm_30C);
stmlogdelta = 6e-2;
bins = min(stmx)*10.^(0:stmlogdelta:log10(max(stmx))+stmlogdelta);
stmy = histc(stmx,bins)/length(stmx)*length(stmx);
stairs(ax,bins,stmy,'color',[0 1 0]); hold on
set(ax,'tag','loghistos','xscale','log');%,'yscale','log');

ttmx = sort(rspdrs.ttm1_30C);
ttmlogdelta = 10e-2;
ttmbins = min(ttmx)*10.^(0:ttmlogdelta:log10(max(ttmx))+ttmlogdelta);
ttmy = histc(ttmx,ttmbins)/length(ttmx)*length(stmx);
stairs(ax,ttmbins,ttmy,'color',[1 0 0]); hold on
axis tight

%%
hold on
plot(wtx,wty,'o','color',[.8 .8 1]);
plot(wtx,slidegamcdf(wtx,wthat2(1),wthat2(2),wthat2(3)),'color',[0 0 1],'displayname','wt_gamcdf');
text(10,.55,sprintf('(%.3f, %.3f, %.3f)',wthat2),'Color',[0 0 1]);

ttmx = sort(rspdrs.ttm1_30C);
ttmy = (1:length(ttmx))/length(ttmx);
ttmhat = gamfit(ttmx);

[ttmhat2,ttmhat2ci] = mle(ttmx,'pdf',@slidegampdf,'cdf',@slidegamcdf,'start',[min(ttmx),ttmhat]);

hold on
plot(ttmx,ttmy,'o','color',[1 .8 .8]);
plot(ttmx,slidegamcdf(ttmx,ttmhat2(1),ttmhat2(2),ttmhat2(3)),'color',[1 0 0],'displayname','ttm_gamcdf');
text(10,.45,sprintf('(%.3f, %.3f, %.3f)',ttmhat2),'Color',[1 0 0]);


%% histogram version of the same
ax = subplot(2,2,2);
set(ax,'tag','combo_hist','xscale','linear','ylim',[-.1 1.1]);
hold on

[bins,deltax] = subOptimalBinWidth(ttmx);
[n,bins] = hist(ttmx,bins);
n = n/length(ttmx)/deltax;
stairs(bins-deltax/2,n, 'Color',[1 0 0],'displayname','ttmhist'); hold on
plot(ttmx,slidegampdf(ttmx,ttmhat2(1),ttmhat2(2),ttmhat2(3)),'r','displayname','ttmpdffit');
axis tight

[bins,deltax] = subOptimalBinWidth(wtx);
[n,bins] = hist(wtx,bins);
n = n/length(wtx)/deltax;
stairs(bins-deltax/2,n, 'Color',[0 0 1],'displayname','wthist'); hold on
plot(wtx,slidegampdf(wtx,wthat2(1),wthat2(2),wthat2(3)),'b','displayname','wtpdffit');
axis tight

[bins,deltax] = subOptimalBinWidth(ttmrhox);
[n,bins] = hist(ttmrhox,bins);
n = n/length(ttmrhox)/deltax;
stairs(bins-deltax/2,n, 'Color',[0 0 0],'displayname','ttmrhohist'); hold on
plot(ttmrhox,combo1(p_mle,ttmrhox),'b','displayname','ttmrhopdffit');
axis tight
