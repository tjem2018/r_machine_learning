function Ic_best = best_complement_opt(I,div_it)
mean_border = mean_border_int(I,div_it);
mean_centre = mean_centre_int(I,div_it);
Ic_t = imcomplement(I);
mean_border_c = mean_border_int(Ic_t,div_it);
mean_centre_c = mean_centre_int(Ic_t,div_it);
% 'BCOMP vars:'
% mean_border
% mean_centre
% mean_border_c
% mean_centre_c
% complement to make centre mean brigher intensity
if (mean_border > mean_centre && mean_border_c < mean_centre_c)
    Ic_best = imcomplement(I);
elseif (mean_border < mean_centre && mean_border_c > mean_centre_c)
    Ic_best = I;
elseif isequal(needs_comp(I,Ic_t),1)
    Ic_best = imcomplement(I);
else
    Ic_best = I;
end;
end