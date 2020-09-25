function grand_damier = fabriquer_grand_damier_rampe(la_moitie, m_rangees, n_colonnes,p,q)
% grand_damier = fabriquer_grand_damier(la_moitie, nb_repetition)
% Fabrique un damier de 2*m_rangees par 2*n_colonnes cases.
% Utilise la fonction fabriquer_petit_damier.
% Frederic Gosselin, 16/01/2003

% fabrique petit damier, i.e.le "cycle"
petit_damier = fabriquer_petit_damier_rampe(la_moitie,p,q);

% repete le petit damier
grand_damier = zeros(m_rangees * 2 * la_moitie, n_colonnes * 2 * la_moitie);
for ii = 1:m_rangees
	for jj = 1:n_colonnes
		grand_damier(((ii - 1) * 2 * la_moitie + 1) : (ii * 2 * la_moitie), ((jj - 1) * 2 * la_moitie + 1) : (jj * 2 * la_moitie)) = petit_damier;
	end
end

end
