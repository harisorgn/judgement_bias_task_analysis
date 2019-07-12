

function task(sigma::Float64, beta::Float64, c_win::Float64, c_loss::Float64)

	rng = MersenneTwister(1234);
	n_trials = 100 ;

	response_v = Array{Int64}(undef, n_trials) ;
	tone_v = Array{Int64}(undef, n_trials) ;
	rt_v = Array{Float64}(undef, n_trials) ;

	lhood_2 = Normal(log(2.0), sigma) ;
	lhood_8 = Normal(log(8.0), sigma) ;

	for i = 1 : n_trials

		tone_v[i] = rand(rng, [2,5,8]) ;

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

		while rt <= rt_max && !decision_made
			x = rand(p_x) ;

			p_lhood_2 = pdf(lhood_2, x) ;
			p_lhood_8 = pdf(lhood_8, x) ;

			(p_post_2, p_post_8) = perception(p_lhood_2, p_lhood_8, p_post_2, p_post_8) ;

			(e_2, e_8) = expected_outcome(p_post_2, p_post_8, c_win, c_loss) ;

			(a, p_2, p_8, p_w) = action(e_2, e_8, r_w, beta) ;

			a == 2 || a == 8 ? decision_made = true : rt += dt ; 
		end
		response_v[i] = a ;
		rt_v[i] = rt ;
	end

	return (tone_v, response_v, rt_v)	
end

function trial_fit(sigma::Float64, sigma_tone::Float64, beta::Float64, c_win::Float64,
					r_w::Float64, tone::Int64)
	
	p_2_v = Array{Float64,1}(undef, Int64(rt_max / dt) + 1) ;
	p_8_v = Array{Float64,1}(undef, Int64(rt_max / dt) + 1) ;
	p_w_v = Array{Float64,1}(undef, Int64(rt_max / dt) + 1) ;

	rng = MersenneTwister(1234);

	#lhood_2 = Normal(log(2.0), sqrt(dt) * sigma) ;
	#lhood_8 = Normal(log(8.0), sqrt(dt) * sigma) ;

	lhood_2 = Normal(2.0, sqrt(dt) * sigma) ;
	lhood_8 = Normal(8.0, sqrt(dt) * sigma) ;

	if tone == 2 
		#p_x = Normal(log(2.0), sqrt(dt) * sigma_tone) ;
		p_x = Normal(2.0, sqrt(dt) * sigma_tone) ;
	elseif tone == 8 
		#p_x = Normal(log(8.0), sqrt(dt) * sigma_tone) ;
		p_x = Normal(8.0, sqrt(dt) * sigma_tone) ;
	else
		#p_x = Normal(log(5.0), sqrt(dt) * sigma_tone) ;
		p_x = Normal(5.0, sqrt(dt) * sigma_tone) ;
	end

	a = 0 ;
	p_post_2 = 0.5 ;
	p_post_8 = 0.5 ;

	for j = 1 : length(p_2_v)
		x = rand(p_x) ;

		p_lhood_2 = pdf(lhood_2, x) ;
		p_lhood_8 = pdf(lhood_8, x) ;

		(p_post_2, p_post_8) = perception(p_lhood_2, p_lhood_8, p_post_2, p_post_8) ;

		(e_2, e_8) = expected_outcome(p_post_2, p_post_8, c_win, c_loss) ;

		(a, p_2_v[j], p_8_v[j], p_w_v[j]) = action(e_2, e_8, r_w, beta) ;
	end
	return (p_2_v, p_8_v, p_w_v)
end