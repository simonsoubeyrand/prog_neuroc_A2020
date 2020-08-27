% Devoir : écrire un script (ou une fonction) qui dessine un grand_damier semblable au petit_damier de 2*N x 2*M cases en utilisant le petit_damier et des boucles.

% % % % % % % % % % % % % % % % % % % % % % % %
% % % % % % % % % % % % % % % % % % % % % % % % 

function petit_damier = fabriquer_petit_damier(la_moitie)
% petit_damier = fabriquer_petit_damier(la_moitie)
% Fabrique un petit damier de 2 par 2 cases.
% Frederic Gosselin, 16/01/2003

petit_damier = ones(2 * la_moitie, 2 * la_moitie);
petit_damier(1 : la_moitie, 1 : la_moitie) = 0;
petit_damier(la_moitie + 1 : 2 * la_moitie, la_moitie + 1 : 2 * la_moitie) = 0;

% % % % % % % % % % % % % % % % % % % % % % % %
% % % % % % % % % % % % % % % % % % % % % % % % 













% % % % % % % % % % % % % % % % % % % % % % % % 
% % % % % % % % % % % % % % % % % % % % % % % % 

function grand_damier = fabriquer_grand_damier(la_moitie, m_rangees, n_colonnes)
% grand_damier = fabriquer_grand_damier(la_moitie, nb_repetition)
% Fabrique un damier de 2*m_rangees par 2*n_colonnes cases.
% Utilise la fonction fabriquer_petit_damier.
% Frederic Gosselin, 16/01/2003

% fabrique petit damier, i.e. le "cycle"
petit_damier = fabriquer_petit_damier(la_moitie);

% repete le petit damier
grand_damier = zeros(m_rangees * 2 * la_moitie, n_colonnes * 2 * la_moitie);
for ii = 1:m_rangees,
	for jj = 1:n_colonnes,
		grand_damier(((ii - 1) * 2 * la_moitie + 1) : (ii * 2 * la_moitie), ((jj - 1) * 2 * la_moitie + 1) : (jj * 2 * la_moitie)) = petit_damier;
	end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


imshow(fabriquer_grand_damier(256/(4*2), 4, 4))
figure, imshow(1-fabriquer_grand_damier(256/(4*3), 4, 4))



% autre solution 1 :
la_moitie = 10;
m_rangees = 10;
n_colonnes = 10;
grand_damier = repmat(fabriquer_petit_damier(la_moitie), m_rangees, n_colonnes);


% autre solution 2 :
la_moitie = 10;
nb_repetition = 5;
grand_damier = xor(repmat((mod(0 : nb_repetition * 2 * la_moitie - 1, 2*la_moitie) < la_moitie), nb_repetition * 2 * la_moitie, 1), repmat((mod(0 : nb_repetition * 2 * la_moitie - 1, 2*la_moitie) < la_moitie), nb_repetition * 2 * la_moitie, 1)');



% sauvegarder une image
grand_damier1 = fabriquer_grand_damier(256/8, 4, 3);
figure, imshow(grand_damier1)

imwrite(grand_damier1, 'damier.tif', 'tif')
grand_damier2 = imread('damier.tif');
figure, imshow(grand_damier2)


% uint8 vs. double entre 0 et 1...
min(grand_damier1(:)), max(grand_damier1(:))
min(grand_damier2(:)), max(grand_damier2(:))


% rampe de luminance
rampe = repmat(0:1/(2000-1):1, 2000, 1);
figure, imshow(rampe)
imwrite(rampe, 'rampe.tif', 'tif')
rampe2 = imread('rampe.tif');
figure, imshow(rampe2)
numel(unique(rampe(:)))
numel(unique(rampe2(:)))
figure, plot(rampe(1,1:100), 255*rampe(1,1:100), 'k', rampe(1,1:100), rampe2(1,1:100), 'r')

rampe3 = uint8(255*rampe);





% Devoir : le grand_damier varie présentement entre 0 (case noires) et 1 (cases blanches); le faire varier entre p et q (avec p < q).




