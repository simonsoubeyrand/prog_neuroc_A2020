function petit_damier = fabriquer_petit_damier_rampe(la_moitie,p,q)
% petit_damier = fabriquer_petit_damier(la_moitie)
% Fabrique un petit damier de 2 par 2 cases.
% Frederic Gosselin, 16/01/2003
% Simon Faghel-Soubeyrand, 2020

rampe = repmat(p:1/(la_moitie-1):q, la_moitie, 1);

% clear rampe
% for row_case=1:la_moitie
%     count=0;
%     for col_case=p:(1/(la_moitie-1)):q
%         count=count+1;
%         temp(row_case,count)=ll;
%     end
% end

petit_damier = ones(2 * la_moitie, 2 * la_moitie);
petit_damier(1 : la_moitie, 1 : la_moitie) = rampe;
petit_damier(la_moitie + 1 : 2 * la_moitie, la_moitie + 1 : 2 * la_moitie) = rampe;

end