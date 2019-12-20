using Distributions, Random, PyPlot

dynamics_predict(μ, σ, μ_ss, γ, σ_μ, 
				μ_c, σ_c, μ_c_ss, σ_μ_c) = (μ + γ * (μ_ss - μ), sqrt((σ^2.0)*(1.0 - γ)^2.0 + σ_μ^2.0),
									μ_c + γ * (μ_c_ss - μ_c), sqrt((σ_c^2.0)*(1.0 - γ)^2.0 + σ_μ_c^2.0))


function run(μ_0, σ_0, σ_μ,
			μ_c_0, σ_c_0, σ_μ_c)

	μ_ss = 0.0 ;
	μ_c_ss = 0.0 ;
	γ = 0.001 ;

	σ_μ_ss = 0.5 ;
	τ_σ_μ = 30.0 ;
	δ_σ_μ = 0.2 ;

	σ_m = 1.0 ;
	σ_m_c = 1.0 ;

	r_θ = -0.0 ;
	pe_θ = 2.0 ;

	μ_r = 0.0 ;
	σ_r = 1.0 ;
	d_r = Normal(μ_r, σ_r) ;

	μ_c = 0.0 ;
	σ_c = 1.0 ;
	d_c = Normal(μ_c, σ_c) ;

	n_r_min = 1 ;
	n_r_max = 7 ;
	n_samples = 10 ;

	rng = MersenneTwister() ;

	μ = μ_0 ;
	σ = σ_0 ;

	μ_c = μ_c_0 ;
	σ_c = σ_c_0 ;

	t_f = 50 ;

	μ_v = Array{Float64,1}(undef, t_f + 1) ;
	σ_v = Array{Float64,1}(undef, t_f + 1) ;
	μ_v[1] = μ ; 
	σ_v[1] = σ ;

	μ_c_v = Array{Float64,1}(undef, t_f + 1) ;
	σ_c_v = Array{Float64,1}(undef, t_f + 1) ;
	μ_c_v[1] = μ_c ; 
	σ_c_v[1] = σ_c ;

	for i = 1 : t_f

		(μ_predict, σ_predict, μ_c_predict, σ_c_predict) = dynamics_predict(μ, σ, μ_ss, γ, σ_μ,
																			μ_c, σ_c, μ_c_ss, σ_μ_c) ;

		d_r_predict = Normal(μ_predict, σ_predict) ;
		d_c_predict = Normal(μ_c_predict, σ_c_predict) ;

		d_predict = Normal(μ_predict - μ_c_predict, 
							sqrt(σ_predict^2.0 + σ_c_predict^2.0)) ;

		r = 0.0 ;
		c = 0.0 ;
		for j = 1 : n_r_min
			r += rand(rng, d_r) ;
			c += rand(rng, d_c) ;
		end

		p_act = 1.0 - cdf(d_predict, 0.0) ;

		n_r_samples = n_r_min ;
		for j = n_r_min + 1 : n_r_max
			if p_act >= rand(rng, Float64)
				r += rand(rng, d_r) ;
				c += rand(rng, d_c) ;
				n_r_samples += 1 ;
			end
		end
		
		for j = n_r_samples : n_samples
			r += rand(rng, d_r_predict) ;
			c += rand(rng, d_c_predict) ;
		end
		
		r /= n_samples ;
		c /= n_samples ;

		K = σ_predict^2.0 / (σ_predict^2.0 + σ_m^2.0) ;
		K_c = σ_c_predict^2.0 / (σ_c_predict^2.0 + σ_m_c^2.0) ;

		μ = μ_predict + K * (r - μ_predict) ;
		μ_c = μ_c_predict + K * (c - μ_c_predict) ;

		σ = sqrt((1.0 - K)) * σ_predict ;
		σ_c = sqrt((1.0 - K_c)) * σ_c_predict ;

		if abs(r - μ_predict) > pe_θ
			σ_μ = σ_μ + δ_σ_μ ;
		else
			σ_μ = σ_μ + (σ_μ_ss - σ_μ) / τ_σ_μ ;
		end

		μ_v[i + 1] = μ ;
		σ_v[i + 1] = σ ;
		μ_c_v[i + 1] = μ_c ;
		σ_c_v[i + 1] = σ_c ;
	end

	xkcd()
	figure()
	ax = gca()

	errorbar(1:length(μ_v), μ_v, yerr = σ_v, fmt = "none", alpha = 0.5)
	plot(1:length(μ_v), μ_v, "-k")

	#errorbar(1:length(μ_c_v), μ_c_v, yerr = σ_c_v, fmt = "none", alpha = 0.5, color = "red")
	#plot(1:length(μ_c_v), μ_c_v, "-k")

	ax.tick_params(labelsize = 20)
	#ylabel("Mood", fontsize = 20)
	xlabel("Days", fontsize = 20)

	show()
end

run(-2.0, 1.0, 0.5,
	0.0, 1.0, 0.5)

