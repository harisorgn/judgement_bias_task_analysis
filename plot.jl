using PyPlot

function plot_switch(subj_v::Array{subj_t,1})

	switch_d = get_switch_after_incorr(subj_v) ;

	switch_tupl_v = collect(values(switch_d)) ;

	mask_significant = map(x -> x[1] >= x[2], switch_tupl_v) ;

	figure()
	ax = gca()
	hist(map(x->x[1], switch_tupl_v[mask_significant]), 25, color = "g", label = "Significant")
	hist(map(x->x[1], switch_tupl_v[.!mask_significant]), 25, color = "b", alpha = 0.2, label = "Not significant")
	xlabel("Switches [%]", fontsize = 16)
	ylabel("N [subjects]", fontsize = 16)
	ax[:tick_params](labelsize = 16)
	legend(fontsize = 16)

	figure()
	ax = gca()
	hist(map(x->x[3], switch_tupl_v), 25, color = "g", label = "Switch")
	hist(map(x->x[4], switch_tupl_v), 25, color = "b", alpha = 0.2, label = "Not switch")
	xlabel("Response time [s]", fontsize = 16)
	ylabel("N [subjects]", fontsize = 16)
	ax[:tick_params](labelsize = 16)
	legend(fontsize = 16)

	figure()
	ax = gca()
	hist(map(x->x[5], switch_tupl_v), color = "g")
	xlabel("N [switches]", fontsize = 16)
	ylabel("N [subjects]", fontsize = 16)
	ax[:tick_params](labelsize = 16)

	show()
end

function plot_ket_switch(subj_veh_v::Array{subj_t,1}, subj_ket_v::Array{subj_t,1})

	switch_veh_d = get_switch_after_incorr(subj_veh_v) ;

	switch_veh_tupl_v = collect(values(switch_veh_d)) ;

	mask_significant_veh = map(x -> x[1] >= x[2], switch_veh_tupl_v) ;

	switch_ket_d = get_switch_after_incorr(subj_ket_v) ;

	switch_ket_tupl_v = collect(values(switch_ket_d)) ;

	mask_significant_ket = map(x -> x[1] >= x[2], switch_ket_tupl_v) ;

	work_sign_switch_veh_v = Array{Float64,1}() ;
	work_sign_switch_ket_v = Array{Float64,1}() ;
	not_work_sign_switch_veh_v = Array{Float64,1}() ;
	not_work_sign_switch_ket_v = Array{Float64,1}() ;

	work_not_sign_switch_veh_v = Array{Float64,1}() ;
	work_not_sign_switch_ket_v = Array{Float64,1}() ;
	not_work_not_sign_switch_veh_v = Array{Float64,1}() ;
	not_work_not_sign_switch_ket_v = Array{Float64,1}() ;

	for subj_veh in subj_veh_v

		subj_ket_idx = findfirst(x -> x.id == subj_veh.id, subj_ket_v) ;
		subj_ket = subj_ket_v[subj_ket_idx] ;

		if subj_veh.cbi < subj_ket.cbi
			if switch_veh_d[subj_veh.id][1] >= switch_veh_d[subj_veh.id][2]
				push!(work_sign_switch_veh_v, switch_veh_d[subj_veh.id][1]) ;
				push!(work_sign_switch_ket_v, switch_ket_d[subj_veh.id][1]) ;
			else
				push!(work_not_sign_switch_veh_v, switch_veh_d[subj_veh.id][1]) ;
				push!(work_not_sign_switch_ket_v, switch_ket_d[subj_veh.id][1]) ;
			end
		else
			if switch_veh_d[subj_veh.id][1] >= switch_veh_d[subj_veh.id][2]
				push!(not_work_sign_switch_veh_v, switch_veh_d[subj_veh.id][1]) ;
				push!(not_work_sign_switch_ket_v, switch_ket_d[subj_veh.id][1]) ;
			else
				push!(not_work_not_sign_switch_veh_v, switch_veh_d[subj_veh.id][1]) ;
				push!(not_work_not_sign_switch_ket_v, switch_ket_d[subj_veh.id][1]) ;
			end
		end
	end


	figure()
	ax = gca() 
	plot([1.0,2.0], [mean(work_sign_switch_veh_v), mean(work_sign_switch_ket_v)], 
		"ro-", label = "*Switches, Ketamine worked")
	plot([1.0,2.0], [mean(not_work_sign_switch_veh_v), mean(not_work_sign_switch_ket_v)], 
		"bo-", label = "*Switches, Ketamine did not work")
	plot([1.0,2.0], [mean(work_not_sign_switch_veh_v), mean(work_not_sign_switch_ket_v)], 
		"go-", label = "Ketamine worked")
	plot([1.0,2.0], [mean(not_work_not_sign_switch_veh_v), mean(not_work_not_sign_switch_ket_v)], 
		"ko-", label = "Ketamine did not work")

	ylabel("Switches [%]", fontsize = 16)
	ax[:set_xticks]([1.0, 2.0])
	ax[:set_xticklabels](["Vehicle", "Ketamine"])
	ax[:tick_params](labelsize = 16)
	legend(fontsize = 16)


	figure()
	ax = gca()
	hist(map(x->x[1], switch_veh_tupl_v[mask_significant_veh]), 25, color = "g", label = "Significant")
	hist(map(x->x[1], switch_veh_tupl_v[.!mask_significant_veh]), 25, color = "b", alpha = 0.2, label = "Not significant")
	xlabel("Switches [%]", fontsize = 16)
	ylabel("N [subjects]", fontsize = 16)
	title("Vehicle", fontsize = 16)
	ax[:tick_params](labelsize = 16)
	legend(fontsize = 16)

	figure()
	ax = gca()
	hist(map(x->x[1], switch_ket_tupl_v[mask_significant_ket]), 25, color = "g", label = "Significant")
	hist(map(x->x[1], switch_ket_tupl_v[.!mask_significant_ket]), 25, color = "b", alpha = 0.2, label = "Not significant")
	xlabel("Switches [%]", fontsize = 16)
	ylabel("N [subjects]", fontsize = 16)
	title("Ketamine", fontsize = 16)
	ax[:tick_params](labelsize = 16)
	legend(fontsize = 16)

	figure()
	ax = gca()
	hist(map(x->x[3], switch_veh_tupl_v), 25, color = "g", label = "Switch")
	hist(map(x->x[4], switch_veh_tupl_v), 25, color = "b", alpha = 0.2, label = "Not switch")
	xlabel("Response time [s]", fontsize = 16)
	ylabel("N [subjects]", fontsize = 16)
	title("Vehicle", fontsize = 16)
	ax[:tick_params](labelsize = 16)
	legend(fontsize = 16)

	figure()
	ax = gca()
	hist(map(x->x[3], switch_ket_tupl_v), 25, color = "g", label = "Switch")
	hist(map(x->x[4], switch_ket_tupl_v), 25, color = "b", alpha = 0.2, label = "Not switch")
	xlabel("Response time [s]", fontsize = 16)
	ylabel("N [subjects]", fontsize = 16)
	title("Ketamine", fontsize = 16)
	ax[:tick_params](labelsize = 16)
	legend(fontsize = 16)

	show()
end

function plot_mid_rt(subj_v::Array{subj_t,1})

	rt_MH_v = Array{Float64,1}() ;
	rt_ML_v = Array{Float64,1}() ;
	rt_HH_v = Array{Float64,1}() ;
	rt_LL_v = Array{Float64,1}() ;

	for subj in subj_v
		mask_MH = map((x,y) -> x == 5 && y == 4, subj.tone_v, subj.press_v) ;
		mask_ML = map((x,y) -> x == 5 && y == 1, subj.tone_v, subj.press_v) ;
		mask_HH = map((x,y) -> x == 2 && y == 4, subj.tone_v, subj.press_v) ;
		mask_LL = map((x,y) -> x == 8 && y == 1, subj.tone_v, subj.press_v) ;

		push!(rt_MH_v, mean(subj.rt_v[mask_MH])) ;
		push!(rt_ML_v, mean(subj.rt_v[mask_ML])) ;
		push!(rt_HH_v, mean(subj.rt_v[mask_HH])) ;
		push!(rt_LL_v, mean(subj.rt_v[mask_LL])) ;
	end

	figure()
	scatter(fill(1,length(rt_HH_v)), rt_HH_v) ;
	scatter(fill(2,length(rt_MH_v)), rt_MH_v) ;
	scatter(fill(3,length(rt_ML_v)), rt_ML_v) ;
	scatter(fill(4,length(rt_LL_v)), rt_LL_v) ;

	errorbar(1, mean(rt_HH_v), fmt = "C0D", markersize = 10, capsize = 10)
	errorbar(2, mean(rt_MH_v), fmt = "C1D", markersize = 10, capsize = 10)
	errorbar(3, mean(rt_ML_v[map(x->!isnan(x), rt_ML_v)]), fmt = "C2D", markersize = 10, capsize = 10)
	errorbar(4, mean(rt_LL_v), fmt = "C3D", markersize = 10, capsize = 10)
end

function plot_mi(mi_pr_v::Array{Float64,1}, mi_pp_v::Array{Float64,1}, mi_prp_v::Array{Float64,1}, 
				mi_ppr_v::Array{Float64,1}, ci_pr_v::Array{Tuple{Float64,Float64},1}, 
				ci_pp_v::Array{Tuple{Float64,Float64},1}, ci_prp_v::Array{Tuple{Float64,Float64},1},
				ci_ppr_v::Array{Tuple{Float64,Float64},1}, n_trials_in_the_past::Int64)

	x_ticks = 1:n_trials_in_the_past

	figure()
	scatter(1:n_trials_in_the_past, mi_pr_v, label = "Actual I")
	scatter((1:n_trials_in_the_past, 1:n_trials_in_the_past), ci_pr_v, label = "Shuffled confidence interval")
	xticks(x_ticks, [string(i) for i in 1:n_trials_in_the_past])
	xlabel("Trials in the past", fontsize = 16)
	ylabel("I", fontsize = 16)
	title("Press ; past reward", fontsize = 16)
	legend()

	figure()
	scatter(1:n_trials_in_the_past, mi_pp_v, label = "Actual I")
	scatter((1:n_trials_in_the_past, 1:n_trials_in_the_past), ci_pp_v, label = "Shuffled confidence interval")
	xticks(x_ticks, [string(i) for i in 1:n_trials_in_the_past])
	xlabel("Trials in the past", fontsize = 16)
	ylabel("I", fontsize = 16)
	title("Press ; past press", fontsize = 16)
	legend()

	figure()
	scatter(1:n_trials_in_the_past, mi_prp_v, label = "Actual I")
	scatter((1:n_trials_in_the_past, 1:n_trials_in_the_past), ci_prp_v, label = "Shuffled confidence interval")
	xticks(x_ticks, [string(i) for i in 1:n_trials_in_the_past])
	xlabel("Trials in the past", fontsize = 16)
	ylabel("I", fontsize = 16)
	title("Press ; past reward | past press", fontsize = 16)
	legend()

	figure()
	scatter(1:n_trials_in_the_past, mi_ppr_v, label = "Actual I")
	scatter((1:n_trials_in_the_past, 1:n_trials_in_the_past), ci_ppr_v, label = "Shuffled confidence interval")
	xticks(x_ticks, [string(i) for i in 1:n_trials_in_the_past])
	xlabel("Trials in the past", fontsize = 16)
	ylabel("I", fontsize = 16)
	title("Press ; past press | past reward", fontsize = 16)
	legend()
	
	show()
end

