using PyPlot

function plot_switch(subj_v::Array{subj_t,1})

	switch_d = get_switch_after_incorr(subj_v) ;

	switch_tupl_v = collect(values(switch_d)) ;

	mask_significant = map(x -> x[1] >= x[2], switch_tupl_v) ;

	m_sign = round(mean(map(x->x[5], switch_tupl_v[mask_significant]))) ;
	m_nsign = round(mean(map(x->x[5], switch_tupl_v[.!mask_significant]))) ;

	m_switch = round(mean(map(x->x[6], switch_tupl_v[mask_significant]))) ;
	m_nswitch = round(mean(map(x->x[7], switch_tupl_v[mask_significant]))) ;

	figure()
	ax = gca()
	hist(map(x->x[1], switch_tupl_v[mask_significant]), 25, color = "g", label = "Significant")
	hist(map(x->x[1], switch_tupl_v[.!mask_significant]), 25, color = "b", alpha = 0.2, label = "Not significant")
	xlabel("Switches [%]", fontsize = 16)
	ylabel("N [subjects]", fontsize = 16)
	title("\$ N_{m, significant} = $m_sign , \\qquad N_{m, not significant} = $m_nsign \$", fontsize = 16)
	ax[:tick_params](labelsize = 16)
	legend(fontsize = 16)

	figure()
	ax = gca()
	hist(map(x->x[3], switch_tupl_v), 25, color = "g", label = "Switch")
	hist(map(x->x[4], switch_tupl_v), 25, color = "b", alpha = 0.2, label = "Not switch")
	xlabel("Response time [s]", fontsize = 16)
	ylabel("N [subjects]", fontsize = 16)
	title("\$ N_{m, switch} = $m_switch , \\qquad N_{m, not switch} = $m_nswitch \$", fontsize = 16)
	ax[:tick_params](labelsize = 16)
	legend(fontsize = 16)

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

	m_sign_veh = round(mean(map(x->x[5], switch_veh_tupl_v[mask_significant_veh]))) ;
	m_nsign_veh = round(mean(map(x->x[5], switch_veh_tupl_v[.!mask_significant_veh]))) ;
	m_sign_ket = round(mean(map(x->x[5], switch_ket_tupl_v[mask_significant_ket]))) ;
	m_nsign_ket = round(mean(map(x->x[5], switch_ket_tupl_v[.!mask_significant_ket]))) ;

	m_switch_veh = round(mean(map(x->x[6], switch_veh_tupl_v[mask_significant_veh]))) ;
	m_nswitch_veh = round(mean(map(x->x[7], switch_veh_tupl_v[mask_significant_veh]))) ;
	m_switch_ket = round(mean(map(x->x[6], switch_ket_tupl_v[mask_significant_ket]))) ;
	m_nswitch_ket = round(mean(map(x->x[7], switch_ket_tupl_v[mask_significant_ket]))) ;

	figure()
	ax = gca() 
	plot([1.0,2.0], [mean(work_sign_switch_veh_v[map(x->!isnan(x), work_sign_switch_veh_v)]), 
					mean(work_sign_switch_ket_v[map(x->!isnan(x), work_sign_switch_ket_v)])], 
					"ro-", label = "*Switches, Ketamine worked")
	plot([1.0,2.0], [mean(not_work_sign_switch_veh_v[map(x->!isnan(x), not_work_sign_switch_veh_v)]), 
					mean(not_work_sign_switch_ket_v[map(x->!isnan(x), not_work_sign_switch_ket_v)])], 
					"bo-", label = "*Switches, Ketamine did not work")
	plot([1.0,2.0], [mean(work_not_sign_switch_veh_v[map(x->!isnan(x), work_not_sign_switch_veh_v)]), 
					mean(work_not_sign_switch_ket_v[map(x->!isnan(x), work_not_sign_switch_ket_v)])], 
					"go-", label = "Ketamine worked")
	plot([1.0,2.0], [mean(not_work_not_sign_switch_veh_v[map(x->!isnan(x), not_work_not_sign_switch_veh_v)]), 
					mean(not_work_not_sign_switch_ket_v[map(x->!isnan(x), not_work_not_sign_switch_ket_v)])], 
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
	title("Vehicle , \$ N_{m, significant} = $m_sign_veh , \\qquad N_{m, not significant} = $m_nsign_veh \$", fontsize = 16)
	ax[:tick_params](labelsize = 16)
	legend(fontsize = 16)

	figure()
	ax = gca()
	hist(map(x->x[1], switch_ket_tupl_v[mask_significant_ket]), 25, color = "g", label = "Significant")
	hist(map(x->x[1], switch_ket_tupl_v[.!mask_significant_ket]), 25, color = "b", alpha = 0.2, label = "Not significant")
	xlabel("Switches [%]", fontsize = 16)
	ylabel("N [subjects]", fontsize = 16)
	title("Ketamine , \$ N_{m, significant} = $m_sign_ket , \\qquad N_{m, not significant} = $m_nsign_ket \$", fontsize = 16)
	ax[:tick_params](labelsize = 16)
	legend(fontsize = 16)

	figure()
	ax = gca()
	hist(map(x->x[3], switch_veh_tupl_v), 25, color = "g", label = "Switch")
	hist(map(x->x[4], switch_veh_tupl_v), 25, color = "b", alpha = 0.2, label = "Not switch")
	xlabel("Response time [s]", fontsize = 16)
	ylabel("N [subjects]", fontsize = 16)
	title("Vehicle , \$ N_{m, switch} = $m_switch_veh , \\qquad N_{m, not switch} = $m_nswitch_veh \$", fontsize = 16)
	ax[:tick_params](labelsize = 16)
	legend(fontsize = 16)

	figure()
	ax = gca()
	hist(map(x->x[3], switch_ket_tupl_v), 25, color = "g", label = "Switch")
	hist(map(x->x[4], switch_ket_tupl_v), 25, color = "b", alpha = 0.2, label = "Not switch")
	xlabel("Response time [s]", fontsize = 16)
	ylabel("N [subjects]", fontsize = 16)
	title("Ketamine , \$ N_{m, switch} = $m_switch_ket , \\qquad N_{m, not switch} = $m_nswitch_ket \$", fontsize = 16)
	ax[:tick_params](labelsize = 16)
	legend(fontsize = 16)

	show()
end

function plot_rt(subj_v::Array{subj_t,1})

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

function plot_rt_prev(subj_v::Array{subj_t,1})

	rt_MH_H_v = Array{Float64,1}() ;
	rt_MH_M_v = Array{Float64,1}() ;
	rt_MH_L_v = Array{Float64,1}() ;
	rt_ML_H_v = Array{Float64,1}() ;
	rt_ML_M_v = Array{Float64,1}() ;
	rt_ML_L_v = Array{Float64,1}() ;
	rt_HH_H_v = Array{Float64,1}() ;
	rt_HH_M_v = Array{Float64,1}() ;
	rt_HH_L_v = Array{Float64,1}() ;
	rt_HL_H_v = Array{Float64,1}() ;
	rt_HL_M_v = Array{Float64,1}() ;
	rt_HL_L_v = Array{Float64,1}() ;
	rt_LH_H_v = Array{Float64,1}() ;
	rt_LH_M_v = Array{Float64,1}() ;
	rt_LH_L_v = Array{Float64,1}() ;
	rt_LL_H_v = Array{Float64,1}() ;
	rt_LL_M_v = Array{Float64,1}() ;
	rt_LL_L_v = Array{Float64,1}() ;

	for subj in subj_v

		# mask_Current tone Current press_Previous tone

		mask_MH_H = map((x,y,z,k) -> x == 5 && y == 4 && z == 2 && k != 0, 
			subj.tone_v[2:end], subj.press_v[2:end], subj.tone_v[1:end-1], subj.press_v[1:end-1]) ;
		mask_MH_M = map((x,y,z,k) -> x == 5 && y == 4 && z == 5 && k != 0, 
			subj.tone_v[2:end], subj.press_v[2:end], subj.tone_v[1:end-1], subj.press_v[1:end-1]) ;
		mask_MH_L = map((x,y,z,k) -> x == 5 && y == 4 && z == 8 && k != 0, 
			subj.tone_v[2:end], subj.press_v[2:end], subj.tone_v[1:end-1], subj.press_v[1:end-1]) ;

		mask_ML_H = map((x,y,z,k) -> x == 5 && y == 1 && z == 2 && k != 0, 
			subj.tone_v[2:end], subj.press_v[2:end], subj.tone_v[1:end-1], subj.press_v[1:end-1]) ;
		mask_ML_M = map((x,y,z,k) -> x == 5 && y == 1 && z == 5 && k != 0, 
			subj.tone_v[2:end], subj.press_v[2:end], subj.tone_v[1:end-1], subj.press_v[1:end-1]) ;
		mask_ML_L = map((x,y,z,k) -> x == 5 && y == 1 && z == 8 && k != 0, 
			subj.tone_v[2:end], subj.press_v[2:end], subj.tone_v[1:end-1], subj.press_v[1:end-1]) ;

		mask_HH_H = map((x,y,z,k) -> x == 2 && y == 4 && z == 2 && k != 0, 
			subj.tone_v[2:end], subj.press_v[2:end], subj.tone_v[1:end-1], subj.press_v[1:end-1]) ;
		mask_HH_M = map((x,y,z,k) -> x == 2 && y == 4 && z == 5 && k != 0, 
			subj.tone_v[2:end], subj.press_v[2:end], subj.tone_v[1:end-1], subj.press_v[1:end-1]) ;
		mask_HH_L = map((x,y,z,k) -> x == 2 && y == 4 && z == 8 && k != 0, 
			subj.tone_v[2:end], subj.press_v[2:end], subj.tone_v[1:end-1], subj.press_v[1:end-1]) ;

		mask_HL_H = map((x,y,z,k) -> x == 2 && y == 1 && z == 2 && k != 0, 
			subj.tone_v[2:end], subj.press_v[2:end], subj.tone_v[1:end-1], subj.press_v[1:end-1]) ;
		mask_HL_M = map((x,y,z,k) -> x == 2 && y == 1 && z == 5 && k != 0, 
			subj.tone_v[2:end], subj.press_v[2:end], subj.tone_v[1:end-1], subj.press_v[1:end-1]) ;
		mask_HL_L = map((x,y,z,k) -> x == 2 && y == 1 && z == 8 && k != 0, 
			subj.tone_v[2:end], subj.press_v[2:end], subj.tone_v[1:end-1], subj.press_v[1:end-1]) ;

		mask_LH_H = map((x,y,z,k) -> x == 8 && y == 4 && z == 2 && k != 0, 
			subj.tone_v[2:end], subj.press_v[2:end], subj.tone_v[1:end-1], subj.press_v[1:end-1]) ;
		mask_LH_M = map((x,y,z,k) -> x == 8 && y == 4 && z == 5 && k != 0, 
			subj.tone_v[2:end], subj.press_v[2:end], subj.tone_v[1:end-1], subj.press_v[1:end-1]) ;
		mask_LH_L = map((x,y,z,k) -> x == 8 && y == 4 && z == 8 && k != 0, 
			subj.tone_v[2:end], subj.press_v[2:end], subj.tone_v[1:end-1], subj.press_v[1:end-1]) ;

		mask_LL_H = map((x,y,z,k) -> x == 8 && y == 1 && z == 2 && k != 0, 
			subj.tone_v[2:end], subj.press_v[2:end], subj.tone_v[1:end-1], subj.press_v[1:end-1]) ;
		mask_LL_M = map((x,y,z,k) -> x == 8 && y == 1 && z == 5 && k != 0, 
			subj.tone_v[2:end], subj.press_v[2:end], subj.tone_v[1:end-1], subj.press_v[1:end-1]) ;
		mask_LL_L = map((x,y,z,k) -> x == 8 && y == 1 && z == 8 && k != 0, 
			subj.tone_v[2:end], subj.press_v[2:end], subj.tone_v[1:end-1], subj.press_v[1:end-1]) ;
		
		pushfirst!(mask_MH_H, false) ;
		pushfirst!(mask_MH_M, false) ;
		pushfirst!(mask_MH_L, false) ;
		pushfirst!(mask_ML_H, false) ;
		pushfirst!(mask_ML_M, false) ;
		pushfirst!(mask_ML_L, false) ;
		pushfirst!(mask_HH_H, false) ;
		pushfirst!(mask_HH_M, false) ;
		pushfirst!(mask_HH_L, false) ;
		pushfirst!(mask_HL_H, false) ;
		pushfirst!(mask_HL_M, false) ;
		pushfirst!(mask_HL_L, false) ;
		pushfirst!(mask_LH_H, false) ;
		pushfirst!(mask_LH_M, false) ;
		pushfirst!(mask_LH_L, false) ;
		pushfirst!(mask_LL_H, false) ;
		pushfirst!(mask_LL_M, false) ;
		pushfirst!(mask_LL_L, false) ;		

		push!(rt_MH_H_v, mean(subj.rt_v[mask_MH_H])) ;
		push!(rt_MH_M_v, mean(subj.rt_v[mask_MH_M])) ;
		push!(rt_MH_L_v, mean(subj.rt_v[mask_MH_L])) ;
		push!(rt_ML_H_v, mean(subj.rt_v[mask_ML_H])) ;
		push!(rt_ML_M_v, mean(subj.rt_v[mask_ML_M])) ;
		push!(rt_ML_L_v, mean(subj.rt_v[mask_ML_L])) ;
		push!(rt_HH_H_v, mean(subj.rt_v[mask_HH_H])) ;
		push!(rt_HH_M_v, mean(subj.rt_v[mask_HH_M])) ;
		push!(rt_HH_L_v, mean(subj.rt_v[mask_HH_L])) ;
		push!(rt_HL_H_v, mean(subj.rt_v[mask_HL_H])) ;
		push!(rt_HL_M_v, mean(subj.rt_v[mask_HL_M])) ;
		push!(rt_HL_L_v, mean(subj.rt_v[mask_HL_L])) ;
		push!(rt_LH_H_v, mean(subj.rt_v[mask_LH_H])) ;
		push!(rt_LH_M_v, mean(subj.rt_v[mask_LH_M])) ;
		push!(rt_LH_L_v, mean(subj.rt_v[mask_LH_L])) ;
		push!(rt_LL_H_v, mean(subj.rt_v[mask_LL_H])) ;
		push!(rt_LL_M_v, mean(subj.rt_v[mask_LL_M])) ;
		push!(rt_LL_L_v, mean(subj.rt_v[mask_LL_L])) ;
	end

	figure()
	ax = gca()
	x_ticks = [0.5, 1.0, 1.5] ;
	scatter(fill(x_ticks[1],length(rt_HH_H_v)), rt_HH_H_v, color = "red") ;
	scatter(fill(x_ticks[2],length(rt_HH_M_v)), rt_HH_M_v, color = "blue") ;
	scatter(fill(x_ticks[3],length(rt_HH_L_v)), rt_HH_L_v, color = "green") ;

	x_ticks .+= 3.0 ;
	scatter(fill(x_ticks[1],length(rt_HL_H_v)), rt_HL_H_v, color = "red") ;
	scatter(fill(x_ticks[2],length(rt_HL_M_v)), rt_HL_M_v, color = "blue") ;
	scatter(fill(x_ticks[3],length(rt_HL_L_v)), rt_HL_L_v, color = "green") ;

	x_ticks .+= 3.0 ;
	scatter(fill(x_ticks[1],length(rt_MH_H_v)), rt_MH_H_v, color = "red") ;
	scatter(fill(x_ticks[2],length(rt_MH_M_v)), rt_MH_M_v, color = "blue") ;
	scatter(fill(x_ticks[3],length(rt_MH_L_v)), rt_MH_L_v, color = "green") ;

	x_ticks .+= 3.0 ;
	scatter(fill(x_ticks[1],length(rt_ML_H_v)), rt_ML_H_v, color = "red") ;
	scatter(fill(x_ticks[2],length(rt_ML_M_v)), rt_ML_M_v, color = "blue") ;
	scatter(fill(x_ticks[3],length(rt_ML_L_v)), rt_ML_L_v, color = "green") ;

	x_ticks .+= 3.0 ;
	scatter(fill(x_ticks[1],length(rt_LH_H_v)), rt_LH_H_v, color = "red") ;
	scatter(fill(x_ticks[2],length(rt_LH_M_v)), rt_LH_M_v, color = "blue") ;
	scatter(fill(x_ticks[3],length(rt_LH_L_v)), rt_LH_L_v, color = "green") ;

	x_ticks .+= 3.0 ;
	scatter(fill(x_ticks[1],length(rt_LL_H_v)), rt_LL_H_v, color = "red", label = "High previous") ;
	scatter(fill(x_ticks[2],length(rt_LL_M_v)), rt_LL_M_v, color = "blue", label = "Mid previous") ;
	scatter(fill(x_ticks[3],length(rt_LL_L_v)), rt_LL_L_v, color = "green", label = "Low previous") ;

	ax[:set_xticks]([x_ticks[2] - 5.0*3.0, x_ticks[2] - 4.0*3.0, x_ticks[2] - 3.0*3.0, 
		x_ticks[2] - 2.0*3.0, x_ticks[2] - 1.0*3.0, x_ticks[2]])
	ax[:set_xticklabels](["High tone \n High Press", "High tone \n Low Press",
						"Mid tone \n High Press", "Mid tone \n Low Press",
						"Low tone \n High Press", "Low tone \n Low Press"])
	ax[:tick_params](labelsize = 16)
	legend()
	show()
end

function plot_psychometric(subj_psycho_v::Array{subj_psycho_t,1})


	n_tones = size(subj_psycho_v[1].acc_m, 1) ;
	n_subj = length(subj_psycho_v) ;

	r4_m = Matrix{Float64}(undef, n_tones, n_subj) ;
	rt_m = Matrix{Float64}(undef, n_tones, n_subj) ;

	i = 1 ;
	for subj in subj_psycho_v 
		r4_m[:, i] = subj.acc_m[:,1] ;
		rt_m[:, i] = subj.rt_m[:,1] ;

		i += 1 ;
	end

	figure()
	ax = gca()
	x_ticks = [0.0 + i for i in 1:n_tones] ;

	for tone = 1 : n_tones
		scatter(fill(x_ticks[tone], n_subj), r4_m[tone,:], alpha = 0.5)
		errorbar(x_ticks[tone], mean(r4_m[tone,:]), yerr = std(r4_m[tone,:]), 
				marker = "D", markersize = 10, capsize = 10)
	end

	figure()
	ax = gca()
	x_ticks = [0.0 + i for i in 1:n_tones] ;

	for tone = 1 : n_tones
		scatter(fill(x_ticks[tone], n_subj), rt_m[tone,:], alpha = 0.5)
		errorbar(x_ticks[tone], mean(rt_m[tone,:]), yerr = std(rt_m[tone,:]), 
				marker = "D", markersize = 10, capsize = 10)
	end

	show()
end

function plot_mi(mi_pr_v::Array{Float64,1}, mi_pp_v::Array{Float64,1}, mi_prp_v::Array{Float64,1}, 
				mi_ppr_v::Array{Float64,1}, ci_pr_v::Array{Tuple{Float64,Float64},1}, 
				ci_pp_v::Array{Tuple{Float64,Float64},1}, ci_prp_v::Array{Tuple{Float64,Float64},1},
				ci_ppr_v::Array{Tuple{Float64,Float64},1}, 
				mi_pt_v::Array{Float64,1}, ci_pt_v::Array{Tuple{Float64,Float64},1},
				n_trials_in_the_past::Int64)

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

	figure()
	scatter(1:n_trials_in_the_past, mi_pt_v, label = "Actual I")
	scatter((1:n_trials_in_the_past, 1:n_trials_in_the_past), ci_pt_v, label = "Shuffled confidence interval")
	xticks(x_ticks, [string(i) for i in 1:n_trials_in_the_past])
	xlabel("Trials in the past", fontsize = 16)
	ylabel("I", fontsize = 16)
	title("Press ; past tone", fontsize = 16)
	legend()
	
	show()
end

