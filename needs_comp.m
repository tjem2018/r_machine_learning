function needs_comp = needs_comp(I,Ic)
rlev = graythresh(I);
I_bw = im2bw(I,rlev);
[height width depth] = size(I);
I_db = double(I_bw);    
sum_I = 0;
for i = 1:width
    for j = 1:height
        sum_I = sum_I + I_db(j,i);
    end;
end;
I_avg_int = sum_I/(width*height);

rlev = graythresh(Ic);
Ic_bw = im2bw(Ic,rlev);
[height width depth] = size(Ic);
Ic_db = double(Ic_bw);    
sum_Ic = 0;
for i = 1:width
    for j = 1:height
        sum_Ic = sum_Ic + Ic_db(j,i);
    end;
end;
Ic_avg_int = sum_Ic/(width*height);

if I_avg_int < Ic_avg_int
    needs_comp = 1;
    echo on;
    '||| Needs Complement:'
    I_avg_int
    Ic_avg_int
    echo off;
else
    needs_comp = 0;
    echo on;
    '||| No need Complement:'
    I_avg_int
    Ic_avg_int
    echo off;
end;

end