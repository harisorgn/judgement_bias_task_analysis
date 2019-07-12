
struct agent_stats
	tone_v::Array{Int64,1}
	response_v::Array{Int64,1}
	rt_2_corr_v::Array{Float64,1} 
	rt_2_incorr_v::Array{Float64,1}
	rt_5_2_v::Array{Float64,1} 
	rt_5_8_v::Array{Float64,1}
	rt_8_corr_v::Array{Float64,1}
	rt_8_incorr_v::Array{Float64,1}
end

struct exp_stats
	rt_2_corr_d::Normal 
	rt_2_incorr_d::Normal
	rt_8_corr_d::Normal
	rt_8_incorr_d::Normal
	n_2_corr::Float64
	n_2_incorr::Float64
	n_8_corr::Float64
	n_8_incorr::Float64
end

lb(x::Float64) = (x < 1e-6 || isnan(x)) ? 1e-6 : x

function obj_func(x::Array{Float64}, grad::Array{Float64})

	log_lhood = 0.0 ;

	for i = 1 : length(rat.rt_v)

		(p_2_v, p_8_v, p_w_v) = trial_fit(x[1], x[2], x[3], x[4], x[5], rat.tone_v[i]) ;

		n_steps = Int64(floor((rat.rt_v[i] - x[6]) / dt)) ;
		p_rt = 1.0 ;
		if n_steps > 1
			for j = 1 : n_steps
				p_rt *= p_w_v[j] ;
			end

			if rat.response_v[i] == 2
				p_rt *= p_2_v[n_steps + 1] ;
			elseif rat.response_v[i] == 8
				p_rt *= p_8_v[n_steps + 1] ;
			end
		elseif n_steps == 1
			if rat.response_v[i] == 2
				p_rt *= p_2_v[n_steps] ;
			elseif rat.response_v[i] == 8
				p_rt *= p_8_v[n_steps] ;
			end
		end

		log_lhood += log(lb(p_rt)) ;
	end
	return log_lhood
end
