
function mutual_info(subj_v::Array{subj_t,1}, n_trials_in_the_past::Int64)

	mi_pr_v = Array{Float64,1}() ;
	mi_pp_v = Array{Float64,1}() ;
	mi_prp_v = Array{Float64,1}() ;
	mi_ppr_v = Array{Float64,1}() ;
	mi_pt_v = Array{Float64,1}() ;

	e_cp_v = Array{Float64,1}(undef, length(subj_v)) ;
	e_pr_v = Array{Float64,1}(undef, length(subj_v)) ;
	e_pp_v = Array{Float64,1}(undef, length(subj_v)) ;
	e_pt_v = Array{Float64,1}(undef, length(subj_v)) ;

	i = 1 ;
	for subj in subj_v
		#mask_amb_trial = map((x,y,z) -> x == 5 && y != 0 && z > n_trials_in_the_past, 
		#			subj.tone_v, subj.press_v, 1:length(subj.tone_v)) ;
		mask_amb_trial = map((y,z) -> y != 0 && z > n_trials_in_the_past, 
							subj.press_v, 1:length(subj.tone_v)) ;
		past_trial_idx_v = findall(x ->  x == true, mask_amb_trial) .- n_trials_in_the_past ;

		e_cp_v[i] = get_entropy(subj.press_v[mask_amb_trial]) ;
		e_pr_v[i] = get_entropy(subj.reward_v[past_trial_idx_v]) ;
		e_pp_v[i] = get_entropy(subj.press_v[past_trial_idx_v]) ;
		e_pt_v[i] = get_entropy(subj.tone_v[mask_amb_trial]) ;

		if e_cp_v[i] > 1e-16
			push!(mi_pr_v, mutual_information(subj.press_v[mask_amb_trial], 
											subj.reward_v[past_trial_idx_v]) / e_cp_v[i]) ;
			push!(mi_pp_v, mutual_information(subj.press_v[mask_amb_trial],
											subj.press_v[past_trial_idx_v]) / e_cp_v[i]) ;
			push!(mi_prp_v, conditional_mi(subj.press_v[mask_amb_trial],
											subj.reward_v[past_trial_idx_v],
											subj.press_v[past_trial_idx_v]) / e_cp_v[i]) ;
			push!(mi_ppr_v, conditional_mi(subj.press_v[mask_amb_trial],
											subj.press_v[past_trial_idx_v],
											subj.reward_v[past_trial_idx_v]) / e_cp_v[i]) ;
			push!(mi_pt_v, mutual_information(subj.press_v[mask_amb_trial], 
											subj.tone_v[past_trial_idx_v]) / e_cp_v[i]) ;
		end
		i += 1 ;
	end

	mi_pr = mean(mi_pr_v) ;
	mi_pp = mean(mi_pp_v) ;
	mi_prp = mean(mi_prp_v) ;
	mi_ppr = mean(mi_ppr_v) ;
	mi_pt = mean(mi_pt_v) ;

	rng = MersenneTwister(1234) ;
	n_shuffle = 1000 ;

	smi_pr = Array{Float64,1}(undef, n_shuffle) ;
	smi_pp = Array{Float64,1}(undef, n_shuffle) ;
	smi_prp = Array{Float64,1}(undef, n_shuffle) ;
	smi_ppr = Array{Float64,1}(undef, n_shuffle) ;
	smi_pt = Array{Float64,1}(undef, n_shuffle) ;

	for s = 1 : n_shuffle
		smi_pr_v = Array{Float64,1}() ;
		smi_pp_v = Array{Float64,1}() ;
		smi_prp_v = Array{Float64,1}() ;
		smi_ppr_v = Array{Float64,1}() ;
		smi_pt_v = Array{Float64,1}() ;

		i = 1 ;
		for subj in subj_v
			if e_cp_v[i] > 1e-16
				#mask_amb_trial = map((x,y,z) -> x == 5 && y != 0 && z > n_trials_in_the_past, 
				#				subj.tone_v, subj.press_v, 1:length(subj.tone_v)) ;
				mask_amb_trial = map((y,z) -> y != 0 && z > n_trials_in_the_past, 
									subj.press_v, 1:length(subj.tone_v)) ;
				past_trial_idx_v = findall(x ->  x == true, mask_amb_trial) .- n_trials_in_the_past ;

				past_press_v = subj.press_v[past_trial_idx_v] ;
				past_reward_v = subj.reward_v[past_trial_idx_v] ;
				past_tone_v = subj.tone_v[past_trial_idx_v] ;

				past_tuple = map((x,y,z) -> (x,y,z), past_reward_v, past_press_v, past_tone_v) ;
				shuffle!(rng, past_tuple) ;

				past_reward_v = map(x -> x[1], past_tuple) ;
				past_press_v = map(x -> x[2], past_tuple) ;
				past_tone_v = map(x -> x[3], past_tuple) ;

				push!(smi_pr_v, mutual_information(subj.press_v[mask_amb_trial], 
											past_reward_v) / e_cp_v[i]) ;
				push!(smi_pp_v, mutual_information(subj.press_v[mask_amb_trial],
												past_press_v) / e_cp_v[i]) ;
				push!(smi_prp_v, conditional_mi(subj.press_v[mask_amb_trial],
												past_reward_v,
												past_press_v) / e_cp_v[i]) ;
				push!(smi_ppr_v, conditional_mi(subj.press_v[mask_amb_trial],
												past_press_v,
												past_reward_v) / e_cp_v[i]) ;
				push!(smi_pt_v, mutual_information(subj.press_v[mask_amb_trial], 
											past_tone_v) / e_cp_v[i]) ;
			end
			i += 1 ;
		end
		smi_pr[s] = mean(smi_pr_v) ;
		smi_pp[s] = mean(smi_pp_v) ;
		smi_prp[s] = mean(smi_prp_v) ;
		smi_ppr[s] = mean(smi_ppr_v) ;
		smi_pt[s] = mean(smi_pt_v) ;
	end

	ci_pr = confint(OneSampleTTest(smi_pr)) ;
	ci_pp = confint(OneSampleTTest(smi_pp)) ;
	ci_prp = confint(OneSampleTTest(smi_prp)) ;
	ci_ppr = confint(OneSampleTTest(smi_ppr)) ;
	ci_pt = confint(OneSampleTTest(smi_pt)) ;

	return [mi_pr, mi_pp, mi_prp, mi_ppr, ci_pr, ci_pp, ci_prp, ci_ppr, mi_pt, ci_pt]
end

conditional_mi(d1::Array{Int64,1}, d2::Array{Int64,1}, cond_d::Array{Int64,1}) = get_joint_entropy_2(d1, cond_d) + 
																		get_joint_entropy_2(d2, cond_d) - 
																		get_joint_entropy_3(d1, d2, cond_d) - 
																		get_entropy(cond_d)


function get_joint_entropy_3(d1::Array{Int64,1}, d2::Array{Int64,1}, d3::Array{Int64,1})

	d_tuple = Array{Tuple{Int64, Int64, Int64},1}() ;
	n_data = length(d1) ;

	for i = 1 : n_data
		push!(d_tuple, (d1[i], d2[i], d3[i])) ;
	end

	cm = countmap(d_tuple) ;
	e = 0 ;
	for key in collect(keys(cm)) 
		e += - (cm[key]/n_data) * log((cm[key]/n_data)) ;
	end

	return e
end

function get_joint_entropy_2(d1::Array{Int64,1}, d2::Array{Int64,1})

	d_tuple = Array{Tuple{Int64, Int64},1}() ;
	n_data = length(d1) ;

	for i = 1 : n_data
		push!(d_tuple, (d1[i], d2[i])) ;
	end

	cm = countmap(d_tuple) ;
	e = 0 ;
	for key in collect(keys(cm)) 
		e += - (cm[key]/n_data) * log((cm[key]/n_data)) ;
	end

	return e
end

function get_entropy(d1::Array{Int64,1})

	n_data = length(d1) ;

	cm = countmap(d1) ;
	e = 0 ;
	for key in collect(keys(cm)) 
		e += - (cm[key]/n_data) * log((cm[key]/n_data)) ;
	end

	return e
end