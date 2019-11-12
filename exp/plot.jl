using PyPlot

nanmean(x) = mean(filter(!isnan,x))
nanmean(x,y) = mapslices(nanmean,x;dims = y)

nanstd(x) = std(filter(!isnan,x))
nanstd(x,y) = mapslices(nanstd,x;dims = y)

function plot_block_data(session_subj_v::Array{Array{subj_t,1},1}, block_sz::Int64,
						session_labels::Array{String,1})
	
	n_blocks = Int64(120 / block_sz) ;

	figure()
	ax = gca()

	x_ticks = 1 : n_blocks ;
	x_tick_labels = ["Block $(i)" for j = 1 : length(session_subj_v) for i = 1 : n_blocks] ;
	x_tick_labels[Int64(ceil(n_blocks/2)) : n_blocks : end] .*= ["\n \n $(session_labels[i])"
																for i = 1 : length(session_subj_v)] ;

	session = 1 ;

	for subj_v in session_subj_v
		session_hh_m = get_block_data(subj_v, block_sz, 2, 2) ;
		session_mh_m = get_block_data(subj_v, block_sz, 5, 2) ;
		session_ml_m = get_block_data(subj_v, block_sz, 5, 8) ;
		session_ll_m = get_block_data(subj_v, block_sz, 8, 8) ;

		plot(x_ticks .+ (session - 1)*n_blocks, nanmean(session_mh_m, 1)[:], "-r")
		plot(x_ticks .+ (session - 1)*n_blocks, nanmean(session_ml_m, 1)[:], "-b")

		if session == 1
			errorbar(x_ticks .+ (session - 1)*n_blocks, nanmean(session_mh_m, 1)[:], 
				yerr = nanstd(session_mh_m, 1)[:]./size(session_mh_m, 1), 
				marker = "D", markersize = 10, capsize = 10, color = "red", label = "High reward responses", 
				linestyle = "")

			errorbar(x_ticks .+ (session - 1)*n_blocks, nanmean(session_ml_m, 1)[:], 
				yerr = nanstd(session_ml_m, 1)[:]./size(session_ml_m, 1), 
				marker = "D", markersize = 10, capsize = 10, color = "blue", label = "Low reward responses", 
				linestyle = "")
		else
			errorbar(x_ticks .+ (session - 1)*n_blocks, nanmean(session_mh_m, 1)[:], 
				yerr = nanstd(session_mh_m, 1)[:]./size(session_mh_m, 1), 
				marker = "D", markersize = 10, capsize = 10, color = "red", label = "", 
				linestyle = "")

			errorbar(x_ticks .+ (session - 1)*n_blocks, nanmean(session_ml_m, 1)[:], 
				yerr = nanstd(session_ml_m, 1)[:]./size(session_ml_m, 1), 
				marker = "D", markersize = 10, capsize = 10, color = "blue", label = "", 
				linestyle = "")
		end
		

		session += 1 ;
	end

	legend(fontsize = 18, frameon = false)
	ylabel("Percentage responses", fontsize = 18)

	ax.set_ylim([20.0, 80.0])

	ax[:set_xticks](1 : length(session_subj_v) * n_blocks)
	ax[:set_xticklabels](x_tick_labels)
	ax[:tick_params](labelsize = 18)

	show()
	#=
	(s1_hh_m, s1_hh_rt_m) = get_block_resp_rt(s1_subj_v, 2, 2) ;
	(s1_mh_m, s1_mh_rt_m) = get_block_resp_rt(s1_subj_v, 5, 2) ;
	(s1_ml_m, s1_ml_rt_m) = get_block_resp_rt(s1_subj_v, 5, 8) ;
	(s1_ll_m, s1_ll_rt_m) = get_block_resp_rt(s1_subj_v, 8, 8) ;

	(s2_hh_m, s2_hh_rt_m) = get_block_resp_rt(s2_subj_v, 2, 2) ;
	(s2_mh_m, s2_mh_rt_m) = get_block_resp_rt(s2_subj_v, 5, 2) ;
	(s2_ml_m, s2_ml_rt_m) = get_block_resp_rt(s2_subj_v, 5, 8) ;
	(s2_ll_m, s2_ll_rt_m) = get_block_resp_rt(s2_subj_v, 8, 8) ;

	x_ticks = 1:10 ;
	
	figure()
	ax = gca()
	#=
	errorbar(x_ticks, vcat(nanmean(s1_hh_m, 1)[:], nanmean(s2_hh_m, 1)[:]), 
		yerr = vcat(nanstd(s1_hh_m, 1)[:]./size(s1_hh_m, 1), nanstd(s2_hh_m, 1)[:]./size(s2_hh_m, 1)), 
		marker = "D", markersize = 10, capsize = 10, color = "red", label = "HT-HR", linestyle = "")

	plot(x_ticks[1:5], nanmean(s1_hh_m, 1)[:], "-r")
	plot(x_ticks[6:10], nanmean(s2_hh_m, 1)[:], "-r")

	errorbar(x_ticks, vcat(nanmean(s1_ll_m, 1)[:], nanmean(s2_ll_m, 1)[:]), 
		yerr = vcat(nanstd(s1_ll_m, 1)[:]./size(s1_ll_m, 1), nanstd(s2_ll_m, 1)[:]./size(s2_ll_m, 1)), 
		marker = "D", markersize = 10, capsize = 10, color = "blue", label = "LT-LR", linestyle = "")

	plot(x_ticks[1:5], nanmean(s1_ll_m, 1)[:], "-b")
	plot(x_ticks[6:10], nanmean(s2_ll_m, 1)[:], "-b")
	=#
	errorbar(x_ticks, vcat(nanmean(s1_mh_m, 1)[:], nanmean(s2_mh_m, 1)[:]), 
		yerr = vcat(nanstd(s1_mh_m, 1)[:]./size(s1_mh_m, 1), nanstd(s2_mh_m, 1)[:]./size(s2_mh_m, 1)), 
		marker = "D", markersize = 10, capsize = 10, color = "red", label = "High reward responses", linestyle = "")

	plot(x_ticks[1:5], nanmean(s1_mh_m, 1)[:], "-r")
	plot(x_ticks[6:10], nanmean(s2_mh_m, 1)[:], "-r")
	
	errorbar(x_ticks, vcat(nanmean(s1_ml_m, 1)[:], nanmean(s2_ml_m, 1)[:]), 
		yerr = vcat(nanstd(s1_ml_m, 1)[:]./size(s1_ml_m, 1), nanstd(s2_ml_m, 1)[:]./size(s2_ml_m, 1)), 
		marker = "D", markersize = 10, capsize = 10, color = "blue", label = "Low reward responses", linestyle = "")

	plot(x_ticks[1:5], nanmean(s1_ml_m, 1)[:], "-b")
	plot(x_ticks[6:10], nanmean(s2_ml_m, 1)[:], "-b")

	legend(fontsize = 18, frameon = false)
	ylabel("Percentage responses", fontsize = 18)
	title("Main effect of ketamine", fontsize = 18)

	ax.set_ylim([20.0, 80.0])
	ax[:set_xticks](x_ticks)
	ax[:set_xticklabels](["Block 1", "Block 2", "Block 3 \n \n Vehicle session", "Block 4", "Block 5",
						"Block 1", "Block 2", "Block 3 \n \n Ketamine (1.0 mg/kg) session", "Block 4", "Block 5"])
	ax[:tick_params](labelsize = 18)

	figure()
	ax = gca()

	errorbar(x_ticks, vcat(nanmean(s1_hh_rt_m, 1)[:], nanmean(s2_hh_rt_m, 1)[:]), 
		yerr = vcat(nanstd(s1_hh_rt_m, 1)[:]./size(s1_hh_rt_m, 1), nanstd(s2_hh_rt_m, 1)[:]./size(s2_hh_rt_m, 1)), 
		marker = "D", markersize = 10, capsize = 10, color = "red", label = "HT-HR", linestyle = "")

	plot(x_ticks[1:5], nanmean(s1_hh_rt_m, 1)[:], "-r")
	plot(x_ticks[6:10], nanmean(s2_hh_rt_m, 1)[:], "-r")

	errorbar(x_ticks, vcat(nanmean(s1_mh_rt_m, 1)[:], nanmean(s2_mh_rt_m, 1)[:]), 
		yerr = vcat(nanstd(s1_mh_rt_m, 1)[:]./size(s1_mh_rt_m, 1), nanstd(s2_mh_rt_m, 1)[:]./size(s2_mh_rt_m, 1)), 
		marker = "D", markersize = 10, capsize = 10, color = "green", label = "MT-HR", linestyle = "")

	plot(x_ticks[1:5], nanmean(s1_mh_rt_m, 1)[:], "-g")
	plot(x_ticks[6:10], nanmean(s2_mh_rt_m, 1)[:], "-g")

	errorbar(x_ticks, vcat(nanmean(s1_ml_rt_m, 1)[:], nanmean(s2_ml_rt_m, 1)[:]), 
		yerr = vcat(nanstd(s1_ml_rt_m, 1)[:]./size(s1_ml_rt_m, 1), nanstd(s2_ml_rt_m, 1)[:]./size(s2_ml_rt_m, 1)), 
		marker = "D", markersize = 10, capsize = 10, color = "cyan", label = "MT-LR", linestyle = "")

	plot(x_ticks[1:5], nanmean(s1_ml_rt_m, 1)[:], "-c")
	plot(x_ticks[6:10], nanmean(s2_ml_rt_m, 1)[:], "-c")

	errorbar(x_ticks, vcat(nanmean(s1_ll_rt_m, 1)[:], nanmean(s2_ll_rt_m, 1)[:]), 
		yerr = vcat(nanstd(s1_ll_rt_m, 1)[:]./size(s1_ll_rt_m, 1), nanstd(s2_ll_rt_m, 1)[:]./size(s2_ll_rt_m, 1)), 
		marker = "D", markersize = 10, capsize = 10, color = "blue", label = "LT-LR", linestyle = "")

	plot(x_ticks[1:5], nanmean(s1_ll_rt_m, 1)[:], "-b")
	plot(x_ticks[6:10], nanmean(s2_ll_rt_m, 1)[:], "-b")

	legend(fontsize = 18, frameon = false)
	ylabel("Response latency [s]", fontsize = 18)
	#title("No main effect", fontsize = 18)
	ax.set_ylim([0.0, 7.5])

	ax[:set_xticks](x_ticks)
	ax[:set_xticklabels](["Block 1", "Block 2", "Block 3 \n First probe session", "Block 4", "Block 5",
						"Block 1", "Block 2", "Block 3 \n Second probe session", "Block 4", "Block 5"])
	ax[:tick_params](labelsize = 18)

	show()
	=#
end

function plot_crf(session_subj_v::Array{Array{subj_t,1},1})


	rt_session1 = [mean(filter(x -> x > 0.0001, subj.rt_v)) for subj in session_subj_v[1]] ;
	rt_session2 = [mean(filter(x -> x > 0.0001, subj.rt_v)) for subj in session_subj_v[2]] ;

	figure()
	ax = gca()
	#=
	scatter(fill(1.0, length(rt_session1)), rt_session1, color = "red")
	scatter(fill(2.0, length(rt_session2)), rt_session2, color = "blue")

	errorbar(1.0, mean(rt_session1), yerr = std(rt_session1), color = "red", marker = "D")
	errorbar(2.0, mean(rt_session2), yerr = std(rt_session2), color = "blue", marker = "D")
	=#
	for i = 1 : length(session_subj_v[1])
		errorbar(1.0, rt_session1[i], yerr = std(filter(x -> x > 0.0001, session_subj_v[1][i].rt_v)), 
				color = "red", marker = "D")
		errorbar(2.0, rt_session2[i], yerr = std(filter(x -> x > 0.0001, session_subj_v[2][i].rt_v)), 
				color = "red", marker = "D")
	end

	show()
end

function plot_rr(subj_v::Array{subj_t,1}, n_trials_in_the_past::Int64)

	rr_v = Array{Float64,1}() ;
	rt_v = Array{Float64,1}() ;
	mask_MH = Array{Bool,1}() ;
	mask_ML = Array{Bool,1}() ;

	for subj in subj_v
		
		push!(rr_v, 0.0)

		for i = 2 : n_trials_in_the_past
			push!(rr_v, sum(subj.reward_v[1:i-1]) / sum(subj.rt_v[1:i-1])) ;
		end

		for i = n_trials_in_the_past + 1 : length(subj.tone_v)
			push!(rr_v, sum(subj.reward_v[i - n_trials_in_the_past : i - 1]) / 
						sum(subj.rt_v[i - n_trials_in_the_past : i - 1])) ;
		end
		append!(rt_v, subj.rt_v) ;
		append!(mask_MH, map((x,y) -> x == 5 && y == 2, subj.tone_v, subj.response_v)) ;
		append!(mask_ML, map((x,y) -> x == 5 && y == 8, subj.tone_v, subj.response_v)) ;
		#append!(mask_MH, map((x,y) -> x == 3 || x == 4 || x == 6 || x == 7 && y == 2, 
		#				subj.tone_v, subj.response_v)) ;
		#append!(mask_ML, map((x,y) -> x == 3 || x == 4 || x == 6 || x == 7 && y == 8, 
		#				subj.tone_v, subj.response_v)) ;
	end

	figure()
	ax = gca()

	plot(rr_v[mask_MH], rt_v[mask_MH], "*r")
	plot(rr_v[mask_ML], rt_v[mask_ML], "*b")

	show()

end

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
		mask_MH = map((x,y) -> x == 5 && y == 2, subj.tone_v, subj.response_v) ;
		mask_ML = map((x,y) -> x == 5 && y == 8, subj.tone_v, subj.response_v) ;
		mask_HH = map((x,y) -> x == 2 && y == 2, subj.tone_v, subj.response_v) ;
		mask_LL = map((x,y) -> x == 8 && y == 8, subj.tone_v, subj.response_v) ;

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

	show()
end

function plot_rt_prev_tone(subj_v::Array{subj_t,1})

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

		# mask_Current tone Current response_Previous tone

		mask_MH_H = map((x,y,z,k) -> x == 5 && y == 2 && z == 2 && k != 0, 
			subj.tone_v[2:end], subj.response_v[2:end], subj.tone_v[1:end-1], subj.response_v[1:end-1]) ;
		mask_MH_M = map((x,y,z,k) -> x == 5 && y == 2 && z == 5 && k != 0, 
			subj.tone_v[2:end], subj.response_v[2:end], subj.tone_v[1:end-1], subj.response_v[1:end-1]) ;
		mask_MH_L = map((x,y,z,k) -> x == 5 && y == 2 && z == 8 && k != 0, 
			subj.tone_v[2:end], subj.response_v[2:end], subj.tone_v[1:end-1], subj.response_v[1:end-1]) ;

		mask_ML_H = map((x,y,z,k) -> x == 5 && y == 8 && z == 2 && k != 0, 
			subj.tone_v[2:end], subj.response_v[2:end], subj.tone_v[1:end-1], subj.response_v[1:end-1]) ;
		mask_ML_M = map((x,y,z,k) -> x == 5 && y == 8 && z == 5 && k != 0, 
			subj.tone_v[2:end], subj.response_v[2:end], subj.tone_v[1:end-1], subj.response_v[1:end-1]) ;
		mask_ML_L = map((x,y,z,k) -> x == 5 && y == 8 && z == 8 && k != 0, 
			subj.tone_v[2:end], subj.response_v[2:end], subj.tone_v[1:end-1], subj.response_v[1:end-1]) ;

		mask_HH_H = map((x,y,z,k) -> x == 2 && y == 2 && z == 2 && k != 0, 
			subj.tone_v[2:end], subj.response_v[2:end], subj.tone_v[1:end-1], subj.response_v[1:end-1]) ;
		mask_HH_M = map((x,y,z,k) -> x == 2 && y == 2 && z == 5 && k != 0, 
			subj.tone_v[2:end], subj.response_v[2:end], subj.tone_v[1:end-1], subj.response_v[1:end-1]) ;
		mask_HH_L = map((x,y,z,k) -> x == 2 && y == 2 && z == 8 && k != 0, 
			subj.tone_v[2:end], subj.response_v[2:end], subj.tone_v[1:end-1], subj.response_v[1:end-1]) ;

		mask_HL_H = map((x,y,z,k) -> x == 2 && y == 8 && z == 2 && k != 0, 
			subj.tone_v[2:end], subj.response_v[2:end], subj.tone_v[1:end-1], subj.response_v[1:end-1]) ;
		mask_HL_M = map((x,y,z,k) -> x == 2 && y == 8 && z == 5 && k != 0, 
			subj.tone_v[2:end], subj.response_v[2:end], subj.tone_v[1:end-1], subj.response_v[1:end-1]) ;
		mask_HL_L = map((x,y,z,k) -> x == 2 && y == 8 && z == 8 && k != 0, 
			subj.tone_v[2:end], subj.response_v[2:end], subj.tone_v[1:end-1], subj.response_v[1:end-1]) ;

		mask_LH_H = map((x,y,z,k) -> x == 8 && y == 2 && z == 2 && k != 0, 
			subj.tone_v[2:end], subj.response_v[2:end], subj.tone_v[1:end-1], subj.response_v[1:end-1]) ;
		mask_LH_M = map((x,y,z,k) -> x == 8 && y == 2 && z == 5 && k != 0, 
			subj.tone_v[2:end], subj.response_v[2:end], subj.tone_v[1:end-1], subj.response_v[1:end-1]) ;
		mask_LH_L = map((x,y,z,k) -> x == 8 && y == 2 && z == 8 && k != 0, 
			subj.tone_v[2:end], subj.response_v[2:end], subj.tone_v[1:end-1], subj.response_v[1:end-1]) ;

		mask_LL_H = map((x,y,z,k) -> x == 8 && y == 8 && z == 2 && k != 0, 
			subj.tone_v[2:end], subj.response_v[2:end], subj.tone_v[1:end-1], subj.response_v[1:end-1]) ;
		mask_LL_M = map((x,y,z,k) -> x == 8 && y == 8 && z == 5 && k != 0, 
			subj.tone_v[2:end], subj.response_v[2:end], subj.tone_v[1:end-1], subj.response_v[1:end-1]) ;
		mask_LL_L = map((x,y,z,k) -> x == 8 && y == 8 && z == 8 && k != 0, 
			subj.tone_v[2:end], subj.response_v[2:end], subj.tone_v[1:end-1], subj.response_v[1:end-1]) ;
		
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
	scatter(fill(x_ticks[1],length(rt_HH_H_v)), rt_HH_H_v, color = "red", alpha = 0.3) ;
	scatter(fill(x_ticks[2],length(rt_HH_M_v)), rt_HH_M_v, color = "blue", alpha = 0.3) ;
	scatter(fill(x_ticks[3],length(rt_HH_L_v)), rt_HH_L_v, color = "green", alpha = 0.3) ;

	errorbar(x_ticks[1], mean(rt_HH_H_v[map(x->!isnan(x), rt_HH_H_v)]), yerr = std(rt_HH_H_v[map(x->!isnan(x), rt_HH_H_v)]) / sqrt(length(rt_HH_H_v[map(x->!isnan(x), rt_HH_H_v)])), 
				marker = "D", markersize = 10, capsize = 10, color = "red")
	errorbar(x_ticks[2], mean(rt_HH_M_v[map(x->!isnan(x), rt_HH_M_v)]), yerr = std(rt_HH_M_v[map(x->!isnan(x), rt_HH_M_v)]) / sqrt(length(rt_HH_M_v[map(x->!isnan(x), rt_HH_M_v)])), 
				marker = "D", markersize = 10, capsize = 10, color = "blue")
	errorbar(x_ticks[3], mean(rt_HH_L_v[map(x->!isnan(x), rt_HH_L_v)]), yerr = std(rt_HH_L_v[map(x->!isnan(x), rt_HH_L_v)]) / sqrt(length(rt_HH_L_v[map(x->!isnan(x), rt_HH_L_v)])), 
				marker = "D", markersize = 10, capsize = 10, color = "green")

	x_ticks .+= 3.0 ;
	scatter(fill(x_ticks[1],length(rt_HL_H_v)), rt_HL_H_v, color = "red", alpha = 0.3) ;
	scatter(fill(x_ticks[2],length(rt_HL_M_v)), rt_HL_M_v, color = "blue", alpha = 0.3) ;
	scatter(fill(x_ticks[3],length(rt_HL_L_v)), rt_HL_L_v, color = "green", alpha = 0.3) ;

	errorbar(x_ticks[1], mean(rt_HL_H_v[map(x->!isnan(x), rt_HL_H_v)]), yerr = std(rt_HL_H_v[map(x->!isnan(x), rt_HL_H_v)]) / sqrt(length(rt_HL_H_v[map(x->!isnan(x), rt_HL_H_v)])), 
				marker = "D", markersize = 10, capsize = 10, color = "red")
	errorbar(x_ticks[2], mean(rt_HL_M_v[map(x->!isnan(x), rt_HL_M_v)]), yerr = std(rt_HL_M_v[map(x->!isnan(x), rt_HL_M_v)]) / sqrt(length(rt_HL_M_v[map(x->!isnan(x), rt_HL_M_v)])), 
				marker = "D", markersize = 10, capsize = 10, color = "blue")
	errorbar(x_ticks[3], mean(rt_HL_L_v[map(x->!isnan(x), rt_HL_L_v)]), yerr = std(rt_HL_L_v[map(x->!isnan(x), rt_HL_L_v)]) / sqrt(length(rt_HL_L_v[map(x->!isnan(x), rt_HL_L_v)])), 
				marker = "D", markersize = 10, capsize = 10, color = "green")

	x_ticks .+= 3.0 ;
	scatter(fill(x_ticks[1],length(rt_MH_H_v)), rt_MH_H_v, color = "red", alpha = 0.3) ;
	scatter(fill(x_ticks[2],length(rt_MH_M_v)), rt_MH_M_v, color = "blue", alpha = 0.3) ;
	scatter(fill(x_ticks[3],length(rt_MH_L_v)), rt_MH_L_v, color = "green", alpha = 0.3) ;

	errorbar(x_ticks[1], mean(rt_MH_H_v[map(x->!isnan(x), rt_MH_H_v)]), yerr = std(rt_MH_H_v[map(x->!isnan(x), rt_MH_H_v)]) / sqrt(length(rt_MH_H_v[map(x->!isnan(x), rt_MH_H_v)])), 
				marker = "D", markersize = 10, capsize = 10, color = "red")
	errorbar(x_ticks[2], mean(rt_MH_M_v[map(x->!isnan(x), rt_MH_M_v)]), yerr = std(rt_MH_M_v[map(x->!isnan(x), rt_MH_M_v)]) / sqrt(length(rt_MH_M_v[map(x->!isnan(x), rt_MH_M_v)])), 
				marker = "D", markersize = 10, capsize = 10, color = "blue")
	errorbar(x_ticks[3], mean(rt_MH_L_v[map(x->!isnan(x), rt_MH_L_v)]), yerr = std(rt_MH_L_v[map(x->!isnan(x), rt_MH_L_v)]) / sqrt(length(rt_MH_L_v[map(x->!isnan(x), rt_MH_L_v)])), 
				marker = "D", markersize = 10, capsize = 10, color = "green")

	x_ticks .+= 3.0 ;
	scatter(fill(x_ticks[1],length(rt_ML_H_v)), rt_ML_H_v, color = "red", alpha = 0.3) ;
	scatter(fill(x_ticks[2],length(rt_ML_M_v)), rt_ML_M_v, color = "blue", alpha = 0.3) ;
	scatter(fill(x_ticks[3],length(rt_ML_L_v)), rt_ML_L_v, color = "green", alpha = 0.3) ;

	errorbar(x_ticks[1], mean(rt_ML_H_v[map(x->!isnan(x), rt_ML_H_v)]), yerr = std(rt_ML_H_v[map(x->!isnan(x), rt_ML_H_v)]) / sqrt(length(rt_ML_H_v[map(x->!isnan(x), rt_ML_H_v)])), 
				marker = "D", markersize = 10, capsize = 10, color = "red")
	errorbar(x_ticks[2], mean(rt_ML_M_v[map(x->!isnan(x), rt_ML_M_v)]), yerr = std(rt_ML_M_v[map(x->!isnan(x), rt_ML_M_v)]) / sqrt(length(rt_ML_M_v[map(x->!isnan(x), rt_ML_M_v)])), 
				marker = "D", markersize = 10, capsize = 10, color = "blue")
	errorbar(x_ticks[3], mean(rt_ML_L_v[map(x->!isnan(x), rt_ML_L_v)]), yerr = std(rt_ML_L_v[map(x->!isnan(x), rt_ML_L_v)]) / sqrt(length(rt_ML_L_v[map(x->!isnan(x), rt_ML_L_v)])), 
				marker = "D", markersize = 10, capsize = 10, color = "green")

	x_ticks .+= 3.0 ;
	scatter(fill(x_ticks[1],length(rt_LH_H_v)), rt_LH_H_v, color = "red", alpha = 0.3) ;
	scatter(fill(x_ticks[2],length(rt_LH_M_v)), rt_LH_M_v, color = "blue", alpha = 0.3) ;
	scatter(fill(x_ticks[3],length(rt_LH_L_v)), rt_LH_L_v, color = "green", alpha = 0.3) ;

	errorbar(x_ticks[1], mean(rt_LH_H_v[map(x->!isnan(x), rt_LH_H_v)]), yerr = std(rt_LH_H_v[map(x->!isnan(x), rt_LH_H_v)]) / sqrt(length(rt_LH_H_v[map(x->!isnan(x), rt_LH_H_v)])), 
				marker = "D", markersize = 10, capsize = 10, color = "red")
	errorbar(x_ticks[2], mean(rt_LH_M_v[map(x->!isnan(x), rt_LH_M_v)]), yerr = std(rt_LH_M_v[map(x->!isnan(x), rt_LH_M_v)]) / sqrt(length(rt_LH_M_v[map(x->!isnan(x), rt_LH_M_v)])), 
				marker = "D", markersize = 10, capsize = 10, color = "blue")
	errorbar(x_ticks[3], mean(rt_LH_L_v[map(x->!isnan(x), rt_LH_L_v)]), yerr = std(rt_LH_L_v[map(x->!isnan(x), rt_LH_L_v)]) / sqrt(length(rt_LH_L_v[map(x->!isnan(x), rt_LH_L_v)])), 
				marker = "D", markersize = 10, capsize = 10, color = "green")

	x_ticks .+= 3.0 ;
	scatter(fill(x_ticks[1],length(rt_LL_H_v)), rt_LL_H_v, color = "red", alpha = 0.3, label = "High previous") ;
	scatter(fill(x_ticks[2],length(rt_LL_M_v)), rt_LL_M_v, color = "blue", alpha = 0.3, label = "Mid previous") ;
	scatter(fill(x_ticks[3],length(rt_LL_L_v)), rt_LL_L_v, color = "green", alpha = 0.3, label = "Low previous") ;

	errorbar(x_ticks[1], mean(rt_LL_H_v[map(x->!isnan(x), rt_LL_H_v)]), yerr = std(rt_LL_H_v[map(x->!isnan(x), rt_LL_H_v)]) / sqrt(length(rt_LL_H_v[map(x->!isnan(x), rt_LL_H_v)])), 
				marker = "D", markersize = 10, capsize = 10, color = "red")
	errorbar(x_ticks[2], mean(rt_LL_M_v[map(x->!isnan(x), rt_LL_M_v)]), yerr = std(rt_LL_M_v[map(x->!isnan(x), rt_LL_M_v)]) / sqrt(length(rt_LL_M_v[map(x->!isnan(x), rt_LL_M_v)])), 
				marker = "D", markersize = 10, capsize = 10, color = "blue")
	errorbar(x_ticks[3], mean(rt_LL_L_v[map(x->!isnan(x), rt_LL_L_v)]), yerr = std(rt_LL_L_v[map(x->!isnan(x), rt_LL_L_v)]) / sqrt(length(rt_LL_L_v[map(x->!isnan(x), rt_LL_L_v)])), 
				marker = "D", markersize = 10, capsize = 10, color = "green")

	ax[:set_xticks]([x_ticks[2] - 5.0*3.0, x_ticks[2] - 4.0*3.0, x_ticks[2] - 3.0*3.0, 
		x_ticks[2] - 2.0*3.0, x_ticks[2] - 1.0*3.0, x_ticks[2]])
	ax[:set_xticklabels](["High tone \n High response", "High tone \n Low response",
						"Mid tone \n High response", "Mid tone \n Low response",
						"Low tone \n High response", "Low tone \n Low response"])
	ax[:tick_params](labelsize = 16)
	ylabel("Response latency [s]", fontsize = 16)
	legend(fontsize = 16)
	show()
end

function plot_resp_rt_prev_reward(subj_v::Array{subj_t,1})

	rt_MH_4_v = Array{Float64,1}() ;
	rt_MH_0_v = Array{Float64,1}() ;
	rt_MH_1_v = Array{Float64,1}() ;
	rt_ML_4_v = Array{Float64,1}() ;
	rt_ML_0_v = Array{Float64,1}() ;
	rt_ML_1_v = Array{Float64,1}() ;
	rt_HH_4_v = Array{Float64,1}() ;
	rt_HH_0_v = Array{Float64,1}() ;
	rt_HH_1_v = Array{Float64,1}() ;
	rt_HL_4_v = Array{Float64,1}() ;
	rt_HL_0_v = Array{Float64,1}() ;
	rt_HL_1_v = Array{Float64,1}() ;
	rt_LH_4_v = Array{Float64,1}() ;
	rt_LH_0_v = Array{Float64,1}() ;
	rt_LH_1_v = Array{Float64,1}() ;
	rt_LL_4_v = Array{Float64,1}() ;
	rt_LL_0_v = Array{Float64,1}() ;
	rt_LL_1_v = Array{Float64,1}() ;

	press_MH_4_v = Array{Float64,1}() ;
	press_MH_0_v = Array{Float64,1}() ;
	press_MH_1_v = Array{Float64,1}() ;
	press_ML_4_v = Array{Float64,1}() ;
	press_ML_0_v = Array{Float64,1}() ;
	press_ML_1_v = Array{Float64,1}() ;
	press_HH_4_v = Array{Float64,1}() ;
	press_HH_0_v = Array{Float64,1}() ;
	press_HH_1_v = Array{Float64,1}() ;
	press_HL_4_v = Array{Float64,1}() ;
	press_HL_0_v = Array{Float64,1}() ;
	press_HL_1_v = Array{Float64,1}() ;
	press_LH_4_v = Array{Float64,1}() ;
	press_LH_0_v = Array{Float64,1}() ;
	press_LH_1_v = Array{Float64,1}() ;
	press_LL_4_v = Array{Float64,1}() ;
	press_LL_0_v = Array{Float64,1}() ;
	press_LL_1_v = Array{Float64,1}() ;

	subj_v_first = Array{subj_t,1}() ;
	subj_v_second = Array{subj_t,1}() ;

	for subj in subj_v
		push!(subj_v_first, subj_t(subj.id, 
				subj.response_v[1:Int64(floor(length(subj.response_v)/2))], 
				subj.reward_v[1:Int64(floor(length(subj.reward_v)/2))], 
				subj.tone_v[1:Int64(floor(length(subj.tone_v)/2))], 
				subj.rt_v[1:Int64(floor(length(subj.rt_v)/2))], 
				subj.cbi)) ;

		push!(subj_v_second, subj_t(subj.id, 
				subj.response_v[Int64(floor(length(subj.response_v)/2)) + 1 : end], 
				subj.reward_v[Int64(floor(length(subj.reward_v)/2)) + 1 : end], 
				subj.tone_v[Int64(floor(length(subj.tone_v)/2)) + 1 : end], 
				subj.rt_v[Int64(floor(length(subj.rt_v)/2)) + 1 : end], 
				subj.cbi)) ;
	end


	for subj in subj_v_second

		# mask_Current tone Current response_Previous reward

		mask_MH_4 = map((x,y,z,k) -> x == 5 && y == 2 && z == 4 && k != 0, 
			subj.tone_v[2:end], subj.response_v[2:end], subj.reward_v[1:end-1], subj.response_v[1:end-1]) ;
		mask_MH_0 = map((x,y,z,k) -> x == 5 && y == 2 && z == 0 && k != 0, 
			subj.tone_v[2:end], subj.response_v[2:end], subj.reward_v[1:end-1], subj.response_v[1:end-1]) ;
		mask_MH_1 = map((x,y,z,k) -> x == 5 && y == 2 && z == 1 && k != 0, 
			subj.tone_v[2:end], subj.response_v[2:end], subj.reward_v[1:end-1], subj.response_v[1:end-1]) ;

		mask_ML_4 = map((x,y,z,k) -> x == 5 && y == 8 && z == 4 && k != 0, 
			subj.tone_v[2:end], subj.response_v[2:end], subj.reward_v[1:end-1], subj.response_v[1:end-1]) ;
		mask_ML_0 = map((x,y,z,k) -> x == 5 && y == 8 && z == 0 && k != 0, 
			subj.tone_v[2:end], subj.response_v[2:end], subj.reward_v[1:end-1], subj.response_v[1:end-1]) ;
		mask_ML_1 = map((x,y,z,k) -> x == 5 && y == 8 && z == 1 && k != 0, 
			subj.tone_v[2:end], subj.response_v[2:end], subj.reward_v[1:end-1], subj.response_v[1:end-1]) ;

		mask_HH_4 = map((x,y,z,k) -> x == 2 && y == 2 && z == 4 && k != 0, 
			subj.tone_v[2:end], subj.response_v[2:end], subj.reward_v[1:end-1], subj.response_v[1:end-1]) ;
		mask_HH_0 = map((x,y,z,k) -> x == 2 && y == 2 && z == 0 && k != 0, 
			subj.tone_v[2:end], subj.response_v[2:end], subj.reward_v[1:end-1], subj.response_v[1:end-1]) ;
		mask_HH_1 = map((x,y,z,k) -> x == 2 && y == 2 && z == 1 && k != 0, 
			subj.tone_v[2:end], subj.response_v[2:end], subj.reward_v[1:end-1], subj.response_v[1:end-1]) ;

		mask_HL_4 = map((x,y,z,k) -> x == 2 && y == 8 && z == 4 && k != 0, 
			subj.tone_v[2:end], subj.response_v[2:end], subj.reward_v[1:end-1], subj.response_v[1:end-1]) ;
		mask_HL_0 = map((x,y,z,k) -> x == 2 && y == 8 && z == 0 && k != 0, 
			subj.tone_v[2:end], subj.response_v[2:end], subj.reward_v[1:end-1], subj.response_v[1:end-1]) ;
		mask_HL_1 = map((x,y,z,k) -> x == 2 && y == 8 && z == 1 && k != 0, 
			subj.tone_v[2:end], subj.response_v[2:end], subj.reward_v[1:end-1], subj.response_v[1:end-1]) ;

		mask_LH_4 = map((x,y,z,k) -> x == 8 && y == 2 && z == 4 && k != 0, 
			subj.tone_v[2:end], subj.response_v[2:end], subj.reward_v[1:end-1], subj.response_v[1:end-1]) ;
		mask_LH_0 = map((x,y,z,k) -> x == 8 && y == 2 && z == 0 && k != 0, 
			subj.tone_v[2:end], subj.response_v[2:end], subj.reward_v[1:end-1], subj.response_v[1:end-1]) ;
		mask_LH_1 = map((x,y,z,k) -> x == 8 && y == 2 && z == 1 && k != 0, 
			subj.tone_v[2:end], subj.response_v[2:end], subj.reward_v[1:end-1], subj.response_v[1:end-1]) ;

		mask_LL_4 = map((x,y,z,k) -> x == 8 && y == 8 && z == 4 && k != 0, 
			subj.tone_v[2:end], subj.response_v[2:end], subj.reward_v[1:end-1], subj.response_v[1:end-1]) ;
		mask_LL_0 = map((x,y,z,k) -> x == 8 && y == 8 && z == 0 && k != 0, 
			subj.tone_v[2:end], subj.response_v[2:end], subj.reward_v[1:end-1], subj.response_v[1:end-1]) ;
		mask_LL_1 = map((x,y,z,k) -> x == 8 && y == 8 && z == 1 && k != 0, 
			subj.tone_v[2:end], subj.response_v[2:end], subj.reward_v[1:end-1], subj.response_v[1:end-1]) ;
		
		pushfirst!(mask_MH_4, false) ;
		pushfirst!(mask_MH_0, false) ;
		pushfirst!(mask_MH_1, false) ;
		pushfirst!(mask_ML_4, false) ;
		pushfirst!(mask_ML_0, false) ;
		pushfirst!(mask_ML_1, false) ;
		pushfirst!(mask_HH_4, false) ;
		pushfirst!(mask_HH_0, false) ;
		pushfirst!(mask_HH_1, false) ;
		pushfirst!(mask_HL_4, false) ;
		pushfirst!(mask_HL_0, false) ;
		pushfirst!(mask_HL_1, false) ;
		pushfirst!(mask_LH_4, false) ;
		pushfirst!(mask_LH_0, false) ;
		pushfirst!(mask_LH_1, false) ;
		pushfirst!(mask_LL_4, false) ;
		pushfirst!(mask_LL_0, false) ;
		pushfirst!(mask_LL_1, false) ;		

		push!(press_MH_4_v, 100.0*length(subj.response_v[mask_MH_4]) / 
						(length(subj.response_v[mask_MH_4]) + length(subj.response_v[mask_MH_0]) + length(subj.response_v[mask_MH_1]))) ;
		push!(press_MH_0_v, 100.0*length(subj.response_v[mask_MH_0]) / 
						(length(subj.response_v[mask_MH_4]) + length(subj.response_v[mask_MH_0]) + length(subj.response_v[mask_MH_1]))) ;
		push!(press_MH_1_v, 100.0*length(subj.response_v[mask_MH_1]) / 
						(length(subj.response_v[mask_MH_4]) + length(subj.response_v[mask_MH_0]) + length(subj.response_v[mask_MH_1]))) ;

		push!(press_ML_4_v, 100.0*length(subj.response_v[mask_ML_4]) / 
						(length(subj.response_v[mask_ML_4]) + length(subj.response_v[mask_ML_0]) + length(subj.response_v[mask_ML_1]))) ;
		push!(press_ML_0_v, 100.0*length(subj.response_v[mask_ML_0]) / 
						(length(subj.response_v[mask_ML_4]) + length(subj.response_v[mask_ML_0]) + length(subj.response_v[mask_ML_1]))) ;
		push!(press_ML_1_v, 100.0*length(subj.response_v[mask_ML_1]) / 
						(length(subj.response_v[mask_ML_4]) + length(subj.response_v[mask_ML_0]) + length(subj.response_v[mask_ML_1]))) ;

		push!(press_HH_4_v, 100.0*length(subj.response_v[mask_HH_4]) / 
						(length(subj.response_v[mask_HH_4]) + length(subj.response_v[mask_HH_0]) + length(subj.response_v[mask_HH_1]))) ;
		push!(press_HH_0_v, 100.0*length(subj.response_v[mask_HH_0]) / 
						(length(subj.response_v[mask_HH_4]) + length(subj.response_v[mask_HH_0]) + length(subj.response_v[mask_HH_1]))) ;
		push!(press_HH_1_v, 100.0*length(subj.response_v[mask_HH_1]) / 
						(length(subj.response_v[mask_HH_4]) + length(subj.response_v[mask_HH_0]) + length(subj.response_v[mask_HH_1]))) ;

		push!(press_HL_4_v, 100.0*length(subj.response_v[mask_HL_4]) / 
						(length(subj.response_v[mask_HL_4]) + length(subj.response_v[mask_HL_0]) + length(subj.response_v[mask_HL_1]))) ;
		push!(press_HL_0_v, 100.0*length(subj.response_v[mask_HL_0]) / 
						(length(subj.response_v[mask_HL_4]) + length(subj.response_v[mask_HL_0]) + length(subj.response_v[mask_HL_1]))) ;
		push!(press_HL_1_v, 100.0*length(subj.response_v[mask_HL_1]) / 
						(length(subj.response_v[mask_HL_4]) + length(subj.response_v[mask_HL_0]) + length(subj.response_v[mask_HL_1]))) ;

		push!(press_LH_4_v, 100.0*length(subj.response_v[mask_LH_4]) / 
						(length(subj.response_v[mask_LH_4]) + length(subj.response_v[mask_LH_0]) + length(subj.response_v[mask_LH_1]))) ;
		push!(press_LH_0_v, 100.0*length(subj.response_v[mask_LH_0]) / 
						(length(subj.response_v[mask_LH_4]) + length(subj.response_v[mask_LH_0]) + length(subj.response_v[mask_LH_1]))) ;
		push!(press_LH_1_v, 100.0*length(subj.response_v[mask_LH_1]) / 
						(length(subj.response_v[mask_LH_4]) + length(subj.response_v[mask_LH_0]) + length(subj.response_v[mask_LH_1]))) ;

		push!(press_LL_4_v, 100.0*length(subj.response_v[mask_LL_4]) / 
						(length(subj.response_v[mask_LL_4]) + length(subj.response_v[mask_LL_0]) + length(subj.response_v[mask_LL_1]))) ;
		push!(press_LL_0_v, 100.0*length(subj.response_v[mask_LL_0]) / 
						(length(subj.response_v[mask_LL_4]) + length(subj.response_v[mask_LL_0]) + length(subj.response_v[mask_LL_1]))) ;
		push!(press_LL_1_v, 100.0*length(subj.response_v[mask_LL_1]) / 
						(length(subj.response_v[mask_LL_4]) + length(subj.response_v[mask_LL_0]) + length(subj.response_v[mask_LL_1]))) ;

		push!(rt_MH_4_v, mean(subj.rt_v[mask_MH_4])) ;
		push!(rt_MH_0_v, mean(subj.rt_v[mask_MH_0])) ;
		push!(rt_MH_1_v, mean(subj.rt_v[mask_MH_1])) ;
		push!(rt_ML_4_v, mean(subj.rt_v[mask_ML_4])) ;
		push!(rt_ML_0_v, mean(subj.rt_v[mask_ML_0])) ;
		push!(rt_ML_1_v, mean(subj.rt_v[mask_ML_1])) ;
		push!(rt_HH_4_v, mean(subj.rt_v[mask_HH_4])) ;
		push!(rt_HH_0_v, mean(subj.rt_v[mask_HH_0])) ;
		push!(rt_HH_1_v, mean(subj.rt_v[mask_HH_1])) ;
		push!(rt_HL_4_v, mean(subj.rt_v[mask_HL_4])) ;
		push!(rt_HL_0_v, mean(subj.rt_v[mask_HL_0])) ;
		push!(rt_HL_1_v, mean(subj.rt_v[mask_HL_1])) ;
		push!(rt_LH_4_v, mean(subj.rt_v[mask_LH_4])) ;
		push!(rt_LH_0_v, mean(subj.rt_v[mask_LH_0])) ;
		push!(rt_LH_1_v, mean(subj.rt_v[mask_LH_1])) ;
		push!(rt_LL_4_v, mean(subj.rt_v[mask_LL_4])) ;
		push!(rt_LL_0_v, mean(subj.rt_v[mask_LL_0])) ;
		push!(rt_LL_1_v, mean(subj.rt_v[mask_LL_1])) ;
	end

	figure()
	ax = gca()
	x_ticks = [0.5, 1.0, 1.5] ;
	scatter(fill(x_ticks[1],length(rt_HH_4_v)), rt_HH_4_v, color = "red", alpha = 0.3) ;
	scatter(fill(x_ticks[2],length(rt_HH_0_v)), rt_HH_0_v, color = "blue", alpha = 0.3) ;
	scatter(fill(x_ticks[3],length(rt_HH_1_v)), rt_HH_1_v, color = "green", alpha = 0.3) ;

	errorbar(x_ticks[1], mean(rt_HH_4_v[map(x->!isnan(x), rt_HH_4_v)]), yerr = std(rt_HH_4_v[map(x->!isnan(x), rt_HH_4_v)]) / sqrt(length(rt_HH_4_v[map(x->!isnan(x), rt_HH_4_v)])), 
				marker = "D", markersize = 10, capsize = 10, color = "red")
	errorbar(x_ticks[2], mean(rt_HH_0_v[map(x->!isnan(x), rt_HH_0_v)]), yerr = std(rt_HH_0_v[map(x->!isnan(x), rt_HH_0_v)]) / sqrt(length(rt_HH_0_v[map(x->!isnan(x), rt_HH_0_v)])), 
				marker = "D", markersize = 10, capsize = 10, color = "blue")
	errorbar(x_ticks[3], mean(rt_HH_1_v[map(x->!isnan(x), rt_HH_1_v)]), yerr = std(rt_HH_1_v[map(x->!isnan(x), rt_HH_1_v)]) / sqrt(length(rt_HH_1_v[map(x->!isnan(x), rt_HH_1_v)])), 
				marker = "D", markersize = 10, capsize = 10, color = "green")

	x_ticks .+= 3.0 ;
	scatter(fill(x_ticks[1],length(rt_HL_4_v)), rt_HL_4_v, color = "red", alpha = 0.3) ;
	scatter(fill(x_ticks[2],length(rt_HL_0_v)), rt_HL_0_v, color = "blue", alpha = 0.3) ;
	scatter(fill(x_ticks[3],length(rt_HL_1_v)), rt_HL_1_v, color = "green", alpha = 0.3) ;

	errorbar(x_ticks[1], mean(rt_HL_4_v[map(x->!isnan(x), rt_HL_4_v)]), yerr = std(rt_HL_4_v[map(x->!isnan(x), rt_HL_4_v)]) / sqrt(length(rt_HL_4_v[map(x->!isnan(x), rt_HL_4_v)])), 
				marker = "D", markersize = 10, capsize = 10, color = "red")
	errorbar(x_ticks[2], mean(rt_HL_0_v[map(x->!isnan(x), rt_HL_0_v)]), yerr = std(rt_HL_0_v[map(x->!isnan(x), rt_HL_0_v)]) / sqrt(length(rt_HL_0_v[map(x->!isnan(x), rt_HL_0_v)])), 
				marker = "D", markersize = 10, capsize = 10, color = "blue")
	errorbar(x_ticks[3], mean(rt_HL_1_v[map(x->!isnan(x), rt_HL_1_v)]), yerr = std(rt_HL_1_v[map(x->!isnan(x), rt_HL_1_v)]) / sqrt(length(rt_HL_1_v[map(x->!isnan(x), rt_HL_1_v)])), 
				marker = "D", markersize = 10, capsize = 10, color = "green")

	x_ticks .+= 3.0 ;
	scatter(fill(x_ticks[1],length(rt_MH_4_v)), rt_MH_4_v, color = "red", alpha = 0.3) ;
	scatter(fill(x_ticks[2],length(rt_MH_0_v)), rt_MH_0_v, color = "blue", alpha = 0.3) ;
	scatter(fill(x_ticks[3],length(rt_MH_1_v)), rt_MH_1_v, color = "green", alpha = 0.3) ;

	errorbar(x_ticks[1], mean(rt_MH_4_v[map(x->!isnan(x), rt_MH_4_v)]), yerr = std(rt_MH_4_v[map(x->!isnan(x), rt_MH_4_v)]) / sqrt(length(rt_MH_4_v[map(x->!isnan(x), rt_MH_4_v)])), 
				marker = "D", markersize = 10, capsize = 10, color = "red")
	errorbar(x_ticks[2], mean(rt_MH_0_v[map(x->!isnan(x), rt_MH_0_v)]), yerr = std(rt_MH_0_v[map(x->!isnan(x), rt_MH_0_v)]) / sqrt(length(rt_MH_0_v[map(x->!isnan(x), rt_MH_0_v)])), 
				marker = "D", markersize = 10, capsize = 10, color = "blue")
	errorbar(x_ticks[3], mean(rt_MH_1_v[map(x->!isnan(x), rt_MH_1_v)]), yerr = std(rt_MH_1_v[map(x->!isnan(x), rt_MH_1_v)]) / sqrt(length(rt_MH_1_v[map(x->!isnan(x), rt_MH_1_v)])), 
				marker = "D", markersize = 10, capsize = 10, color = "green")

	x_ticks .+= 3.0 ;
	scatter(fill(x_ticks[1],length(rt_ML_4_v)), rt_ML_4_v, color = "red", alpha = 0.3) ;
	scatter(fill(x_ticks[2],length(rt_ML_0_v)), rt_ML_0_v, color = "blue", alpha = 0.3) ;
	scatter(fill(x_ticks[3],length(rt_ML_1_v)), rt_ML_1_v, color = "green", alpha = 0.3) ;

	errorbar(x_ticks[1], mean(rt_ML_4_v[map(x->!isnan(x), rt_ML_4_v)]), yerr = std(rt_ML_4_v[map(x->!isnan(x), rt_ML_4_v)]) / sqrt(length(rt_ML_4_v[map(x->!isnan(x), rt_ML_4_v)])), 
				marker = "D", markersize = 10, capsize = 10, color = "red")
	errorbar(x_ticks[2], mean(rt_ML_0_v[map(x->!isnan(x), rt_ML_0_v)]), yerr = std(rt_ML_0_v[map(x->!isnan(x), rt_ML_0_v)]) / sqrt(length(rt_ML_0_v[map(x->!isnan(x), rt_ML_0_v)])), 
				marker = "D", markersize = 10, capsize = 10, color = "blue")
	errorbar(x_ticks[3], mean(rt_ML_1_v[map(x->!isnan(x), rt_ML_1_v)]), yerr = std(rt_ML_1_v[map(x->!isnan(x), rt_ML_1_v)]) / sqrt(length(rt_ML_1_v[map(x->!isnan(x), rt_ML_1_v)])), 
				marker = "D", markersize = 10, capsize = 10, color = "green")

	x_ticks .+= 3.0 ;
	scatter(fill(x_ticks[1],length(rt_LH_4_v)), rt_LH_4_v, color = "red", alpha = 0.3) ;
	scatter(fill(x_ticks[2],length(rt_LH_0_v)), rt_LH_0_v, color = "blue", alpha = 0.3) ;
	scatter(fill(x_ticks[3],length(rt_LH_1_v)), rt_LH_1_v, color = "green", alpha = 0.3) ;

	errorbar(x_ticks[1], mean(rt_LH_4_v[map(x->!isnan(x), rt_LH_4_v)]), yerr = std(rt_LH_4_v[map(x->!isnan(x), rt_LH_4_v)]) / sqrt(length(rt_LH_4_v[map(x->!isnan(x), rt_LH_4_v)])), 
				marker = "D", markersize = 10, capsize = 10, color = "red")
	errorbar(x_ticks[2], mean(rt_LH_0_v[map(x->!isnan(x), rt_LH_0_v)]), yerr = std(rt_LH_0_v[map(x->!isnan(x), rt_LH_0_v)]) / sqrt(length(rt_LH_0_v[map(x->!isnan(x), rt_LH_0_v)])), 
				marker = "D", markersize = 10, capsize = 10, color = "blue")
	errorbar(x_ticks[3], mean(rt_LH_1_v[map(x->!isnan(x), rt_LH_1_v)]), yerr = std(rt_LH_1_v[map(x->!isnan(x), rt_LH_1_v)]) / sqrt(length(rt_LH_1_v[map(x->!isnan(x), rt_LH_1_v)])), 
				marker = "D", markersize = 10, capsize = 10, color = "green")

	x_ticks .+= 3.0 ;
	scatter(fill(x_ticks[1],length(rt_LL_4_v)), rt_LL_4_v, color = "red", alpha = 0.3, label = "4 previous") ;
	scatter(fill(x_ticks[2],length(rt_LL_0_v)), rt_LL_0_v, color = "blue", alpha = 0.3, label = "0 previous") ;
	scatter(fill(x_ticks[3],length(rt_LL_1_v)), rt_LL_1_v, color = "green", alpha = 0.3, label = "1 previous") ;

	errorbar(x_ticks[1], mean(rt_LL_4_v[map(x->!isnan(x), rt_LL_4_v)]), yerr = std(rt_LL_4_v[map(x->!isnan(x), rt_LL_4_v)]) / sqrt(length(rt_LL_4_v[map(x->!isnan(x), rt_LL_4_v)])), 
				marker = "D", markersize = 10, capsize = 10, color = "red")
	errorbar(x_ticks[2], mean(rt_LL_0_v[map(x->!isnan(x), rt_LL_0_v)]), yerr = std(rt_LL_0_v[map(x->!isnan(x), rt_LL_0_v)]) / sqrt(length(rt_LL_0_v[map(x->!isnan(x), rt_LL_0_v)])), 
				marker = "D", markersize = 10, capsize = 10, color = "blue")
	errorbar(x_ticks[3], mean(rt_LL_1_v[map(x->!isnan(x), rt_LL_1_v)]), yerr = std(rt_LL_1_v[map(x->!isnan(x), rt_LL_1_v)]) / sqrt(length(rt_LL_1_v[map(x->!isnan(x), rt_LL_1_v)])), 
				marker = "D", markersize = 10, capsize = 10, color = "green")

	ax[:set_xticks]([x_ticks[2] - 5.0*3.0, x_ticks[2] - 4.0*3.0, x_ticks[2] - 3.0*3.0, 
		x_ticks[2] - 2.0*3.0, x_ticks[2] - 1.0*3.0, x_ticks[2]])
	ax[:set_xticklabels](["High tone \n High response", "High tone \n Low response",
						"Mid tone \n High response", "Mid tone \n Low response",
						"Low tone \n High response", "Low tone \n Low response"])
	ax[:tick_params](labelsize = 16)
	ylabel("Response latency [s]", fontsize = 16)
	legend(fontsize = 16)

	figure()
	ax = gca()
	x_ticks = [0.5, 1.0, 1.5] ;
	
	scatter(fill(x_ticks[1],length(press_HH_4_v)), press_HH_4_v, color = "red", alpha = 0.3) ;
	scatter(fill(x_ticks[2],length(press_HH_0_v)), press_HH_0_v, color = "blue", alpha = 0.3) ;
	scatter(fill(x_ticks[3],length(press_HH_1_v)), press_HH_1_v, color = "green", alpha = 0.3) ;

	errorbar(x_ticks[1], mean(press_HH_4_v[map(x->!isnan(x), press_HH_4_v)]), yerr = std(press_HH_4_v[map(x->!isnan(x), press_HH_4_v)]) / sqrt(length(press_HH_4_v[map(x->!isnan(x), press_HH_4_v)])), 
				marker = "D", markersize = 10, capsize = 10, color = "red")
	errorbar(x_ticks[2], mean(press_HH_0_v[map(x->!isnan(x), press_HH_0_v)]), yerr = std(press_HH_0_v[map(x->!isnan(x), press_HH_0_v)]) / sqrt(length(press_HH_0_v[map(x->!isnan(x), press_HH_0_v)])), 
				marker = "D", markersize = 10, capsize = 10, color = "blue")
	errorbar(x_ticks[3], mean(press_HH_1_v[map(x->!isnan(x), press_HH_1_v)]), yerr = std(press_HH_1_v[map(x->!isnan(x), press_HH_1_v)]) / sqrt(length(press_HH_1_v[map(x->!isnan(x), press_HH_1_v)])), 
				marker = "D", markersize = 10, capsize = 10, color = "green")

	x_ticks .+= 3.0 ;
	scatter(fill(x_ticks[1],length(press_HL_4_v)), press_HL_4_v, color = "red", alpha = 0.3) ;
	scatter(fill(x_ticks[2],length(press_HL_0_v)), press_HL_0_v, color = "blue", alpha = 0.3) ;
	scatter(fill(x_ticks[3],length(press_HL_1_v)), press_HL_1_v, color = "green", alpha = 0.3) ;

	errorbar(x_ticks[1], mean(press_HL_4_v[map(x->!isnan(x), press_HL_4_v)]), yerr = std(press_HL_4_v[map(x->!isnan(x), press_HL_4_v)]) / sqrt(length(press_HL_4_v[map(x->!isnan(x), press_HL_4_v)])), 
				marker = "D", markersize = 10, capsize = 10, color = "red")
	errorbar(x_ticks[2], mean(press_HL_0_v[map(x->!isnan(x), press_HL_0_v)]), yerr = std(press_HL_0_v[map(x->!isnan(x), press_HL_0_v)]) / sqrt(length(press_HL_0_v[map(x->!isnan(x), press_HL_0_v)])), 
				marker = "D", markersize = 10, capsize = 10, color = "blue")
	errorbar(x_ticks[3], mean(press_HL_1_v[map(x->!isnan(x), press_HL_1_v)]), yerr = std(press_HL_1_v[map(x->!isnan(x), press_HL_1_v)]) / sqrt(length(press_HL_1_v[map(x->!isnan(x), press_HL_1_v)])), 
				marker = "D", markersize = 10, capsize = 10, color = "green")

	x_ticks .+= 3.0 ;
	scatter(fill(x_ticks[1],length(press_MH_4_v)), press_MH_4_v, color = "red", alpha = 0.3) ;
	scatter(fill(x_ticks[2],length(press_MH_0_v)), press_MH_0_v, color = "blue", alpha = 0.3) ;
	scatter(fill(x_ticks[3],length(press_MH_1_v)), press_MH_1_v, color = "green", alpha = 0.3) ;

	errorbar(x_ticks[1], mean(press_MH_4_v[map(x->!isnan(x), press_MH_4_v)]), yerr = std(press_MH_4_v[map(x->!isnan(x), press_MH_4_v)]) / sqrt(length(press_MH_4_v[map(x->!isnan(x), press_MH_4_v)])), 
				marker = "D", markersize = 10, capsize = 10, color = "red")
	errorbar(x_ticks[2], mean(press_MH_0_v[map(x->!isnan(x), press_MH_0_v)]), yerr = std(press_MH_0_v[map(x->!isnan(x), press_MH_0_v)]) / sqrt(length(press_MH_0_v[map(x->!isnan(x), press_MH_0_v)])), 
				marker = "D", markersize = 10, capsize = 10, color = "blue")
	errorbar(x_ticks[3], mean(press_MH_1_v[map(x->!isnan(x), press_MH_1_v)]), yerr = std(press_MH_1_v[map(x->!isnan(x), press_MH_1_v)]) / sqrt(length(press_MH_1_v[map(x->!isnan(x), press_MH_1_v)])), 
				marker = "D", markersize = 10, capsize = 10, color = "green")

	x_ticks .+= 3.0 ;
	scatter(fill(x_ticks[1],length(press_ML_4_v)), press_ML_4_v, color = "red", alpha = 0.3) ;
	scatter(fill(x_ticks[2],length(press_ML_0_v)), press_ML_0_v, color = "blue", alpha = 0.3) ;
	scatter(fill(x_ticks[3],length(press_ML_1_v)), press_ML_1_v, color = "green", alpha = 0.3) ;

	errorbar(x_ticks[1], mean(press_ML_4_v[map(x->!isnan(x), press_ML_4_v)]), yerr = std(press_ML_4_v[map(x->!isnan(x), press_ML_4_v)]) / sqrt(length(press_ML_4_v[map(x->!isnan(x), press_ML_4_v)])), 
				marker = "D", markersize = 10, capsize = 10, color = "red")
	errorbar(x_ticks[2], mean(press_ML_0_v[map(x->!isnan(x), press_ML_0_v)]), yerr = std(press_ML_0_v[map(x->!isnan(x), press_ML_0_v)]) / sqrt(length(press_ML_0_v[map(x->!isnan(x), press_ML_0_v)])), 
				marker = "D", markersize = 10, capsize = 10, color = "blue")
	errorbar(x_ticks[3], mean(press_ML_1_v[map(x->!isnan(x), press_ML_1_v)]), yerr = std(press_ML_1_v[map(x->!isnan(x), press_ML_1_v)]) / sqrt(length(press_ML_1_v[map(x->!isnan(x), press_ML_1_v)])), 
				marker = "D", markersize = 10, capsize = 10, color = "green")

	x_ticks .+= 3.0 ;
	scatter(fill(x_ticks[1],length(press_LH_4_v)), press_LH_4_v, color = "red", alpha = 0.3) ;
	scatter(fill(x_ticks[2],length(press_LH_0_v)), press_LH_0_v, color = "blue", alpha = 0.3) ;
	scatter(fill(x_ticks[3],length(press_LH_1_v)), press_LH_1_v, color = "green", alpha = 0.3) ;

	errorbar(x_ticks[1], mean(press_LH_4_v[map(x->!isnan(x), press_LH_4_v)]), yerr = std(press_LH_4_v[map(x->!isnan(x), press_LH_4_v)]) / sqrt(length(press_LH_4_v[map(x->!isnan(x), press_LH_4_v)])), 
				marker = "D", markersize = 10, capsize = 10, color = "red")
	errorbar(x_ticks[2], mean(press_LH_0_v[map(x->!isnan(x), press_LH_0_v)]), yerr = std(press_LH_0_v[map(x->!isnan(x), press_LH_0_v)]) / sqrt(length(press_LH_0_v[map(x->!isnan(x), press_LH_0_v)])), 
				marker = "D", markersize = 10, capsize = 10, color = "blue")
	errorbar(x_ticks[3], mean(press_LH_1_v[map(x->!isnan(x), press_LH_1_v)]), yerr = std(press_LH_1_v[map(x->!isnan(x), press_LH_1_v)]) / sqrt(length(press_LH_1_v[map(x->!isnan(x), press_LH_1_v)])), 
				marker = "D", markersize = 10, capsize = 10, color = "green")

	x_ticks .+= 3.0 ;
	scatter(fill(x_ticks[1],length(press_LL_4_v)), press_LL_4_v, color = "red", alpha = 0.3, label = "4 previous") ;
	scatter(fill(x_ticks[2],length(press_LL_0_v)), press_LL_0_v, color = "blue", alpha = 0.3, label = "0 previous") ;
	scatter(fill(x_ticks[3],length(press_LL_1_v)), press_LL_1_v, color = "green", alpha = 0.3, label = "1 previous") ;

	errorbar(x_ticks[1], mean(press_LL_4_v[map(x->!isnan(x), press_LL_4_v)]), yerr = std(press_LL_4_v[map(x->!isnan(x), press_LL_4_v)]) / sqrt(length(press_LL_4_v[map(x->!isnan(x), press_LL_4_v)])), 
				marker = "D", markersize = 10, capsize = 10, color = "red")
	errorbar(x_ticks[2], mean(press_LL_0_v[map(x->!isnan(x), press_LL_0_v)]), yerr = std(press_LL_0_v[map(x->!isnan(x), press_LL_0_v)]) / sqrt(length(press_LL_0_v[map(x->!isnan(x), press_LL_0_v)])), 
				marker = "D", markersize = 10, capsize = 10, color = "blue")
	errorbar(x_ticks[3], mean(press_LL_1_v[map(x->!isnan(x), press_LL_1_v)]), yerr = std(press_LL_1_v[map(x->!isnan(x), press_LL_1_v)]) / sqrt(length(press_LL_1_v[map(x->!isnan(x), press_LL_1_v)])), 
				marker = "D", markersize = 10, capsize = 10, color = "green")

	ax[:set_xticks]([x_ticks[2] - 5.0*3.0, x_ticks[2] - 4.0*3.0, x_ticks[2] - 3.0*3.0, 
		x_ticks[2] - 2.0*3.0, x_ticks[2] - 1.0*3.0, x_ticks[2]])
	ax[:set_xticklabels](["High tone \n High response", "High tone \n Low response",
						"Mid tone \n High response", "Mid tone \n Low response",
						"Low tone \n High response", "Low tone \n Low response"])
	ax[:tick_params](labelsize = 16)
	ylabel("Responses [% of current tone-response]", fontsize = 16)
	legend(fontsize = 16)


	figure()
	ax = gca()

	hist([rt_HH_4_v, rt_HH_1_v, rt_HH_0_v], 50, density = 1, alpha = 0.3,
		stacked = true, color = ["red", "green", "blue"], label = ["4", "1", "0"])

	legend(fontsize = 18)
	title("HH", fontsize = 18)

	figure()
	ax = gca()

	hist([rt_MH_4_v, rt_MH_1_v, rt_MH_0_v], 50, density = 1, alpha = 0.3,
		stacked = true, color = ["red", "green", "blue"], label = ["4", "1", "0"])

	legend(fontsize = 18)
	title("MH", fontsize = 18)

	figure()
	ax = gca()

	hist([rt_LH_4_v, rt_LH_1_v, rt_LH_0_v], 50, density = 1, alpha = 0.3,
		stacked = true, color = ["red", "green", "blue"], label = ["4", "1", "0"])

	legend(fontsize = 18)
	title("LH", fontsize = 18)

	figure()
	ax = gca()

	hist([rt_HL_4_v, rt_HL_1_v, rt_HL_0_v], 50, density = 1, alpha = 0.3,
		stacked = true, color = ["red", "green", "blue"], label = ["4", "1", "0"])

	legend(fontsize = 18)
	title("HL", fontsize = 18)

	figure()
	ax = gca()

	hist([rt_ML_4_v, rt_ML_1_v, rt_ML_0_v], 50, density = 1, alpha = 0.3,
		stacked = true, color = ["red", "green", "blue"], label = ["4", "1", "0"])

	legend(fontsize = 18)
	title("ML", fontsize = 18)

	figure()
	ax = gca()

	hist([rt_LL_4_v, rt_LL_1_v, rt_LL_0_v], 50, density = 1, alpha = 0.3,
		stacked = true, color = ["red", "green", "blue"], label = ["4", "1", "0"])

	legend(fontsize = 18)
	title("LL", fontsize = 18)

	show()
end

function plot_psychometric(subj_v::Array{subj_t,1}, conditioned_tone::Int64,
			  			conditioned_response::Int64,  conditioned_reward::Int64; 
			  			fit = false, curve = :none)

	unique_subj_v = get_unique_subj_v(subj_v) ;

	subj_psycho_v = get_psychometric(unique_subj_v, conditioned_tone, 
									conditioned_response, conditioned_reward)	

	n_tones = size(subj_psycho_v[1].acc_m, 1) ;
	n_subj = length(subj_psycho_v) ;

	r_2_m = Matrix{Float64}(undef, n_tones, n_subj) ;
	rt_2_m = Matrix{Float64}(undef, n_tones, n_subj) ;

	r_8_m = Matrix{Float64}(undef, n_tones, n_subj) ;
	rt_8_m = Matrix{Float64}(undef, n_tones, n_subj) ;

	#x_data = [2.0, 4.5, 4.75, 5.25, 5.5, 8.0] ;
	#x_data = [2.0, 4.0, 5.0, 6.0, 8.0] ;
	x_data = [2.0, 5.0, 5.5, 6.0, 9.0] ;
	#x_data = [2.0, 5.0, 8.0] ;

	bic_2_v = Array{Float64,1}() ;
	aic_2_v = Array{Float64,1}() ;
	bic_8_v = Array{Float64,1}() ;
	aic_8_v = Array{Float64,1}() ;

	i = 1 ;
	for subj in subj_psycho_v 
		r_2_m[:, i] = subj.acc_m[:,1] ;
		rt_2_m[:, i] = subj.rt_m[:,1] ;

		r_8_m[:, i] = subj.acc_m[:,2] ;
		rt_8_m[:, i] = subj.rt_m[:,2] ;

		i += 1 ;
	end
	
	figure()
	ax = gca()

	for tone = 1 : n_tones
		scatter(fill(x_data[tone], n_subj), r_2_m[tone,:], alpha = 0.5, color = "black")
		errorbar(x_data[tone], mean(r_2_m[tone,:]), yerr = std(r_2_m[tone,:]), 
				marker = "D", markersize = 10, capsize = 10, color = "black")
	end

	if fit && curve == :all
		x = collect(minimum(x_data):0.1:maximum(x_data)) ;
		
		(cf_2, bic, aic) = fit_psychometric(unique_subj_v, x_data, 2, :log_std) ;
		push!(bic_2_v, bic) ;
		push!(aic_2_v, aic) ;
		plot(x, log_std_model(x, cf_2),"-b", label = "log 1 std")

		(cf_2, bic, aic) = fit_psychometric(unique_subj_v, x_data, 2, :log_2std) ;
		push!(bic_2_v, bic) ;
		push!(aic_2_v, aic) ;
		plot(x, log_2std_2_model(x, cf_2),"-r", label = "log 2 std")

		(cf_2, bic, aic) = fit_psychometric(unique_subj_v, x_data, 2, :log_std_offset) ;
		push!(bic_2_v, bic) ;
		push!(aic_2_v, aic) ;
		plot(x, log_std_offset_2_model(x, cf_2),"-m", label = "log 1 std 1 offset")

		(cf_2, bic, aic) = fit_psychometric(unique_subj_v, x_data, 2, :log_std_2offset) ;
		push!(bic_2_v, bic) ;
		push!(aic_2_v, aic) ;
		plot(x, log_std_2offset_2_model(x, cf_2),"-c", label = "log 1 std 2 offset")

		(cf_2, bic, aic) = fit_psychometric(unique_subj_v, x_data, 2, :sig) ;
		push!(bic_2_v, bic) ;
		push!(aic_2_v, aic) ;
		plot(x, sig_model(x, cf_2),"-g", label = "sigmoid")
		
		(cf_2, bic, aic) = fit_psychometric(unique_subj_v, x_data, 2, :sig_mean_std) ;
		push!(bic_2_v, bic) ;
		push!(aic_2_v, aic) ;
		plot(x, sig_mean_std_model(x, cf_2),"-y", label = "sigmoid w/o bounds")
		
	end

	legend(fontsize = 20, frameon = false)
	title("High reward responses", fontsize = 16)
	ax.tick_params(labelsize = 20)

	figure()
	ax = gca()

	for tone = 1 : n_tones
		scatter(fill(x_data[tone], n_subj), r_8_m[tone,:], alpha = 0.5, color = "black")
		errorbar(x_data[tone], mean(r_8_m[tone,:]), yerr = std(r_8_m[tone,:]), 
				marker = "D", markersize = 10, capsize = 10, color = "black")
	end

	if fit && curve == :all
		x = collect(minimum(x_data):0.1:maximum(x_data)) ;
		
		(cf_8, bic, aic) = fit_psychometric(unique_subj_v, x_data, 8, :log_std) ;
		push!(bic_8_v, bic) ;
		push!(aic_8_v, aic) ;
		plot(x, log_std_model(x, cf_8),"-b", label = "log 1 std")

		(cf_8, bic, aic) = fit_psychometric(unique_subj_v, x_data, 8, :log_2std) ;
		push!(bic_8_v, bic) ;
		push!(aic_8_v, aic) ;
		plot(x, log_2std_8_model(x, cf_8),"-r", label = "log 2 std")

		(cf_8, bic, aic) = fit_psychometric(unique_subj_v, x_data, 8, :log_std_offset) ;
		push!(bic_8_v, bic) ;
		push!(aic_8_v, aic) ;
		plot(x, log_std_offset_8_model(x, cf_8),"-m", label = "log 1 std 1 offset")

		(cf_8, bic, aic) = fit_psychometric(unique_subj_v, x_data, 8, :log_std_2offset) ;
		push!(bic_8_v, bic) ;
		push!(aic_8_v, aic) ;
		plot(x, log_std_2offset_8_model(x, cf_8),"-c", label = "log 1 std 2 offset")

		(cf_8, bic, aic) = fit_psychometric(unique_subj_v, x_data, 8, :sig) ;
		push!(bic_8_v, bic) ;
		push!(aic_8_v, aic) ;
		plot(x, sig_model(x, cf_8),"-g", label = "sigmoid")
		
		(cf_8, bic, aic) = fit_psychometric(unique_subj_v, x_data, 8, :sig_mean_std) ;
		push!(bic_8_v, bic) ;
		push!(aic_8_v, aic) ;
		plot(x, sig_mean_std_model(x, cf_8),"-y", label = "sigmoid w/o bounds")
		
	end

	legend(fontsize = 20, frameon = false)
	title("Low reward responses", fontsize = 16)
	ax.tick_params(labelsize = 20)

	if fit && curve == :all
		x_step = 0.2 ;

		figure()
		ax = gca()

		plot(1.0:length(bic_2_v), bic_2_v, color = "blue", linestyle = "", marker = "o", markersize = 15, 
										label = "BIC")
		plot((1.0:length(aic_2_v)) .+ x_step, aic_2_v, color = "red", linestyle = "", marker = "o", markersize = 15, 
										label = "AIC")

		ax.set_xticks((1.0:length(bic_2_v)) .+ x_step/2.0)
		ax.set_xticklabels(["log 1 std", "log 2 std", "log std offset", "log std 2 offsets", "sigmoid", "sigmoid w/o bounds"])
		ax.tick_params(labelsize = 20)

		legend(fontsize = 20, frameon = false)
		title("High reward responses", fontsize = 20)

		figure()	
		ax = gca()

		plot(1.0:length(bic_8_v), bic_8_v, color = "blue", linestyle = "", marker = "o", markersize = 15,
										label = "BIC")
		plot((1.0:length(aic_8_v)) .+ 0.2, aic_8_v, color = "red", linestyle = "", marker = "o", markersize = 15,
										label = "AIC")

		ax.set_xticks((1.0:length(bic_8_v)) .+ x_step/2.0)
		ax.set_xticklabels(["log 1 std", "log 2 std", "log std offset", "log std 2 offsets", "sigmoid", "sigmoid w/o bounds"])
		ax.tick_params(labelsize = 20)

		legend(fontsize = 20, frameon = false)
		title("Low reward responses", fontsize = 20)
	end
	#=
	figure()
	ax = gca()

	for tone = 1 : n_tones
		scatter(fill(x_data[tone], n_subj), rt_2_m[tone,:], alpha = 0.5)
		errorbar(x_data[tone], mean(rt_2_m[tone,map(x->!isnan(x), rt4_m[tone,:])]), 
				yerr = std(rt_2_m[tone,map(x->!isnan(x), rt4_m[tone,:])]), marker = "D", markersize = 10, capsize = 10)
	end

	title("High tone RTs", fontsize = 16)
	ax[:tick_params](labelsize = 16)

	figure()
	ax = gca()

	for tone = 1 : n_tones
		scatter(fill(x_data[tone], n_subj), rt_8_m[tone,:], alpha = 0.5)
		errorbar(x_data[tone], mean(rt_8_m[tone,map(x->!isnan(x), rt1_m[tone,:])]), 
				yerr = std(rt_8_m[tone,map(x->!isnan(x), rt1_m[tone,:])]), marker = "D", markersize = 10, capsize = 10)
	end

	title("Low tone RTs", fontsize = 16)
	ax[:tick_params](labelsize = 16)
	=#
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
	title("response ; past reward", fontsize = 16)
	legend()

	figure()
	scatter(1:n_trials_in_the_past, mi_pp_v, label = "Actual I")
	scatter((1:n_trials_in_the_past, 1:n_trials_in_the_past), ci_pp_v, label = "Shuffled confidence interval")
	xticks(x_ticks, [string(i) for i in 1:n_trials_in_the_past])
	xlabel("Trials in the past", fontsize = 16)
	ylabel("I", fontsize = 16)
	title("response ; past response", fontsize = 16)
	legend()

	figure()
	scatter(1:n_trials_in_the_past, mi_prp_v, label = "Actual I")
	scatter((1:n_trials_in_the_past, 1:n_trials_in_the_past), ci_prp_v, label = "Shuffled confidence interval")
	xticks(x_ticks, [string(i) for i in 1:n_trials_in_the_past])
	xlabel("Trials in the past", fontsize = 16)
	ylabel("I", fontsize = 16)
	title("response ; past reward | past response", fontsize = 16)
	legend()

	figure()
	scatter(1:n_trials_in_the_past, mi_ppr_v, label = "Actual I")
	scatter((1:n_trials_in_the_past, 1:n_trials_in_the_past), ci_ppr_v, label = "Shuffled confidence interval")
	xticks(x_ticks, [string(i) for i in 1:n_trials_in_the_past])
	xlabel("Trials in the past", fontsize = 16)
	ylabel("I", fontsize = 16)
	title("response ; past response | past reward", fontsize = 16)
	legend()

	figure()
	scatter(1:n_trials_in_the_past, mi_pt_v, label = "Actual I")
	scatter((1:n_trials_in_the_past, 1:n_trials_in_the_past), ci_pt_v, label = "Shuffled confidence interval")
	xticks(x_ticks, [string(i) for i in 1:n_trials_in_the_past])
	xlabel("Trials in the past", fontsize = 16)
	ylabel("I", fontsize = 16)
	title("response ; past tone", fontsize = 16)
	legend()
	
	show()
end

