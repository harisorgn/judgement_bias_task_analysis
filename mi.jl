
function mutual_info(curr_press_v::Array{Int64,1}, past_reward_v::Array{Int64,1}, past_press_v::Array{Int64,1})

	mi_pr = mutual_information(curr_press_v, past_reward_v) ;
	mi_pp = mutual_information(curr_press_v, past_press_v) ;
	mi_prp = conditional_mi(curr_press_v, past_reward_v, past_press_v) ;
	mi_ppr = conditional_mi(curr_press_v, past_press_v, past_reward_v) ;

	rng = MersenneTwister(1234) ;
	n_shuffle = 1000 ;

	smi_pr = Array{Float64,1}(undef, n_shuffle) ;
	smi_pp = Array{Float64,1}(undef, n_shuffle) ;
	smi_prp = Array{Float64,1}(undef, n_shuffle) ;
	smi_ppr = Array{Float64,1}(undef, n_shuffle) ;

	for i = 1 : n_shuffle
		past_tuple = map((x,y) -> (x,y), past_reward_v, past_press_v) ;
		shuffle!(rng, past_tuple) ;

		past_reward_v = map(x -> x[1], past_tuple) ;
		past_press_v = map(x -> x[2], past_tuple) ;

		smi_pr[i] = mutual_information(curr_press_v, past_reward_v) ;
		smi_pp[i] = mutual_information(curr_press_v, past_press_v) ;
		smi_prp[i] = conditional_mi(curr_press_v, past_reward_v, past_press_v) ;
		smi_ppr[i] = conditional_mi(curr_press_v, past_press_v, past_reward_v) ;
	end

	ci_pr = confint(OneSampleTTest(smi_pr)) ;
	ci_pp = confint(OneSampleTTest(smi_pp)) ;
	ci_prp = confint(OneSampleTTest(smi_prp)) ;
	ci_ppr = confint(OneSampleTTest(smi_ppr)) ;

	println("shuffled mi conf int, press - past reward: ", ci_pr, " , actual value: ", mi_pr)
	println("shuffled mi conf int, press - past press: ", ci_pp, " , actual value: ", mi_pp)
	println("shuffled conditional mi conf int, press - past reward|past press: ", ci_prp, " , actual value: ", mi_prp)
	println("shuffled conditional mi conf int, press - past press|past reward: ", ci_ppr, " , actual value: ", mi_ppr)
	return [mi_pr, mi_pp, mi_prp, mi_ppr]
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