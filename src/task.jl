

function task(sigma::Float64, beta::Float64, c_win::Float64, c_loss::Float64,
			tone::Int64)

	p_2_v = Array{Float64,1}(undef, Int64(rt_max / dt) + 1) ;
	p_8_v = Array{Float64,1}(undef, Int64(rt_max / dt) + 1) ;
	p_w_v = Array{Float64,1}(undef, Int64(rt_max / dt) + 1) ;

	n_trials = 1 ;
	rng = MersenneTwister(1234);

	response_v = Array{Int64}(undef, n_trials) ;
	tone_v = Array{Int64}(undef, n_trials) ;
	rt_v = Array{Float64}(undef, n_trials) ;

	lhood_2 = Normal(log(2.0), sigma) ;
	lhood_8 = Normal(log(8.0), sigma) ;

	for i = 1 : n_trials

		#tone_v[i] = rand(rng, [2,5,8]) ;
		tone_v[i] = tone ;
		if tone_v[i] == 2 
			p_x = p_x_2 ;
		elseif tone_v[i] == 8 
			p_x = p_x_8 ;
		else
			p_x = p_x_amb ;
		end

		decision_made = false ;
		rt = 0.0 ;
		a = 0 ;
		p_post_2 = 0.5 ;
		p_post_8 = 0.5 ;

		#=
		while rt <= rt_max && !decision_made
			x = rand(p_x) ;

			p_lhood_2 = pdf(lhood_2, x) ;
			p_lhood_8 = pdf(lhood_8, x) ;

			(p_post_2, p_post_8) = perception(p_lhood_2, p_lhood_8, p_post_2, p_post_8) ;

			(e_2, e_8) = expected_outcome(p_post_2, p_post_8, c_win, c_loss) ;

			(a, p_2_v[j], p_8_v[j], p_w_v[j]) = action(e_2, e_8, r_w, beta) ;
			j += 1 ;

			a == 2 || a == 8 ? decision_made = false : rt += dt ; # dont make decisions, run until rt_max
		end
		=#
		for j = 1 : length(p_2_v)
			x = rand(p_x) ;

			p_lhood_2 = pdf(lhood_2, x) ;
			p_lhood_8 = pdf(lhood_8, x) ;

			(p_post_2, p_post_8) = perception(p_lhood_2, p_lhood_8, p_post_2, p_post_8) ;

			(e_2, e_8) = expected_outcome(p_post_2, p_post_8, c_win, c_loss) ;

			(a, p_2_v[j], p_8_v[j], p_w_v[j]) = action(e_2, e_8, r_w, beta) ;

			a == 2 || a == 8 ? decision_made = false : rt += dt ; # dont make decisions, run until rt_max
		end

		response_v[i] = a ;
		rt_v[i] = rt ;
	end

	return (p_2_v, p_8_v, p_w_v)
	#return get_agent_stats(tone_v, response_v, rt_v)
end
