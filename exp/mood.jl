using Distributions, Random, PyPlot

dynamics_predict(μ, σ, μ_ss, γ, σ_μ) = (μ + γ * (μ_ss - μ), sqrt((σ^2.0)*(1.0 - γ)^2.0 + σ_μ^2.0))


function run(μ_0, σ_0, σ_μ)

	μ_ss = 0.0 ;

	σ_m = 1.0 ;

	γ = 0.001 ;
	r_θ = -0.0 ;

	μ_r = 0.0 ;
	σ_r = 1.0 ;
	d_r = Normal(μ_r, σ_r) ;

	n_r_min = 1 ;
	n_r_max = 5 ;
	n_samples = 10 ;

	rng = MersenneTwister() ;

	μ = μ_0 ;
	σ = σ_0 ;

	t_f = 100 ;

	μ_v = Array{Float64,1}(undef, t_f + 1) ;
	σ_v = Array{Float64,1}(undef, t_f + 1) ;
	μ_v[1] = μ ; 
	σ_v[1] = σ ;

	for i = 1 : t_f

		(μ_predict, σ_predict) = dynamics_predict(μ, σ, μ_ss, γ, σ_μ) ;

		d_r_predict = Normal(μ_predict, σ_predict) ;

		r = 0.0 ;
		for j = 1 : n_r_min
			r += rand(rng, d_r) ;
		end

		n_r_samples = n_r_min ;
		for j = n_r_min + 1 : n_r_max
			p_act = 1.0 - cdf(d_r_predict, r_θ) ;

			if p_act >= rand(rng, Float64)
				r += rand(rng, d_r) ;
				n_r_samples += 1 ;
			end
		end

		for j = n_r_samples : n_samples
			r += rand(rng, d_r_predict) ;
		end
		
		r /= n_samples ;

		K = σ_predict^2.0 / (σ_predict^2.0 + σ_m^2.0) ;

		μ = μ_predict + K * (r - μ_predict) ;

		σ = sqrt((1.0 - K)) * σ_predict ;

		μ_v[i + 1] = μ ;
		σ_v[i + 1] = σ ;
	end

	xkcd()
	figure()
	ax = gca()

	errorbar(1:length(μ_v), μ_v, yerr = σ_v, fmt = "none", alpha = 0.5)
	plot(1:length(μ_v), μ_v, "-k")

	ax.tick_params(labelsize = 20)
	#ylabel("Mood", fontsize = 20)
	xlabel("Days", fontsize = 20)

	show()
end

run(-2.0, 0.5, 0.5)


