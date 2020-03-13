#using NLsolve
using NLopt
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

obj_grid(x, p) = ((p[1] - p[2]) + 
			(p[2] - x[1]) * exp(-x[2]*p[6]*gauss_pdf(p[2], x[6] + x[8], x[7])) - 
			(p[1] - x[1]) * exp(-x[2]*p[6]*gauss_pdf(p[1], x[6], x[7])) - 
			(p[3] - x[1]) * (exp(-x[2]*p[6]*gauss_pdf(p[3], x[6] + x[8], x[7])) - 
			   		 		exp(-x[2]*p[6]*gauss_pdf(p[3], x[6], x[7]))))^2.0 +

			((p[1] - p[2]) + 
			(p[2] - x[1]) * exp(-x[2]*p[7]*gauss_pdf(p[2], x[6] + x[8], x[7])) - 
			(p[1] - x[1]) * exp(-x[2]*p[7]*gauss_pdf(p[1], x[6], x[7])) - 
			log(p[11]) / p[8])^2.0 +

			((p[4] - p[5]) - 
			(p[4] - x[1]) * exp(-x[2]*p[7]*gauss_pdf(p[4], x[6], x[8])) +
			(p[5] - x[1]) * exp(-x[2]*p[7]*gauss_pdf(p[5], x[6], x[8])) -
			log(p[12]) / p[8])^2.0 +

			((p[1] - p[2]) + 
			(p[2] - x[1]) * exp(-x[2]*p[7]*gauss_pdf(p[2], x[3] + x[5], x[4])) - 
			(p[1] - x[1]) * exp(-x[2]*p[7]*gauss_pdf(p[1], x[3], x[4])) - 
			log(p[9]) / p[8])^2.0 +

			((p[4] - p[5]) - 
			(p[4] - x[1]) * exp(-x[2]*p[7]*gauss_pdf(p[4], x[3], x[4])) +
			(p[5] - x[1]) * exp(-x[2]*p[7]*gauss_pdf(p[5], x[3], x[4])) -
			log(p[10]) / p[8])^2.0

df(x, p) = ForwardDiff.gradient(x -> obj_grid(x,p), x) 

function obj_nlopt(x::Vector, grad::Vector, p::Vector)
	if length(grad) > 0
		grad[:] = df(x, p)
	end

	return	obj_grid(x, p)
end

function m_constraint(x::Vector, grad::Vector, p::Vector)
	if length(grad) > 0
		grad[:] = [0.0, 0.0, -1.0, 0.0, 0.0, 1.0, 0.0, 0.0]
	end

	return	x[6] - x[3]
end

function nlopt_search(p)

#--------------------------------------------------------------------------------------------------
# p = [r_A_veh, r_B_drug, r_C_blank, r_high_reward, r_low_reward,
# 	   t_training, t_testing, beta, bias_1v1_ctrl, bias_2v1_ctrl, bias_1v1_ela, bias_2v1_ela]
#
# x = [r_expected_0, n, m_ctrl, s_ctrl, d_m_ctrl, m_ela, s_ela, d_m_ela]
#--------------------------------------------------------------------------------------------------

	opt = Opt(:LD_SLSQP, 8)
	opt.lower_bounds = [0.1, 0.1, -3.0, 0.1, -3.0, -3.0, 0.1, -3.0]
	opt.upper_bounds = [1.0, 1.0, 3.0, 3.0, 3.0, (p[4] + p[5])/2.0, 3.0, 3.0]

	opt.xtol_rel = 1e-8

	opt.min_objective = (x, grad) -> obj_nlopt(x, grad, p)

	inequality_constraint!(opt, (x, grad) -> m_constraint(x, grad, p), 1e-8)


	(minf,minx,ret) = optimize(opt, [0.6, 0.5, 1.5, 0.5, -0.2, 1.0, 0.6, -1.0])
	numevals = opt.numevals 
	println("got $minf at $minx after $numevals iterations (returned $ret)")

end

function grid_search(p)

#--------------------------------------------------------------------------------------------------
# p = [r_A_veh, r_B_drug, r_C_blank, r_high_reward, r_low_reward,
# 	   t_training, t_testing, beta, bias_1v1_ctrl, bias_2v1_ctrl, bias_1v1_ela, bias_2v1_ela]
#
# x = [r_expected_0, n, m_ctrl, s_ctrl, d_m_ctrl, m_ela, s_ela, d_m_ela]
#--------------------------------------------------------------------------------------------------

	grid_step = 0.2 

	r_exp_0_range = 0.2 : grid_step : 1.0
	n_range = 0.2 : grid_step : 1.0
	m_ctrl_range = -2.0 : grid_step : 2.0
	s_ctrl_range = 0.2 : grid_step : 3.0
	d_m_ctrl_range = -2.0 : grid_step : 2.0
	m_ela_range = -2.0 : grid_step : 1.5
	s_ela_range = 0.2 : grid_step : 3.0
	d_m_ela_range = -2.0 : grid_step : 2.0

	x = Array{Tuple{Float32, Float32, Float32, Float32, Float32, Float32, Float32, Float32, Float32},1}(undef, 
		length(r_exp_0_range) * length(n_range) * length(m_ctrl_range) * length(s_ctrl_range) *
		length(d_m_ctrl_range) * length(m_ela_range) * length(s_ela_range) * length(d_m_ela_range))
	
	c = 1 

	for r_exp_0 = r_exp_0_range
	for n = n_range
	for m_ctrl = m_ctrl_range
	for s_ctrl = s_ctrl_range
	for d_m_ctrl = d_m_ctrl_range
	for m_ela = m_ela_range
	for s_ela = s_ela_range
	for d_m_ela = d_m_ela_range
		
		x[c] = (obj_grid([r_exp_0, n, m_ctrl, s_ctrl, d_m_ctrl, m_ela, s_ela, d_m_ela], p), 
						r_exp_0, n, m_ctrl, s_ctrl, d_m_ctrl, m_ela, s_ela, d_m_ela)

		c += 1
	end
	end
	end
	end
	end
	end
	end
	end

	sort!(x)

	println(x[1])
	println(x[2])
	println(x[3])
	println(x[4])
end

function nlsolve_search()

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

end

#grid_search([1.0, 1.0, 0.0, 2.0, 1.0, 2.0, 14.0, 2.5, 1.07, 1.5, 1.5, 1.0])
nlopt_search([1.0, 1.0, 0.0, 2.0, 1.0, 2.0, 14.0, 2.5, 1.07, 1.5, 1.5, 1.0])