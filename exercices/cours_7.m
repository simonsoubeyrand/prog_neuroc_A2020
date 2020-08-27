% fabrication d'un son pur
Fe = 44100; % frequence d'echantillonnage temporelle; 8000, 11025, 22050, 44100, 48000, 96000
nBits = 16; % nombre de bits par echantillon; 8, 16 ou 24 bits
duree = 2; % duree en s
freq = 1000; % frequence en Hz
etendue = 2 * pi * (0:duree*Fe-1) / Fe;
amplitude = 0.2;
un_son = amplitude * sin(freq * etendue); % son composee d'un sinus a une frequence de 'freq' Hz d'une duree de 'duree'; un_son doit varier entre -1 et 1
sound(un_son, Fe, nBits); % joue le son

% alternativement, pour plus de controle dans le jeu :
un_son_struct = audioplayer(un_son, Fe, nBits);
play(un_son_struct)

audiowrite('son_1000_Hz.wav', un_son, Fe) % sauvergarder un son dans un fichier .wav

[un_son2, Fe2] = audioread('son_2000_Hz.wav'); % lire un fichier .wav

sound(un_son2, Fe2); % joue le son


% fabrication d'un son pur stereo avec delai de phase interaurale de
% 'delai' rad
Fe = 44100; % frequence d'echantillonnage temporelle; 8000, 11025, 22050, 44100, 48000, 96000
nBits = 24; % nombre de bits par echantillon; 8, 16 ou 24 bits
duree = 1; % duree en s
etendue = 2 * pi * (0:duree*Fe-1) / Fe;
freq = 1000; % frequence en Hz
delai_phase = pi/2; % delai de phase interaural; entre 0 et pi
un_son_stereo(:,1) = sin(freq * etendue); % son composee d'un sinus a freq Hz
un_son_stereo(:,2) = sin(freq * etendue + delai_phase); % son composee d'un sinus a freq Hz

sound(un_son_stereo, Fe, nBits)

diviseur = 100; % seulement pour aider a la visualisation
figure, plot(etendue(1:round(end/diviseur)), un_son_stereo(1:round(end/diviseur),:)) % visualiser le delai de phase
xlabel(sprintf('%.2f s', duree/diviseur))


% bruit blanc
Fe = 22050; % frequence d'echantillonnage temporelle; 8000, 11025, 22050, 44100, 48000, 96000
nBits = 24; % nombre de bits par echantillon; 8, 16 ou 24 bits
duree = 1; % duree en s
bruit = randn(duree*Fe, 1);
sound(bruit, Fe, nBits)

sum(abs(bruit)>1)/length(bruit)

figure, hist(bruit(:))

perte = 0.05; % proportion de signal perdu
bruit_ajuste = bruit/(icdf('Normal',(1-perte/2),0,1));
figure, hist(bruit_ajuste(:))
sum(abs(bruit_ajuste)>1)/length(bruit_ajuste)

sound(bruit_ajuste, Fe, nBits)


% ajout d'une rampe avant et apres son
Fe = 22050; % frequence d'echantillonnage temporelle; 8000, 11025, 22050, 44100, 48000, 96000
nBits = 24; % nombre de bits par echantillon; 8, 16 ou 24 bits
duree = 1; % duree en s
bruit = randn(duree*Fe, 1);
perte = 0.05; % proportion de signal perdu
bruit_ajuste = bruit/(icdf('Normal',(1-perte/2),0,1));

duree_rampe = 0.2; % duree en s
masque = ones(size(bruit_ajuste));
rampe = (0:round(duree_rampe*Fe))/round(duree_rampe*Fe);
masque(1:length(rampe)) = rampe;
masque(end-length(rampe)+1:end) = fliplr(rampe);
figure, plot(masque)
stimulus = masque.*bruit_ajuste;
figure, plot(stimulus)
sound(stimulus, Fe, nBits)

