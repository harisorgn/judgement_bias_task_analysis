
using Distributions, Random, PyPlot


r_h = 2.0 ;
r_l = 1.0 ;
σ = 2.0 ;
μ = (r_h^2.0 - r_l^2.0 - 2.0 * log(2.0) * σ^2.0) / (2.0*r_h - 2.0*r_l) ;

d_r_xp = Normal(μ, σ) ;
d_r1 = Normal(1.0, 0.2) ;
d_r2 = Normal(2.0, 0.2) ;
n = 0.8 ;

t_f = 500 ;
r1_xp_v = Array{Float64,1}(undef, t_f)
r1_xp_v[1] = μ ;

r2_xp_v = Array{Float64,1}(undef, t_f)
r2_xp_v[1] = μ ;

rng = MersenneTwister() ;

for t = 2 : t_f

	r1_t = rand(rng, d_r1) ;

	r1_xp_v[t] = r1_xp_v[t - 1] + n * pdf(d_r_xp, r1_t) * (r1_t - r1_xp_v[t - 1]) ;

	r2_t = rand(rng, d_r2) ;

	r2_xp_v[t] = r2_xp_v[t - 1] + n * pdf(d_r_xp, r2_t) * (r2_t - r2_xp_v[t - 1]) ;

end

figure()
ax = gca()

plot(1:t_f, r1_xp_v, "-b")
plot(1:t_f, r2_xp_v, "-r")

#=
figure()
ax = gca()

m_v = [(r_h^2.0 - r_l^2.0 - 2.0 * log(2.0) * i^2.0) / (2.0*r_h - 2.0*r_l) for i = 0.02:0.01:3.0]

plot(0.02:0.01:3.0, m_v)
=#
show()
