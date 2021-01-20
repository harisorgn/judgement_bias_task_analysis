struct subj_psycho_t
	id::String
	acc_m::Matrix{Float64}
	rt_m::Matrix{Float64}
	conditioned_tone::Int64
	conditioned_response::Int64
	conditioned_reward::Int64
end

function get_session_subj(subj_v::Array{subj_t,1}, min_completed_trials::Int64)

	n_sessions = count(x -> x.id == subj_v[1].id, subj_v) ;
	
	error_flag = false ;
	for subj in subj_v
		if count(x -> x.id == subj.id, subj_v) != n_sessions
			println("subject $(subj.id) has different number of sessions")
			error_flag = true ;
		end
	end

	if error_flag
		return 0
	end
	
	session_subj_v = [subj_t[] for i = 1 : n_sessions] ;

	considered_subj_d = Dict{String, Int64}() ;

	for subj in subj_v
		mask_prem = map(x -> x == 0 , subj.tone_v) ;
		if !haskey(considered_subj_d, subj.id) 
			if count(x -> x == false, mask_prem) >= min_completed_trials
				push!(session_subj_v[1], subj) ;
				considered_subj_d[subj.id] = 1 ;
			else
				considered_subj_d[subj.id] = 0 ;
			end
		else
			for i = 2 : n_sessions
				if considered_subj_d[subj.id] == i - 1
					push!(session_subj_v[i], subj) ;
					considered_subj_d[subj.id] += 1 ;
					break ;
				end
			end
		end
	end
	return session_subj_v
end

function get_block_data(subj_v::Array{subj_t,1}, n_blocks::Int64, 
					tone_playing, response_made)

	resp_m = Matrix{Float64}(undef, length(subj_v), n_blocks) ;
	rt_m = Matrix{Float64}(undef, length(subj_v), n_blocks) ;

	s = 1 ;
	for subj in subj_v
		
		mask_prem = map((x,y) -> x == 0 && y != 0, subj.tone_v, subj.response_v) ;
		tone_v = subj.tone_v[.!mask_prem] ;
		response_v = subj.response_v[.!mask_prem] ;
		rt_v = subj.rt_v[.!mask_prem] ;

		block_sz = Int64(ceil(length(tone_v) / n_blocks)) ;
	
		for i = 1 : n_blocks
			mask_tone_resp = map((x,y,z) -> x == tone_playing && y == response_made && z <= i*block_sz && z > (i-1)*block_sz, 
				tone_v, response_v, 1:length(tone_v)) ;

			if tone_playing != 0
				mask_tone = map((x,z) -> x == tone_playing && z <= i*block_sz && z > (i-1)*block_sz, 
					tone_v, 1:length(tone_v)) ;

				resp_m[s,i] = 100.0*count(x -> x == true, mask_tone_resp) / count(x -> x == true, mask_tone) ;
				rt_m[s,i] = mean(rt_v[mask_tone_resp]) ;
			else
				resp_m[s,i] = 100.0*count(x -> x == true, mask_tone_resp) / (ceil(length(subj.tone_v))/n_blocks) ;
			end

		end
		s += 1 ;
	end
	return (resp_m, rt_m)
end

function get_switch_after_incorr(subj_v::Array{subj_t,1})

	dict = Dict{String, Tuple{Float64, Float64, Float64, Float64, Int64, Int64, Int64}}() ;

	n_more_than_two_sessions = 0 ;
	for subj in subj_v

		n_incorr_before_p = 0 ;
		n_switch = 0 ;
		n_not_switch = 0 ;
		if !haskey(dict, subj.id)
			switch_rt_v = Array{Float64,1}() ;
			not_switch_rt_v = Array{Float64,1}() ;
			subj_idx = findall(x -> x.id == subj.id, subj_v) ;
			if length(subj_idx) > 2
				n_more_than_two_sessions += 1 ;
			end
			for idx in subj_idx
				for i = 2 : length(subj_v[idx].response_v)
					if subj_v[idx].reward_v[i-1] == 0 && subj_v[idx].tone_v[i] == 5 && 
						subj_v[idx].response_v[i-1] != 0 && subj_v[idx].response_v[i] != 0 &&
						subj_v[idx].tone_v[i-1] != 0 #&& subj_v[idx].tone_v[i-1] != 5

						n_incorr_before_p += 1 ;
						if subj_v[idx].response_v[i] != subj_v[idx].response_v[i-1]
							n_switch += 1 ;
							push!(switch_rt_v, subj_v[idx].rt_v[i]) ;
						else
							push!(not_switch_rt_v, subj_v[idx].rt_v[i]) ;
							n_not_switch += 1 ;
						end
					elseif subj_v[idx].tone_v[i] == 5 && 
						subj_v[idx].response_v[i-1] != 0 && subj_v[idx].response_v[i] != 0 &&                                                      
						subj_v[idx].tone_v[i-1] != 0 && subj_v[idx].tone_v[i-1] != 5

						push!(not_switch_rt_v, subj_v[idx].rt_v[i]) ;
						n_not_switch += 1 ;
					end
				end
			end

			p = 0.5 ;
			cum_prob =  0.0 ;
			n_switch_binom = n_incorr_before_p ;

			while cum_prob < 0.05
				cum_prob += binomial(Int128(n_incorr_before_p), Int128(n_switch_binom)) * p^n_switch_binom * 
									(1.0 - p)^(n_incorr_before_p - n_switch_binom) ;
				n_switch_binom -= 1 ;
			end
			dict[subj.id] = (100.0*n_switch/n_incorr_before_p, 
							100.0*(n_switch_binom + 1)/n_incorr_before_p,
							mean(switch_rt_v),
							mean(not_switch_rt_v),
							n_incorr_before_p,
							n_switch,
							n_not_switch) ;
		end
	end
	
	#println(n_more_than_two_sessions," out of ",length(collect(keys(dict))))
	return dict
end

function get_switch_after_incorr_base(subj_v::Array{subj_t,1})

	dict = Dict{String, Tuple{Float64, Float64, Float64, Float64, Int64, Int64, Int64}}() ;

	n_more_than_two_sessions = 0 ;
	for subj in subj_v

		n_incorr = 0 ;
		n_switch = 0 ;
		n_not_switch = 0 ;
		if !haskey(dict, subj.id)
			switch_rt_v = Array{Float64,1}() ;
			not_switch_rt_v = Array{Float64,1}() ;
			subj_idx = findall(x -> x.id == subj.id, subj_v) ;
			if length(subj_idx) > 2
				n_more_than_two_sessions += 1 ;
			end
			for idx in subj_idx
				for i = 2 : length(subj_v[idx].response_v)
					if subj_v[idx].reward_v[i-1] == 0 && 
						subj_v[idx].response_v[i-1] != 0 && subj_v[idx].response_v[i] != 0
						subj_v[idx].tone_v[i-1] != 0 && subj_v[idx].tone_v[i] != 0

						n_incorr += 1 ;
						if subj_v[idx].response_v[i] != subj_v[idx].response_v[i-1]
							n_switch += 1 ;
							push!(switch_rt_v, subj_v[idx].rt_v[i]) ;
						else
							push!(not_switch_rt_v, subj_v[idx].rt_v[i]) ;
							n_not_switch += 1 ;
						end
					elseif subj_v[idx].response_v[i-1] != 0 && subj_v[idx].response_v[i] != 0
						subj_v[idx].tone_v[i-1] != 0 && subj_v[idx].tone_v[i] != 0

						push!(not_switch_rt_v, subj_v[idx].rt_v[i]) ;
						n_not_switch += 1 ;
					end
				end
			end

			p = 0.5 ;
			cum_prob =  0.0 ;
			n_switch_binom = n_incorr ;

			while cum_prob < 0.05
				cum_prob += binomial(Int128(n_incorr), Int128(n_switch_binom)) * p^n_switch_binom * 
									(1.0 - p)^(n_incorr - n_switch_binom) ;
				n_switch_binom -= 1 ;
			end
			dict[subj.id] = (100.0*n_switch/n_incorr, 
							100.0*(n_switch_binom + 1)/n_incorr,
							mean(switch_rt_v),
							mean(not_switch_rt_v),
							n_incorr,
							n_switch,
							n_not_switch) ;
		end
	end
	
	#println(n_more_than_two_sessions," out of ",length(collect(keys(dict))))
	return dict
end

function get_same_after_corr(subj_v::Array{subj_t,1})

	dict = Dict{String, Tuple{Float64, Float64}}() ;

	total_n_corr_before_p = 0 ;
	total_n_same = 0 ;

	for subj in subj_v

		n_corr_before_p = 0 ;
		n_same = 0 ;

		if !haskey(dict, subj.id)
			subj_idx = findall(x -> x.id == subj.id, subj_v) ;
			for idx in subj_idx
				for i = 2 : length(subj_v[idx].response_v)
					if subj_v[idx].reward_v[i-1] != 0 && subj_v[idx].tone_v[i] == 5
						n_corr_before_p += 1 ;
						if subj_v[idx].response_v[i] == subj_v[idx].response_v[i-1]
							n_same += 1 ;
						end
					end
				end
			end

			p = 0.5 ;
			cum_prob =  0.0 ;
			n_same_binom = n_corr_before_p ;

			while cum_prob < 0.05
				cum_prob += binomial(BigInt(n_corr_before_p), BigInt(n_same_binom)) * p^n_same_binom * 
									(1.0 - p)^(n_corr_before_p - n_same_binom) ;
				n_same_binom -= 1 ;
			end
			dict[subj.id] = (100.0*n_same/n_corr_before_p, 100.0*(n_same_binom + 1)/n_corr_before_p) ;

			total_n_corr_before_p += n_corr_before_p ;
			total_n_same += n_same ;
		end
	end
	
	return dict
end

function get_unique_subj_v(subj_v::Array{subj_t,1})

	# get a single subj_t structure for all sessions of a subject
	# by concatenating the data across sessions

	unique_subj_id_v = unique([subj.id for subj in subj_v]) ;
	unique_subj_v = Array{subj_t,1}() ;

	for id in unique_subj_id_v

		response_v = Array{Int64,1}() ;
		reward_v = Array{Int64,1}() ;
		tone_v = Array{Int64,1}() ;
		rt_v = Array{Float64,1}() ;
		cbi_v = Array{Float64,1}() ;

		subj_idx_v = findall(x -> x.id == id, subj_v)

		for idx in subj_idx_v
			append!(response_v, subj_v[idx].response_v) ;
			append!(reward_v, subj_v[idx].reward_v) ;
			append!(tone_v, subj_v[idx].tone_v) ;
			append!(rt_v, subj_v[idx].rt_v) ;
			push!(cbi_v, subj_v[idx].cbi) ;
		end
		push!(unique_subj_v, 
			subj_t(id,
				response_v,
				reward_v,
				tone_v,
				rt_v,
				mean(cbi_v))) ;
	end
	return unique_subj_v
end

function get_psychometric(subj_v::Array{subj_t,1}, conditioned_tone::Int64, 
						conditioned_response::Int64, conditioned_reward::Int64)

	# conditioned variables correspond to the previous trial

	subj_psycho_t_v = Array{subj_psycho_t,1}() ;

	tone_v = sort!(unique(subj_v[1].tone_v)) ;

	if tone_v[1] == 0 
		tone_v = tone_v[2:end] ;
	end

	for subj in subj_v
		acc_m = Matrix{Float64}(undef, length(tone_v), 2) ;
		rt_m = Matrix{Float64}(undef, length(tone_v), 2) ;

		for i = 1 : length(tone_v)
			mask_tone = get_mask_for_psychometric(subj.tone_v, subj.response_v, subj.reward_v, tone_v[i], 
												conditioned_tone, conditioned_response, conditioned_reward);
			n_trials = length(subj.tone_v[mask_tone]) ;

			acc_m[i, :] = [count(x->x==2, subj.response_v[mask_tone])/n_trials, 
							count(x->x==8, subj.response_v[mask_tone])/n_trials] ;
			rt_m[i, :] = [mean(subj.rt_v[map((x,y) -> x == 2 && y == true, subj.response_v, mask_tone)]), 
						mean(subj.rt_v[map((x,y) -> x == 8 && y == true, subj.response_v, mask_tone)])] ;
		end
		push!(subj_psycho_t_v, subj_psycho_t(subj.id, acc_m, rt_m, 
										conditioned_tone, conditioned_response, conditioned_reward))
	end	

	return subj_psycho_t_v
end

function get_mask_for_psychometric(tone_v::Array{Int64,1}, response_v::Array{Int64,1}, reward_v::Array{Int64,1},
								tone::Int64, conditioned_tone::Int64, 
								conditioned_response::Int64, conditioned_reward::Int64)
	
	if conditioned_tone != -1 && conditioned_response != -1 && conditioned_reward != -1 
		mask_tone = map((x,y,z,k,l) -> x == tone && y != 0 && 
			z == conditioned_tone && k != conditioned_response && l == conditioned_reward, 
			tone_v[2:end], response_v[2:end], 
			tone_v[1:end-1], response_v[1:end-1], reward_v[1:end-1]) ;

		pushfirst!(mask_tone, false) ;
		return mask_tone

	elseif conditioned_tone != -1 && conditioned_response != -1 
		mask_tone = map((x,y,z,k) -> x == tone && y != 0 && 
			z == conditioned_tone && k != conditioned_response, 
			tone_v[2:end], response_v[2:end], 
			tone_v[1:end-1], response_v[1:end-1]) ;

		pushfirst!(mask_tone, false) ;
		return mask_tone

	elseif conditioned_response != -1 && conditioned_reward != -1 
		mask_tone = map((x,y,z,k) -> x == tone && y != 0 && 
			z == conditioned_response && k == conditioned_reward, 
			tone_v[2:end], response_v[2:end], 
			response_v[1:end-1], reward_v[1:end-1]) ;

		pushfirst!(mask_tone, false) ;
		return mask_tone

	elseif conditioned_tone != -1 && conditioned_reward != -1 
		mask_tone = map((x,y,z,k,l) -> x == tone && y != 0 && 
			z == conditioned_tone && k != 0 && l == conditioned_reward, 
			tone_v[2:end], response_v[2:end], 
			tone_v[1:end-1], response_v[1:end-1], reward_v[1:end-1]) ;

		pushfirst!(mask_tone, false) ;
		return mask_tone

	elseif conditioned_tone != -1
		mask_tone = map((x,y,z,k) -> x == tone && y != 0 && z == conditioned_tone && k != 0, 
			tone_v[2:end], response_v[2:end], tone_v[1:end-1], response_v[1:end-1]) ;

		pushfirst!(mask_tone, false) ;
		return mask_tone

	elseif conditioned_response != -1
		mask_tone = map((x,y,z) -> x == tone && y != 0 && z == conditioned_response, 
			tone_v[2:end], response_v[2:end], response_v[1:end-1]) ;

		pushfirst!(mask_tone, false) ;
		return mask_tone

	elseif conditioned_reward != -1
		mask_tone = map((x,y,z) -> x == tone && y != 0 && z == conditioned_reward, 
			tone_v[2:end], response_v[2:end], reward_v[1:end-1]) ;

		pushfirst!(mask_tone, false) ;
		return mask_tone

	else
		mask_tone = map((x,y) -> x == tone && y != 0, tone_v, response_v) ;
		return mask_tone
	end
end
