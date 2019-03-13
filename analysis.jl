function get_switch_after_incorr(subj_v::Array{subj_t,1})

	dict = Dict{String, Tuple{Float64, Float64, Float64, Float64, Int64}}() ;

	total_n_incorr_before_amb = 0 ;
	total_n_switch = 0 ;

	for subj in subj_v

		n_incorr_before_amb = 0 ;
		n_switch = 0 ;

		if !haskey(dict, subj.id)
			switch_rt_v = Array{Float64,1}() ;
			not_switch_rt_v = Array{Float64,1}() ;
			subj_idx = findall(x -> x.id == subj.id, subj_v) ;
			for idx in subj_idx
				for i = 2 : length(subj_v[idx].press_v)
					if subj_v[idx].reward_v[i-1] == 0 && subj_v[idx].tone_v[i] == 5 && 
						subj_v[idx].press_v[i-1] != 0 && subj_v[idx].tone_v[i-1] != 0

						n_incorr_before_amb += 1 ;
						if subj_v[idx].press_v[i] != subj_v[idx].press_v[i-1]
							n_switch += 1 ;
							push!(switch_rt_v, subj_v[idx].rt_v[i]) ;
						else
							push!(not_switch_rt_v, subj_v[idx].rt_v[i]) ;
						end
					elseif subj_v[idx].tone_v[i] == 5 && 
						subj_v[idx].press_v[i-1] != 0 && subj_v[idx].tone_v[i-1] != 0

						push!(not_switch_rt_v, subj_v[idx].rt_v[i]) ;
					end
				end
			end

			p = 0.5 ;
			cum_prob =  0.0 ;
			n_switch_binom = n_incorr_before_amb ;

			while cum_prob < 0.05
				cum_prob += binomial(Int128(n_incorr_before_amb), Int128(n_switch_binom)) * p^n_switch_binom * 
									(1.0 - p)^(n_incorr_before_amb - n_switch_binom) ;
				n_switch_binom -= 1 ;
			end
			dict[subj.id] = (100.0*n_switch/n_incorr_before_amb, 
							100.0*(n_switch_binom + 1)/n_incorr_before_amb,
							mean(switch_rt_v),
							mean(not_switch_rt_v),
							n_incorr_before_amb) ;

			total_n_incorr_before_amb += n_incorr_before_amb ;
			total_n_switch += n_switch ;
		end
	end
	#=
	p = 0.5 ;
	total_cum_prob =  0.0 ;
	total_n_switch_binom = total_n_incorr_before_amb ;

	while total_cum_prob < 0.05
		total_cum_prob += binomial(BigInt(total_n_incorr_before_amb), BigInt(total_n_switch_binom)) * 
				p^total_n_switch_binom * (1.0 - p)^(total_n_incorr_before_amb - total_n_switch_binom) ;
		total_n_switch_binom -= 1 ;
	end

	println(100.0*total_n_switch/total_n_incorr_before_amb, " ",
		100.0*(total_n_switch_binom + 1)/total_n_incorr_before_amb)
	=#
	return dict
end

function get_same_after_corr(subj_v::Array{subj_t,1})

	dict = Dict{String, Tuple{Float64, Float64}}() ;

	total_n_corr_before_amb = 0 ;
	total_n_same = 0 ;

	for subj in subj_v

		n_corr_before_amb = 0 ;
		n_same = 0 ;

		if !haskey(dict, subj.id)
			subj_idx = findall(x -> x.id == subj.id, subj_v) ;
			for idx in subj_idx
				for i = 2 : length(subj_v[idx].press_v)
					if subj_v[idx].reward_v[i-1] != 0 && subj_v[idx].tone_v[i] == 5
						n_corr_before_amb += 1 ;
						if subj_v[idx].press_v[i] == subj_v[idx].press_v[i-1]
							n_same += 1 ;
						end
					end
				end
			end

			p = 0.5 ;
			cum_prob =  0.0 ;
			n_same_binom = n_corr_before_amb ;

			while cum_prob < 0.05
				cum_prob += binomial(BigInt(n_corr_before_amb), BigInt(n_same_binom)) * p^n_same_binom * 
									(1.0 - p)^(n_corr_before_amb - n_same_binom) ;
				n_same_binom -= 1 ;
			end
			dict[subj.id] = (100.0*n_same/n_corr_before_amb, 100.0*(n_same_binom + 1)/n_corr_before_amb) ;

			total_n_corr_before_amb += n_corr_before_amb ;
			total_n_same += n_same ;
		end
	end
	#=
	p = 0.5 ;
	total_cum_prob =  0.0 ;
	total_n_same_binom = total_n_corr_before_amb ;

	while total_cum_prob < 0.05
		total_cum_prob += binomial(BigInt(total_n_corr_before_amb), BigInt(total_n_same_binom)) * 
				p^total_n_same_binom * (1.0 - p)^(total_n_corr_before_amb - total_n_same_binom) ;
		total_n_same_binom -= 1 ;
	end

	println(100.0*total_n_same/total_n_corr_before_amb, " ",
		100.0*(total_n_same_binom + 1)/total_n_corr_before_amb)
	=#
	return dict
end