
function mutual_info(curr_press_v::Array{Int64,1}, past_reward_v::Array{Int64,1}, 
					past_press_v::Array{Int64,1}, n_trials_v::Array{Int64,1})

	mi_pr_v = Array{Float64,1}() ;
	mi_pp_v = Array{Float64,1}() ;
	mi_prp_v = Array{Float64,1}() ;
	mi_ppr_v = Array{Float64,1}() ;
	e_cp_v = Array{Float64,1}(undef, length(n_trials_v)) ;

	cum_n_trials = 0 ;
	for i = 1 : length(n_trials_v)
		e_cp_v[i] = estimate_entropy(curr_press_v[1 + cum_n_trials:n_trials_v[i] + cum_n_trials]) ;
		if e_cp_v[i] > 1e-16
			push!(mi_pr_v, mutual_information(curr_press_v[1 + cum_n_trials:n_trials_v[i] + cum_n_trials], 
								past_reward_v[1 + cum_n_trials:n_trials_v[i] + cum_n_trials]) / e_cp_v[i]) ;
			push!(mi_pp_v, mutual_information(curr_press_v[1 + cum_n_trials:n_trials_v[i] + cum_n_trials], 
								past_press_v[1 + cum_n_trials:n_trials_v[i] + cum_n_trials]) / e_cp_v[i]) ;
			push!(mi_prp_v, conditional_mi(curr_press_v[1 + cum_n_trials:n_trials_v[i] + cum_n_trials], 
								past_reward_v[1 + cum_n_trials:n_trials_v[i] + cum_n_trials], 
								past_press_v[1 + cum_n_trials:n_trials_v[i] + cum_n_trials]) / e_cp_v[i]) ;
			push!(mi_ppr_v, conditional_mi(curr_press_v[1 + cum_n_trials:n_trials_v[i] + cum_n_trials], 
								past_press_v[1 + cum_n_trials:n_trials_v[i] + cum_n_trials], 
								past_reward_v[1 + cum_n_trials:n_trials_v[i] + cum_n_trials]) / e_cp_v[i]) ;
		end
		cum_n_trials += n_trials_v[i] ;
	end

	mi_pr = mean(mi_pr_v) ;
	mi_pp = mean(mi_pp_v) ;
	mi_prp = mean(mi_prp_v) ;
	mi_ppr = mean(mi_ppr_v) ;

	rng = MersenneTwister(1234) ;
	n_shuffle = 1000 ;

	smi_pr = Array{Float64,1}(undef, n_shuffle) ;
	smi_pp = Array{Float64,1}(undef, n_shuffle) ;
	smi_prp = Array{Float64,1}(undef, n_shuffle) ;
	smi_ppr = Array{Float64,1}(undef, n_shuffle) ;
	
	for s = 1 : n_shuffle
		smi_pr_v = Array{Float64,1}() ;
		smi_pp_v = Array{Float64,1}() ;
		smi_prp_v = Array{Float64,1}() ;
		smi_ppr_v = Array{Float64,1}() ;
		cum_n_trials = 0 ;
		for i = 1 : length(n_trials_v)
			if e_cp_v[i] > 1e-16
				past_tuple = map((x,y) -> (x,y), past_reward_v[1 + cum_n_trials:n_trials_v[i] + cum_n_trials], 
												past_press_v[1 + cum_n_trials:n_trials_v[i] + cum_n_trials]) ;
				shuffle!(rng, past_tuple) ;

				past_reward_v[1 + cum_n_trials:n_trials_v[i] + cum_n_trials] = map(x -> x[1], past_tuple) ;
				past_press_v[1 + cum_n_trials:n_trials_v[i] + cum_n_trials] = map(x -> x[2], past_tuple) ;
				
				push!(smi_pr_v, mutual_information(curr_press_v[1 + cum_n_trials:n_trials_v[i] + cum_n_trials], 
									past_reward_v[1 + cum_n_trials:n_trials_v[i] + cum_n_trials]) / e_cp_v[i]) ;
				push!(smi_pp_v, mutual_information(curr_press_v[1 + cum_n_trials:n_trials_v[i] + cum_n_trials], 
									past_press_v[1 + cum_n_trials:n_trials_v[i] + cum_n_trials]) / e_cp_v[i]) ;
				push!(smi_prp_v, conditional_mi(curr_press_v[1 + cum_n_trials:n_trials_v[i] + cum_n_trials], 
									past_reward_v[1 + cum_n_trials:n_trials_v[i] + cum_n_trials], 
									past_press_v[1 + cum_n_trials:n_trials_v[i] + cum_n_trials]) / e_cp_v[i]) ;
				push!(smi_ppr_v, conditional_mi(curr_press_v[1 + cum_n_trials:n_trials_v[i] + cum_n_trials], 
									past_press_v[1 + cum_n_trials:n_trials_v[i] + cum_n_trials], 
									past_reward_v[1 + cum_n_trials:n_trials_v[i] + cum_n_trials]) / e_cp_v[i]) ;
			end
			cum_n_trials += n_trials_v[i] ;
		end
		
		smi_pr[s] = mean(smi_pr_v) ;
		smi_pp[s] = mean(smi_pp_v) ;
		smi_prp[s] = mean(smi_prp_v) ;
		smi_ppr[s] = mean(smi_ppr_v) ;
	end

	ci_pr = confint(OneSampleTTest(smi_pr)) ;
	ci_pp = confint(OneSampleTTest(smi_pp)) ;
	ci_prp = confint(OneSampleTTest(smi_prp)) ;
	ci_ppr = confint(OneSampleTTest(smi_ppr)) ;


	println(" n_data_points = ", length(curr_press_v))
	println("shuffled mi conf int, press - past reward: ", ci_pr, " , actual value: ", mi_pr)
	println("shuffled mi conf int, press - past press: ", ci_pp, " , actual value: ", mi_pp)
	println("shuffled conditional mi conf int, press - past reward|past press: ", ci_prp, " , actual value: ", mi_prp)
	println("shuffled conditional mi conf int, press - past press|past reward: ", ci_ppr, " , actual value: ", mi_ppr)
	println("------------------------------------------------------------------------------------")
	return [mi_pr, mi_pp, mi_prp, mi_ppr, ci_pr, ci_pp, ci_prp, ci_ppr]
end

conditional_mi(d1::Array{Int64,1}, d2::Array{Int64,1}, cond_d::Array{Int64,1}) = double_joint_entropy(d1, cond_d) + 
																		double_joint_entropy(d2, cond_d) - 
																		triple_joint_entropy(d1, d2, cond_d) - 
																		estimate_entropy(cond_d)


function triple_joint_entropy(d1::Array{Int64,1}, d2::Array{Int64,1}, d3::Array{Int64,1})

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

function double_joint_entropy(d1::Array{Int64,1}, d2::Array{Int64,1})

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