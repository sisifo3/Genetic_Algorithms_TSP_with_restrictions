function[anser] = main_cangrejo(~)

close all;
clc;

%=======1 for PMx and other for David ===== 
crossover_tec = 0;
%=================end=====================
%============help==========
dista_pid = csvread('dist_f.csv');
%===========end==========
%disp(dista_pid)

number_of_solution = 100;
sol = number_of_solution;

celda_num = zeros(sol,3);
celda_num = num2cell(celda_num);

cell_num = zeros(sol*2,3);
cell_num = num2cell(cell_num);

mid_sol = sol/2;
generations = 100;

it_gen = zeros(1,generations);
sum_aptd = zeros(1,generations);

best_solution_per_generation = zeros(generations,3);
best_solution_per_generation = num2cell(best_solution_per_generation);

bes_ind_pmx = zeros(1,generations);
wor_ind_pmx = zeros(1,generations);


for i = 1:sol
    arr_temp =  randperm(18,18);
    celda_num{i,1} = arr_temp;
    cell_num{i,1} = arr_temp;
end

[celda_num] = make_dist_apt(celda_num,dista_pid);

for iter = 1:generations
    for rip = 1:mid_sol
        [pred1,pred2] = sel_pad_best(celda_num);
        
        if crossover_tec == 1
            [desc1,desc2] = crossover_PMx_18(pred1,pred2);
        else
            [desc1,desc2] = order_crossover_Davids(pred1,pred2);
        end
        
        cell_num{rip+sol,1} = desc1;
        cell_num{rip+mid_sol*3,1} = desc2;
    end
    
    [cell_num] = make_dist_apt(cell_num,dista_pid);
    [cell_num] = biology_competition(cell_num,dista_pid);
    
    b = mod(iter,10);
    if b == 0
        disp('heuristic')
        [cell_num] = heuristic_mutation(cell_num,dista_pid);
    end
         
    [sum_apt] = apt_for_gene(cell_num);
    sum_aptd(iter) =  sum_apt;
    it_gen(iter) =  iter;
    
    best_solution_per_generation(iter,:) = cell_num(1,:);
    bes_ind_pmx(iter) = cell_num{1,3}; 
    wor_ind_pmx(iter) = cell_num{100,3};
    
    
    disp(iter)
    celda_num = cell_num;
end
%[apt_david,bes_ind,wos_ind] = cangrejo_david();



%disp(best_solution_per_generation)
%[wx] = learn_to_plot(it_gen,apt_david,sum_aptd);
%[wz] = learn_to_plot_bestind(it_gen,bes_ind,bes_ind_pmx);


anser = cell_num;
%disp(wx)
%disp(wz)




















%==============make_dist_apt=====================
function[cell_out] = make_dist_apt(cell_in,dista_pid)

len_hg = length(cell_in);

%una vez generada la poblacion, buscamos sus distancias y las sumamos.
for ri = 1:len_hg
    ce = cell_in{ri,1};
    a = zeros(1,18);
    a(1) = dista_pid(ce(1),ce(2));
    a(2) = dista_pid(ce(2),ce(3));
    a(3) = dista_pid(ce(3),ce(4));
    a(4) = dista_pid(ce(4),ce(5));
    a(5) = dista_pid(ce(5),ce(6));
    a(6) = dista_pid(ce(6),ce(7));
    
    a(7) = dista_pid(ce(7),ce(8));
    a(8) = dista_pid(ce(8),ce(9));
    a(9) = dista_pid(ce(9),ce(10));
    a(10) = dista_pid(ce(10),ce(11));
    a(11) = dista_pid(ce(11),ce(12));
    a(12) = dista_pid(ce(12),ce(13));
    
    a(13) = dista_pid(ce(13),ce(14));
    a(14) = dista_pid(ce(14),ce(15));
    a(15) = dista_pid(ce(15),ce(16));
    a(16) = dista_pid(ce(16),ce(17));
    a(17) = dista_pid(ce(17),ce(18));
    a(18) = dista_pid(ce(18),ce(1));
    
    sum_a = sum(a);
    cell_in{ri,2} = sum_a;
end

% es necesario ordenar con la fittnes function.
%fitness = 1/cost;
for tre = 1:len_hg
    fitness = 1/cell_in{tre,2};
    cell_in{tre,3} = fitness;
end
[cell_in] = ord_insertion(cell_in);
cell_out = cell_in;
end

%===============end==========

%=======ord_insertion=========
function[celda_ord] = ord_insertion(celda_num)

for ls = 1:length(celda_num)
    d = ls;
    while((d > 1) && (celda_num{d,3}) > (celda_num{d-1,3}))
        % aptitud.
        var_temp = celda_num{d,3};
        celda_num{d,3} = celda_num{d-1,3};
        celda_num{d-1,3} = var_temp;
       
        %distance. 
        var_temp1 = celda_num{d,2};
        celda_num{d,2} = celda_num{d-1,2};
        celda_num{d-1,2} = var_temp1;
        %gene. 
        var_temp2 = celda_num{d,1};
        celda_num{d,1} = celda_num{d-1,1};
        celda_num{d-1,1} = var_temp2;
        
        d = d-1;
        
    end
end
celda_ord= celda_num;
end
%============end=============

%=========sel_pad_best=======
function [padre1,padre2] =  sel_pad_best(Ce_cmp)    
%global selection_metodo 
padre1 = zeros(1,18);
padre2 = zeros(1,18);
for rl = 1:2
    if rl ==1
       [index] = my_own_RWS_best(Ce_cmp);
       padre1 = Ce_cmp{index,1};
    end
    if rl ==2
        [index] = my_own_RWS_best(Ce_cmp);
        padre2 = Ce_cmp{index,1};
    end
end
 
end 
%==========end===========

%=======my_own_RWS_best===
function [index] = my_own_RWS_best(Ce_cmp)
% generamos la probabilidad de que sean seleccionados, esta aumenta 
%dependiendo de su fitness
%creamos un valor prioridad.
len_v = length(Ce_cmp);
vec_prio = zeros(len_v,1);
for le = 1:len_v
    vec_prio(le,1) = Ce_cmp{le,3};
end
%[1] = previous_probability + (fitness / sum_of_fitness) = 0.0 + (1 / 10) = 0.1
%previous_probability = 0.1
vec_prio = flipud(vec_prio); %invertimos los valores 
sum_vec_prio = sum(vec_prio);
prob_selec = vec_prio/sum_vec_prio;   %Generamos todo la matriz con los resultados (fitness / sum_of_fitness)
%Generamos la probabilidad de ser seleccionado la suma de pre_pro + (fit/sum)
proba = zeros(1,len_v);
prev_proba = 0;
for km = 1:len_v
    proba(km) = prev_proba + prob_selec(km,1);
    prev_proba = proba(km);
end
%Escogemos al asar el numero en index que necesitamos.
%xbp = flipud(proba);
num_rand = rand;
%disp(num_rand)
for ksr = 1:len_v
    if num_rand < proba(ksr)
        index = ksr;
        return
    end
end

end
%===========end=========


%=========crossover_PMx_18========
function[desc1,desc2] = crossover_PMx_18(pred1,pred2)

nir = randi(12);
mat_one = zeros(2,12);
ident_mat = zeros(2,6);

for old = 1:nir
    mat_one(1,old) = pred1(old);
    mat_one(2,old) = pred2(old);    
end
nar = nir+6;
ner = 18-nar;
for olp = 1:ner
    mat_one(1,nir+olp) = pred1(nar+olp);
    mat_one(2,nir+olp) = pred2(nar+olp);
end

for gh = 1:6
    ident_mat(2,gh) = pred1(gh+nir);
    ident_mat(1,gh) = pred2(gh+nir);
end

%for this part of the code we have the matrx identidy [ident_mat] and 
%the matriz for comparation [mat_one]
%disp(mat_one)
count_it = 0;
var_a = [];
%for olq = 1:3
fatal_error = 1;
%for ejem = 1:5
while fatal_error ~= 0    
    count_it = count_it + 1;
    count = 0;
   
    for olr = 1:12
        for olt = 1:6
            if mat_one(1,olr) == ident_mat(1,olt) 
                temp_var_a = mat_one(1,olr);
                mat_one(1,olr) = mat_one(2,olr);
                mat_one(2,olr) = temp_var_a;
                var_a = [var_a,olr];
                count = count + 1;
            end 
             if mat_one(2,olr) == ident_mat(2,olt) 
                temp_var_b = mat_one(2,olr);
                mat_one(2,olr) = mat_one(1,olr);
                mat_one(1,olr) = temp_var_b;
                var_a = [var_a,olr];
                count = count +1;
            end

        end
    end    

    %Now we have a array that it's compared and changed depend of the simility of
    %mat_one and ident_mat;
    %it the next we compare mat_one inside for a repeat value.

    for olte = 1:12
        for oly = 1:12
            if mat_one(1,olte) == mat_one(1,oly) && olte ~= oly
                exist_olte = any(var_a(:) == olte);
                if exist_olte == 0
                    temp_varb = mat_one(1,olte);
                    mat_one(1,olte) = mat_one(2,olte);
                    mat_one(2,olte) = temp_varb;
                    var_a = [var_a,olte];
                    count = count +1;
                end    
            end
            if mat_one(2,olte) == mat_one(2,oly) && olte ~= oly
                exist_oltbe = any(var_a(:) == olte);
                if exist_oltbe == 0
                    temp_varb = mat_one(2,olte);
                    mat_one(2,olte) = mat_one(1,olte);
                    mat_one(1,olte) = temp_varb;
                    var_a = [var_a,olte];
                    count = count +1;
                end    
             end
        end
    end    
    
    fatal_error = 0;
    for olz = 1:12
        for olw = 1:12
            if mat_one(1,olz) == mat_one(1,olw) && olz ~= olw
                
                fatal_error = 1;
                count = count +1;  
            end
            if mat_one(2,olz) == mat_one(2,olw) && olz ~= olw
               
                count = count +1;  
                fatal_error = 1;
            end

        end
    end    

    for oln = 1:12 
        for olm = 1:6
            if mat_one(1,oln) == ident_mat(1,olm) && oln ~= olm
               
                fatal_error = 1;
            end
            if mat_one(2,oln) == ident_mat(2,olm) && oln ~= olm
               
                fatal_error = 1;
            end
        end
    end    
end

desc1 = zeros(1,18); 
desc2 = zeros(1,18);
nir = randi(12);
nar = nir+6;
ner = 18-nar;
for olu = 1:nir
    desc1(olu) = mat_one(1,olu);
    desc2(olu) = mat_one(2,olu);
end
for oli = 1:6
    desc1(nir+oli) = ident_mat(1,oli);
    desc2(nir+oli) = ident_mat(2,oli);
end

for ole = 1:ner
    desc1(nar+ole) = mat_one(1,nir+ole);
    desc2(nar+ole) = mat_one(2,nir+ole);
end  
%and the last just for security we check the last time
%for repeat values.


for ot = 1:18
    for op = 1:18
        
        if desc1(1,ot) == desc1(1,op) && ot ~= op
            disp('fatal Global error line 1')
            disp(pred1)
            disp(desc1)
        end
        if desc2(1,ot) == desc2(1,op) && ot ~= op
            disp('fatal Global error line 2')
            disp(pred2)
            disp(desc2)
            
        end   
    end
end    

end
%=================end===============


%======order_crossover_Davids=========
function[david_one,david_two] = order_crossover_Davids(pred1,pred2)

%pred1 = randperm(18,18);
%pred2 = randperm(18,18);
%pred1 = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18];
%pred2 = [18,17,16,15,14,13,12,11,10,9,8,7,6,5,4,3,2,1];

david_one = zeros(1,18);
david_two = zeros(1,18);
t_one = zeros(1,18);
t_two = zeros(1,18);
O_one = zeros(1,12);
O_two = zeros(1,12);

%ran_dd = randi(12);
ran_dd = 8;
ran_da = ran_dd + 6;
ran_db = 18-ran_da;
ran_dc = 12-ran_db;

for dvd = 1:ran_db
    t_one(dvd) = pred1(ran_da+dvd); 
    t_two(dvd) = pred2(ran_da+dvd);
end

for dvda = 1:ran_da
    t_one(ran_db + dvda) = pred1(dvda);
    t_two(ran_db + dvda) = pred2(dvda);
end    
%disp(t_one)
%disp(t_two)
for dvdc = 1:6
    david_one(ran_dd+dvdc) = pred2(ran_dd+dvdc);
    david_two(ran_dd+dvdc) = pred1(ran_dd+dvdc);
end

v_a = 1;
v_b = 1;
for dvdb = 1:18
    ex_tind2 = any(david_one(:) == t_one(dvdb));
    ex_tind1 = any(david_two(:) == t_two(dvdb));
    if ex_tind2 == 0
        O_one(v_a) = t_one(dvdb);
        v_a = v_a + 1;
    end
    if ex_tind1 == 0
        O_two(v_b) = t_two(dvdb);
        v_b = v_b + 1;
    end    
end

for dvdc = 1:ran_db
    david_one(ran_da+dvdc) = O_one(dvdc);
    david_two(ran_da+dvdc) = O_two(dvdc);
end    

for dvdd = 1:ran_dc
    david_one(dvdd) = O_one(ran_db+dvdd);
    david_two(dvdd) = O_two(ran_db+dvdd);
end
%disp(david_one)
%disp(david_two)
for dvde = 1:18
    for dvdf = 1:18
        if david_one(dvde) == david_one(dvdf) && dvde ~= dvdf
            disp('fatal error davids one zone')
        end    
        if david_two(dvde) == david_two(dvdf) && dvde ~= dvdf
            disp('fatal error davids two zone')
        end    
    end   
end    
end
%===============end===============

%===========biology_competition=====
function[more_stronge] = biology_competition(cell_pred_desc,dista_pid)
%disp(cell_pred_desc)


[cell_pred_desc] =  delete_repeated(cell_pred_desc,dista_pid);

%dista_pid = readtable('dist_f.csv');
%dista_pid = table2array(dista_pid);

[cell_out] = make_dist_apt(cell_pred_desc,dista_pid);
%disp(cell_out)
len_bc = length(cell_out);
len_bc_two = len_bc/2;
cell_str = zeros(len_bc_two,3);
cell_str = num2cell(cell_str);

for str = 1:len_bc_two
    cell_str(str,:) = cell_out(str,:);
end    


more_stronge = cell_str;

end
%===========end===========

%======delete_repeated====
function[cell_nor] =  delete_repeated(cell_act,dista_pid)

%disp(cell_act)
%dista_pid = readtable('dist_f.csv');
%dista_pid = table2array(dista_pid);

cookie_loc = zeros(18,1);

len_dt = length(cell_act);
%disp(len_dt)
for dtl = 1:len_dt
    for dtla = 1:len_dt
        exist_cookie = any(cookie_loc(:) == dtla);
        if cell_act{dtl,2} == cell_act{dtla,2} && dtl ~= dtla && exist_cookie == 0
            cookie_loc(dtl) = dtl;
            gen_loc_rep = cell_act{dtla,1};
            %disp(gen_loc_rep)
            [gen_mut] = scramble_met_per_one(gen_loc_rep);
            cell_act{dtla,1} = gen_mut;    
        end
    end  
     %disp(dtl)

end
[cell_act] = make_dist_apt(cell_act,dista_pid);
%disp(cell_act)
cell_nor = cell_act;
end
%============end========

%========scramble_met_per_one========
function[anser] = scramble_met_per_one(gen_loc_rep)

%gen_loc_rep = randperm(18,18);

gen_loc_sc = zeros(1,18);
mat_rep_one = zeros(1,12);
mat_rep_two = zeros(1,6);

for sma = 1:1
    
    nsm = randi(12);
    %nsm = 3;
    nsma = nsm + 6;
    nsmb = 18-nsma;
    for smb = 1:nsm
        mat_rep_one(smb) = gen_loc_rep(smb);
    end
    for smc = 1:6
        mat_rep_two(smc) = gen_loc_rep(smc+nsm);
    end
    for smd = 1:nsmb
        mat_rep_one(smd+nsm) = gen_loc_rep(nsma + smd);
    end
    
    nsm_m = randi(12);
    %nsm_m = 5;
    nsm_ma = nsm_m + 6; 
    nsm_mb = 18-nsm_ma;
    for sme = 1:nsm_m
        gen_loc_sc(sme) = mat_rep_one(sme);
    end
    for smf = 1:6
        gen_loc_sc(smf+nsm_m) = mat_rep_two(smf);
    end
    for smg = 1:nsm_mb
        gen_loc_sc(nsm_ma+smg) = mat_rep_one(smg+nsm_m);
    end
    
end


anser = gen_loc_sc;        


end
%===============end============

%========heuristic_mutation========
function[cell_muted] = heuristic_mutation(cell_for_mut,dista_pid)
%in this function acept the cell and back 
% a cell with the 10 with mutation.

len_hm = length(cell_for_mut);
len_por = len_hm/2;
len_ph = len_hm - len_por;

for hma = 1:len_por
    one_man = cell_for_mut{len_ph+hma,1};
    [one_man_mut] = permu_loc(one_man,dista_pid);
    cell_for_mut(len_ph+hma,:) = one_man_mut(1,:);
end

[cell_for_mut] = ord_insertion(cell_for_mut);

cell_muted = cell_for_mut;


end
%================end=======

%=========permu_loc=========
function[one_man_mut] = permu_loc(one_man,dista_pid)

%one_man = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18];
rni = randi(12);
rne = rni+6;
rna = 18-rne;

one_man_one = zeros(1,6);
one_man_two = zeros(1,12);
one_man_per = zeros(720,18);
cell_cromut = zeros(720,3);
cell_cromut = num2cell(cell_cromut);

for om = 1:rni
    one_man_two(om) = one_man(om);
end
for oma = 1:6
    one_man_one(oma) = one_man(rni+oma);
end

for omb = 1:rna
    one_man_two(omb+rni) = one_man(rne+omb);
end

one_man_three = perms(one_man_one);

for omc = 1:720
    for omd = 1:rni
        one_man_per(omc,omd) = one_man_two(omd);
    end  
    for ome = 1:6
        one_man_per(omc,rni+ome) = one_man_three(omc,ome);
    end   
    for omf = 1:rna
        one_man_per(omc,rne+omf) = one_man_two(rni+omf);
    end    
    cell_cromut{omc,1} = one_man_per(omc,:);
end

[cell_cromut] = make_dist_apt(cell_cromut,dista_pid);

one_man_mut = cell_cromut(1,:);

end  
%================end===============

%==========apt_for_gene======
function[sum_apt] = apt_for_gene(cell_act)
len_cel = length(cell_act); 
mat_apt = zeros(1,len_cel);
for ju = 1:len_cel
    mat_apt(ju) = cell_act{ju,3};
end
sum_apt = sum(mat_apt);
disp(sum_apt)

end
%=============end==========


end