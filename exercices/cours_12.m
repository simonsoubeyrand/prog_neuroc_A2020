% Analyses & visualisation de donnée

% need some data points
load('eeg_data_PSY2038.mat','eeg_subjects','time','gr','ROIs')

% eeg_subejcts is a cell array with 4 conditions matrices of size
% [nb_subjects  x electrodes x time]
% time is from image onset : -150 to 1100 ms after onset.

% condition 1 :  face presented, face memory. 
% condition 2 :  non-face presented, non-face memory.
% condition 3 :  non-face presented, face memory.
% condition 4 :  face presented, non-face memory.

condition = 2; % on choisit la condition qu'on veut inspecter

% on va "inspecter" les donnees d'une condition specifique
data_temp = eeg_subjects{condition};

size_data = size(data_temp) % 32 sujets x 128 electrodes x 333 time samples

% % % this will only work if you have FieldTrip Toolbox (analysis for
% M/EEG) installed.
tmpcfg.layout=[];
tmpcfg.layout = 'biosemi128.lay';
lay = ft_prepare_layout(tmpcfg);

figure, ft_plot_layout(lay)

%% Inspection des donnees : histogram

% une bonne chose a faire est de regarder l'histogram. Ici, on est en mV.
% on cree une nouvelle figure avec "figure ," et on appelle la function
% "histogram"
figure, histogram(data_temp(:,:,:),50) % [1er arg : les data. 2e : le nombre de "bins"]


% meme chose, mais sur certaines electrodes seulement. 
electrodes_choisies=ROIs.CentralOcc;
data_roi{1}=squeeze(nanmean(data_temp(:,electrodes_choisies,:),2));
data_roi{2}=squeeze(nanmean(data_temp(:,ROIs.CentroFront,:),2));


% On ajoute aussi le titre des axes (e.g. xlabel), et de la figure (title)
figure, histogram(data_roi{1},50),...
    xlabel('mV'),ylabel('frequence'),title('distribution du voltage, electrode occipitales')


% on peut aussi juxtaposer deux graphiques (ou plus) en meme temps avec
% HOLD ON
figure, histogram(data_roi{1},50),...
    xlabel('mV'),ylabel('frequence'),title('distribution voltage, occ & frontales')
hold on
histogram(data_roi{2},50)...
    ,legend({'occipitales','frontales'})% On utilise LEGEND pour decrire ce qu'on montre. 1er : occipitales, 2eme: frontales.

%% Inspection des donnees : boxplot, differences stats, et plot
% on va maintenant inspecter avec certaines stats descriptives de la distribution, e.g.
% moyennes ,medianes, percentiles..
boxplot([data_roi{1}(:) data_roi{2}(:)],{'occipitales','frontales'},'plotstyle','compact','colors',[0 0 0])

% si on voulait comparer les distribution, on pourrait utiliser un ttest:
[H,P,CI,STATS] = ttest(data_roi{1}(:), data_roi{2}(:))

%% Pas tres interessant par contre. L'EEG est une technique d'imagerie
% plutot dynamique, avec une resolution temporelle tres fine. Voyons voir
% le decours temporel, 
condition=1;
data_roi{1}=squeeze(nanmean(eeg_subjects{condition}(:,electrodes_choisies,:),2));
data_roi{2}=squeeze(nanmean(eeg_subjects{condition}(:,ROIs.CentroFront,:),2));

figure, plot(time,mean(data_roi{1})),xlabel('temps (sec)'),ylabel('mV')
hold on
plot(time,mean(data_roi{2})),legend({'occipitales','frontales'}),title('Event Related Potential (ERP)')

%% % % % comparons visuelement les conditions dans le temps, sur differentesregions d'interet (electrodes)
electrodes_choisies=ROIs.RightOcc;
data_roi{1}=squeeze(nanmean(eeg_subjects{1}(:,electrodes_choisies,:),2));
data_roi{2}=squeeze(nanmean(eeg_subjects{2}(:,electrodes_choisies,:),2));
electrodes_choisies=ROIs.LeftOcc;
data_roi{3}=squeeze(nanmean(eeg_subjects{1}(:,electrodes_choisies,:),2));
data_roi{4}=squeeze(nanmean(eeg_subjects{2}(:,electrodes_choisies,:),2));


figure, plot(time,mean(data_roi{1}),'-b','LineWidth',2),xlabel('temps (sec)'),ylabel('mV'),title('ERP en fonction du type de stimuli')
hold on
plot(time,mean(data_roi{3}),'--b','LineWidth',2)
hold on
plot(time,mean(data_roi{2}),'-k','LineWidth',2)
hold on
plot(time,mean(data_roi{4}),'--k','LineWidth',2)
set(gcf,'Position',[100 100 1400 600], 'Color', 'w') % on choist la position et la Taille de la figure.
legend({'faces: right-hemisph','faces: left-hemisph','non-faces : right-hemisph','non-faces : left-hemisph'})
%% % % % comparons visuelement les GROUPES dans le temps, sur differentesregions d'interet (electrodes)
electrodes_choisies=ROIs.RightOcc;
data_roi{1}=squeeze(nanmean(eeg_subjects{1}(gr==1,electrodes_choisies,:),2));
data_roi{2}=squeeze(nanmean(eeg_subjects{1}(gr==0,electrodes_choisies,:),2));
electrodes_choisies=ROIs.LeftOcc;
data_roi{3}=squeeze(nanmean(eeg_subjects{1}(gr==1,electrodes_choisies,:),2));
data_roi{4}=squeeze(nanmean(eeg_subjects{1}(gr==0,electrodes_choisies,:),2));

color_palette=viridis;

figure, plot(time,mean(data_roi{1}),'-b','Color',color_palette(100,:),'LineWidth',2),xlabel('temps (sec)'),ylabel('mV'),title('ERP pour visage, en fonction du groupe')
hold on
plot(time,mean(data_roi{3}),'--b','Color',color_palette(100,:),'LineWidth',2)
hold on
plot(time,mean(data_roi{2}),'-k','Color',color_palette(150,:),'LineWidth',2)
hold on
plot(time,mean(data_roi{4}),'--k','Color',color_palette(150,:),'LineWidth',2)
set(gcf,'Position',[100 100 1400 600], 'Color', 'w') % on choist la position et la Taille de la figure.
legend({'group 1: right-hemisph','group 1 : left-hemisph','group 2 : right-hemisph','group 2 : left-hemisph'})

%% some stats, for the N170

electrodes_choisies=ROIs.RightOcc;
data_roi{1}=squeeze(nanmean(eeg_subjects{1}(:,electrodes_choisies,:),2));

n170_window= time<.180&time>.120;
time_n170=time(n170_window);
[amp_n170,ind]=min(data_roi{1}(:,n170_window)');
peak_n170=time_n170(ind);
peaks_n170=peak_n170;
amps_n170=amp_n170;

[H,P_lat,CI,STATS] = ttest2(peak_n170(gr==1),peak_n170(gr==0));
effect_group_peaktime = STATS.tstat
[H,P_amp,CI,STATS] = ttest2(amp_n170(gr==1),amp_n170(gr==0));
effect_group_peakamp = STATS.tstat
%%
time_window = 1:333;
for cond=1:4
data_brainrep{cond}=squeeze(mean(eeg_subjects{cond}(:,:,time_window)));
end

% plot en 2D (imagesc)
figure, imagesc(data_brainrep{1}),colormap(jet),ylabel('electrodes'),xlabel('time (sec)')
set(gca,'XTick',30:50:333,'XTickLabel',round(time(30:50:333),2))

% plot en 3D (surf plot..)
figure, surf(data_brainrep{1}),colormap(parula),ylabel('electrodes'),xlabel('time (sec)'),zlabel('amplitude (mV)')

figure, ft_plot_layout(lay)

%% TOPOGRAPHIES : ceci necessite fieldtrip (toolbox matlab pour l'EEG/MEG)

% now make a searchlight
tmpcfg.layout=[];
tmpcfg.layout = 'biosemi128.lay';

lay = ft_prepare_layout(tmpcfg);
chan_pos=lay.pos(1:128,1:2);

n170_window= time<.180&time>.120;% on choisit une "fenetre" temporelle
p100_window = time<.110&time>.09;

time_window=p100_window;
% time_window=n170_window;

figure,
tmp_topo=squeeze(mean(data_brainrep{1}(:,time_window),2));

ft_plot_topo(chan_pos(:,1),chan_pos(:,2),tmp_topo,'mask',lay.mask,'outline',lay.outline,'interplim','mask','isolines',[8]);%'clim',[-.5 .9],'isolines',[3]);%'clim',[-7 3]
colormap(viridis),axis('square'),axis off,h=colorbar,set(get(h,'label'),'string','uV'),title('EEG topography')
set(gca,'XTick',[],'YTick',[])
set(gca,'color','none')
set(gcf,'Position',[100 100 900 900], 'Color', 'w')
%% est-ce que la representation d'un individu pour les visages est similaire a celle pour les objects, scenes etc.?
% on peut regarder la similarité (multivariée) des représentations entre
% les conditions.
time_window = time<.110&time>.09; % on choisit une "fenetre" temporelle
time_window = time<.180&time>.120;


data_brainrep{1}=squeeze(nanmean(eeg_subjects{1}(gr==1,:,time_window),3));
data_brainrep{2}=squeeze(nanmean(eeg_subjects{2}(gr==1,:,time_window),3));
data_brainrep{3}=squeeze(nanmean(eeg_subjects{3}(gr==1,:,time_window),3));
data_brainrep{4}=squeeze(nanmean(eeg_subjects{4}(gr==1,:,time_window),3));

for cond=1:4
    data_brainrep{cond}=(mean(data_brainrep{cond}));
end

figure, scatter(data_brainrep{1}(:),data_brainrep{2}(:),'filled'),lsline,... % on ajoute lsline pour voir la droite des moindres carres (pente de correlation)
    xlabel('brain representation : faces'),ylabel('brain representation : non-faces');

hold off

[r,p]=corr(data_brainrep{1}',data_brainrep{2}','type','Kendall');

scatter(data_brainrep{1}(:),data_brainrep{2}(:),'filled'),... % on ajoute lsline pour voir la droite des moindres carres (pente de correlation)
    xlabel('brain representation : faces'),ylabel('brain representation : non-faces');
hold on 
scatter(data_brainrep{4}(:),data_brainrep{3}(:),'filled'),title(sprintf(' correlation = %.2f,p=%.4f',r,p))%,legend({'intra discrimination','inter (e.g. face vs nonface)'})


%%
hold off
color_palette=plasma;
color_electrodes=zeros(128,3);
color_electrodes(ROIs.RightOcc,:)=repmat(squeeze(color_palette(200,:)),numel(ROIs.RightOcc),1,1);
color_electrodes(ROIs.LeftOcc,:)=repmat(squeeze(color_palette(100,:)),numel(ROIs.LeftOcc),1,1);
color_electrodes(ROIs.CentralOcc,:)=repmat(squeeze(color_palette(50,:)),numel(ROIs.CentroFront),1,1);

figure,
h=scatter(data_brainrep{1}(:),data_brainrep{2}(:),'filled'),... % on ajoute lsline pour voir la droite des moindres carres (pente de correlation)
    xlabel('brain representation : faces'),ylabel('brain representation : non-faces'),title(sprintf(' correlation = %.2f,p=%.4f',r,p))
h.CData=color_electrodes;


%% Comparaisons des representations entre groupes
time_window = time<.180&time>.120; % on choisit une "fenetre" temporelle

data_brainrep{1}=(squeeze(mean(eeg_subjects{1}(:,:,time_window),3)));
data_brainrep{2}=(squeeze(mean(eeg_subjects{2}(:,:,time_window),3)));
ntime=333;

% on correle les representations, par moment dans le temps
[r,p]=corr(data_brainrep{1}',data_brainrep{2}','type','Spearman');

corr_intrasujets=r(eye(32)==1);
tmp=r;
tmp(eye(32)==1)=0;

corr_intersujets=mean(tmp);
anova1(corr_intersujets(:),gr(:))

%% show topographies
for cond=1:4
    figure,
    set(gcf,'Position',[100 100 900 300], 'Color', 'w')
    for t=1:4
        this_time=these_times{t};
        ts=time(these_times{t});
        
        tmp_topo=squeeze(mean(all_topo{1}(:,cond,t,:)));
        subplot(2,4,t), ft_plot_topo(chan_pos(:,1),chan_pos(:,2),tmp_topo,'mask',lay.mask,'outline',lay.outline,'interplim','mask','clim',[-7 14]);%,'isolines',[3]);%'clim',[-7 3]
        colormap(viridis),axis('square'), title(sprintf('%3.0f-%3.0f ms',round(ts(1),2)*1000,round(ts(end),2)*1000)),axis off,h=colorbar,set(get(h,'label'),'string','uV'),title(which_conds_labels{cond})
        set(gca,'XTick',[],'YTick',[])
        set(gca,'color','none')
        tmp_topo=squeeze(mean(all_topo{2}(:,cond,t,:)));
        subplot(2,4,t+4), ft_plot_topo(chan_pos(:,1),chan_pos(:,2),tmp_topo,'mask',lay.mask,'outline',lay.outline,'interplim','mask','clim',[-7 14]);%,'isolines',[3]);%'clim',[-7 3]
        colormap(viridis),axis('square'), title(sprintf('%3.0f-%3.0f ms',round(ts(1),2)*1000,round(ts(end),2)*1000)),axis off,h=colorbar,set(get(h,'label'),'string','uV');
        set(gca,'XTick',[],'YTick',[])
        set(gca,'color','none')
    end
end



