
using Distributions, Random
using Roots
using PyPlot
using ForwardDiff

#____Difference equation____
prob_rw_diff(n, d_r_xp, r_t, r_xp_t) = n * pdf(d_r_xp, r_t) * (r_t - r_xp_t) 

#____Analytical solution____
prob_rw(n, d_r_xp, r, t, r_xp_0) = r .- (r[1] - r_xp_0).*exp.(-n.*pdf(d_r_xp, r).*t)

f(μ, σ, r_h, r_l, n, c_h, c_l, t) = r_h .- r_l  .- c_h .* exp.(-n.*t.*exp(-((r_h - μ)^2.0)/(2.0*σ^2.0))./(σ*sqrt(2.0*pi))) .+
											   	 c_l .* exp.(-n.*t.*exp(-((r_l - μ)^2.0)/(2.0*σ^2.0))./(σ*sqrt(2.0*pi)))

df(μ, σ, r_h, r_l, n, c_h, c_l, t) = c_h*n*t*exp(-((r_h - μ)^2.0)/(2.0*σ^2.0))*exp(-n*t*exp(-((r_h - μ)^2.0)/(2.0*σ^2.0))/(σ*sqrt(2.0*pi)))*(r_h - μ)/(sqrt(2*pi)*σ^3.0) -
									 c_l*n*t*exp(-((r_l - μ)^2.0)/(2.0*σ^2.0))*exp(-n*t*exp(-((r_l - μ)^2.0)/(2.0*σ^2.0))/(σ*sqrt(2.0*pi)))*(r_l - μ)/(sqrt(2*pi)*σ^3.0)

#df(f, σ, r_h, r_l, n, c_h, c_l, t) = x -> ForwardDiff.derivative(x -> f(x, σ, r_h, r_l, n, c_h, c_l, t),float(x))

function prob_rw_dist_solve(σ, r_h, r_l, n, t, r_0, μ_0)

	μ_root = find_zero((x -> f(x, σ, r_h, r_l, n, r_h - r_0, r_l - r_0, t), 
						x -> df(x, σ, r_h, r_l, n, r_h - r_0, r_l - r_0, t)), 
		   				#df(f, σ, r_h, r_l, n, r_h - r_0, r_l - r_0, t)),
						μ_0, Roots.Newton())
	
	return (μ_root, f(μ_root, σ, r_h, r_l, n, r_h - r_0, r_l - r_0, t))
end


function prob_rw_run(μ, σ, r_h, r_l, n, r_xp_0)

	d_r_xp = Normal(μ, σ) ;
	d_r_h = Normal(r_h, 0.01) ;
	d_r_l = Normal(r_l, 0.01) ;

	t_f = 500 ;
	r_h_xp_v = Array{Float64,1}(undef, t_f)
	r_h_xp_v[1] = r_xp_0 ;

	r_l_xp_v = Array{Float64,1}(undef, t_f)
	r_l_xp_v[1] = r_xp_0 ;

	rng = MersenneTwister() ;

	for t = 2 : t_f

		r_l_t = rand(rng, d_r_l) ;

		r_l_xp_v[t] = r_l_xp_v[t - 1] + prob_rw_diff(n, d_r_xp, r_l_t, r_l_xp_v[t - 1]) ;

		r_h_t = rand(rng, d_r_h) ;

		r_h_xp_v[t] = r_h_xp_v[t - 1] + prob_rw_diff(n, d_r_xp, r_h_t, r_h_xp_v[t - 1]) ;
	end

	figure()
	ax = gca()

	plot(1:t_f, r_l_xp_v, "-b")
	plot(1:t_f, r_h_xp_v, "-r")

	plot(1:t_f, prob_rw(n, d_r_xp, r_l, 0:(t_f - 1), r_l_xp_v[1]), "-c")
	plot(1:t_f, prob_rw(n, d_r_xp, r_h, 0:(t_f - 1), r_h_xp_v[1]), "-m")

	show()
end

#prob_rw_run(-0.6, 1.0, 2.0, 1.0, 0.8, 0.0)
