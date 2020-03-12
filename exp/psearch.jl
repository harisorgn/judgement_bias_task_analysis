#using NLopt
using NLsolve
using ForwardDiff
using PyPlot

gauss_pdf(x, m, s) = exp(-((x - m)^2.0)/(2.0*s^2.0)) / (s*sqrt(2.0*pi))

function f!(F, x, p)
	F[:] = [(p[2] - p[3]) + 
			(p[3] - p[1]) * exp(-p[12]*p[7]*gauss_pdf(p[3], x[1] + x[3], x[2])) - 
			(p[2] - p[1]) * exp(-p[12]*p[7]*gauss_pdf(p[2], x[1], x[2])) - 
			(p[4] - p[1]) * (exp(-p[12]*p[7]*gauss_pdf(p[4], x[1] + x[3], x[2])) - 
			   		 		exp(-p[12]*p[7]*gauss_pdf(p[4], x[1], x[2]))),

			(p[2] - p[3]) + 
			(p[3] - p[1]) * exp(-p[12]*p[8]*gauss_pdf(p[3], x[1] + x[3], x[2])) - 
			(p[2] - p[1]) * exp(-p[12]*p[8]*gauss_pdf(p[2], x[1], x[2])) - 
			log(p[10]) / p[9],

			(p[5] - p[6]) - 
			(p[5] - p[1]) * exp(-p[12]*p[8]*gauss_pdf(p[5], x[1], x[2])) +
			(p[6] - p[1]) * exp(-p[12]*p[8]*gauss_pdf(p[6], x[1], x[2])) -
			log(p[11]) / p[9]]
end

#--------------------------------------------------------------------------------------------------
# p = [r_expected_0, r_A_no_manipulation, r_B_manipulation, r_C_blank, r_high_reward, r_low_reward,
# 	   t_training, t_testing, beta, bias_1v1, bias_2v1, n]
#
# x = [mean, sigma, mean_offset]
#--------------------------------------------------------------------------------------------------

x_0 = [0.5, 1.0, -0.5] 

x_sim = Array{Float64,1}(undef, 3)
p_sim = Array{Float64,1}(undef, 12)

for n = 0.5 : 0.02 : 1.0

	#p = [0.6, 1.0, 1.0, 0.0, 2.0, 1.0, 2.0, 8.0, 2.5, 1.5, 1.0, n]
	p = [0.6, 1.0, 1.0, 0.0, 2.0, 1.0, 2.0, 8.0, 2.5, 1.08, 1.5, n]

	s = nlsolve((F,x) -> f!(F,x,p), x_0, autodiff = :forward, iterations = 100000) 

	if (s.zero[1] <= (p[5] + p[6]) / 2.0) && (s.zero[2] >= 0.2) && (s.zero[3] <= 0.0)
		x_sim[:] = s.zero
		p_sim[:] = p ;
	end
end

t = 0.0 : 0.05 : p_sim[7]

println(x_sim)
println(p_sim)

figure()
ax = gca()

plot(t, p_sim[2] .- (p_sim[2] - p_sim[1]) .* 
					exp.(-p_sim[12] .* gauss_pdf(p_sim[2], x_sim[1], x_sim[2]) .* t), 
					"-r", label = "Veh")

plot(t, p_sim[3] .- (p_sim[3] - p_sim[1]) .* 
					exp.(-p_sim[12] .* gauss_pdf(p_sim[3], x_sim[1] + x_sim[3], x_sim[2]) .* t), 
					"-b", label = "ND")

plot(t, p_sim[4] .- (p_sim[4] - p_sim[1]) .* 
					exp.(-p_sim[12] .* gauss_pdf(p_sim[4], x_sim[1], x_sim[2]) .* t), 
					"-g", label = "Blank (vs Veh)")

plot(t, p_sim[4] .- (p_sim[4] - p_sim[1]) .* 
					exp.(-p_sim[12] .* gauss_pdf(p_sim[4], x_sim[1] + x_sim[3], x_sim[2]) .* t), 
					"-c", label = "Blank (vs ND)")

xlabel("t [trials]", fontsize = 20)
ylabel("r [pellets]", fontsize = 20)
ax.legend(fontsize = 20, frameon = false)

t = 0.0 : 0.05 : p_sim[8]

figure()
ax = gca()

plot(t, p_sim[2] .- (p_sim[2] - p_sim[1]) .* 
					exp.(-p_sim[12] .* gauss_pdf(p_sim[2], x_sim[1], x_sim[2]) .* t), 
					"-r", label = "Veh")

plot(t, p_sim[3] .- (p_sim[3] - p_sim[1]) .* 
					exp.(-p_sim[12] .* gauss_pdf(p_sim[3], x_sim[1] + x_sim[3], x_sim[2]) .* t), 
					"-b", label = "ND")

xlabel("t [trials]", fontsize = 20)
ylabel("r [pellets]", fontsize = 20)
ax.legend(fontsize = 20, frameon = false)

figure()
ax = gca()

plot(t, p_sim[5] .- (p_sim[5] - p_sim[1]) .* 
					exp.(-p_sim[12] .* gauss_pdf(p_sim[5], x_sim[1], x_sim[2]) .* t), 
					"-r", label = "r = 2")

plot(t, p_sim[6] .- (p_sim[6] - p_sim[1]) .* 
					exp.(-p_sim[12] .* gauss_pdf(p_sim[6], x_sim[1], x_sim[2]) .* t), 
					"-b", label = "r = 1")

xlabel("t [trials]", fontsize = 20)
ylabel("r [pellets]", fontsize = 20)
ax.legend(fontsize = 20, frameon = false)

show()


#=
g1(x::Vector, p::Vector) = (p[2] - p[3]) + 
						   (p[3] - p[1]) * exp(-x[4]*p[7]*gauss_pdf(p[3], x[1] + x[3], x[2])) - 
				  		   (p[2] - p[1]) * exp(-x[4]*p[7]*gauss_pdf(p[2], x[1], x[2])) + 
						   (p[4] - p[1]) * (exp(-x[4]*p[7]*gauss_pdf(p[4], x[1] + x[3], x[2])) - 
			   		 						exp(-x[4]*p[7]*gauss_pdf(p[4], x[1], x[2])))

g2(x::Vector, p::Vector) =	(p[3] - p[1]) * exp(-x[4]*p[8]*gauss_pdf(p[3], x[1] + x[3], x[2])) - 
							(p[2] - p[1]) * exp(-x[4]*p[8]*gauss_pdf(p[3], x[1], x[2])) - 
							log(p[10]) / p[9]

g3(x::Vector, p::Vector) =	p[5] - p[6] - 
							(p[5] - p[1]) * exp(-x[4]*p[8]*gauss_pdf(p[5], x[1], x[2])) +
				  			(p[6] - p[1]) * exp(-x[4]*p[8]*gauss_pdf(p[6], x[1], x[2]))

dg(g, p) = x -> ForwardDiff.gradient(z -> g(z,p), x) 

function constraint(g::Function, x::Vector, grad::Vector, p::Vector)
	if length(grad) > 0
		grad[:] = dg(g, p)(x) ;
	end
	g(x, p)
end

function obj(x::Vector, grad::Vector)
	if length(grad) > 0 
		grad[:] = [0.0, 0.0, 0.0, 0.0, 1.0]
	end
	x[5]
end

p = [0.5, 1.0, 1.0, 0.0, 2.0, 1.0, 10.0, 20.0, 2.5, 1.5] ;

opt = Opt(:LD_SLSQP, 5) ;
opt.lower_bounds = [-Inf, 0.0, -Inf, 0.0, -Inf] ;
opt.upper_bounds = [(p[5] + p[6])/2.0, Inf, Inf, 1.0, Inf] ;

opt.xtol_rel = 1e-4 ;

opt.min_objective = obj ;
equality_constraint!(opt, (x,g) -> constraint(g1, x, g, p), 1e-8) ;
equality_constraint!(opt, (x,g) -> constraint(g2, x, g, p), 1e-8) ;
equality_constraint!(opt, (x,g) -> constraint(g3, x, g, p), 1e-8) ;

(minf,minx,ret) = optimize(opt, [0.0, 1.0, -0.5, 0.8, 0.0]) ;
numevals = opt.numevals ;
println("got $minf at $minx after $numevals iterations (returned $ret)") ;
=#




