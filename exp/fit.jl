
@. sig_model(x, p) = (1.0 - p[1] - p[2]) / (1.0 + exp(p[3] * (x - p[4]))) + p[1] 

@. sig_mean_std_model(x, p) = 1.0 / (1.0 + exp(p[2] * (x - p[1]))) 

@. log_std_model(x, p) = 1.0 / (1.0 + (x / sqrt(2.0*8.0))^p[1]) 

@. log_2std_2_model(x,p) = 1.0 / 
		(1.0 + (p[1]/p[2])*exp((- 2.0*p[1]^2.0 * (log(x) - log(8.0))^2.0 + 2.0*p[2]^2.0 * (log(x) - log(2.0))^2.0)/
				(4.0 * p[1]^2.0 * p[2]^2.0)))

@. log_2std_8_model(x,p) = 1.0 / 
		(1.0 + (p[2]/p[1])*exp((- 2.0*p[2]^2.0 * (log(x) - log(2.0))^2.0 + 2.0*p[1]^2.0 * (log(x) - log(8.0))^2.0)/
				(4.0 * p[1]^2.0 * p[2]^2.0)))

@. log_std_offset_2_model(x,p) = 1.0 / 
		(1.0 + exp(log((8.0 + p[1])/(2.0 - p[1]))*log(x/sqrt((2.0 - p[1])*(8.0 + p[1])))/(p[2]^2.0)))

@. log_std_offset_8_model(x,p) = 1.0 / 
		(1.0 + exp(log((2.0 - p[1])/(8.0 + p[1]))*log(x/sqrt((2.0 - p[1])*(8.0 + p[1])))/(p[2]^2.0)))

@. log_std_2offset_2_model(x,p) = 1.0 / 
		(1.0 + exp(log((8.0 + p[2])/(2.0 - p[1]))*log(x/sqrt((2.0 - p[1])*(8.0 + p[2])))/(p[3]^2.0)))

@. log_std_2offset_8_model(x,p) = 1.0 / 
		(1.0 + exp(log((2.0 - p[1])/(8.0 + p[2]))*log(x/sqrt((2.0 - p[1])*(8.0 + p[2])))/(p[3]^2.0)))


function fit_psychometric(subj_v::Array{subj_t,1}, x_data::Array{Float64,1}, response::Int64, curve::Symbol)

	tone_v = sort!(unique(subj_v[1].tone_v)) ;

	filter!(x -> x > 0, tone_v) ;

	y = Array{Array{Float64,1},1}(undef, length(tone_v)) ;
	n_trials_tone_v = Array{Array{Float64,1},1}(undef, length(tone_v)) ;
	n_responses_tone_v = Array{Array{Float64,1},1}(undef, length(tone_v)) ;

	for i = 1 : length(tone_v)

		n_trials_tone_v[i] = [length(subj.tone_v[map((x,y) -> x == tone_v[i] && y != 0, subj.tone_v, subj.response_v)])
							for subj in subj_v] ;
		n_responses_tone_v[i] = [length(subj.tone_v[map((x,y) -> x == tone_v[i] && y == response, subj.tone_v, subj.response_v)])
								for subj in subj_v] ;

		y[i] = n_responses_tone_v[i] ./ n_trials_tone_v[i] ;
	end

	n_trials_tone_v = [mean(n_t_i) for n_t_i in n_trials_tone_v] ;
	n_responses_tone_v = [mean(n_r_i) for n_r_i in n_responses_tone_v] ;

	y_data = [mean(y_i) for y_i in y] ;

	inner_optimizer = LBFGS(linesearch=LineSearches.BackTracking()) ;

	if curve == :log_std
		if response == 2
			lb = [1.0] ;
			ub = [15.0] ;
			p0 = [2.0] ;
		elseif response == 8
			lb = [-15.0] ;
			ub = [-1.0] ;
			p0 = [-2.0] ;
		end

		fit = optimize(p -> log_lhood(p, x_data, log_std_model, n_trials_tone_v, n_responses_tone_v), 
					lb, ub, p0, Fminbox(inner_optimizer)) ;

		(bic, aic) = get_bic_aic(Optim.minimizer(fit), x_data, log_std_model, n_trials_tone_v, n_responses_tone_v) ;

		return (Optim.minimizer(fit), bic, aic)

	elseif curve == :log_2std
		if response == 2
			lb = [0.0, 0.0] ;
			ub = [5.0, 5.0] ;
			p0 = [2.0, 2.0] ;

			fit = optimize(p -> log_lhood(p, x_data, log_2std_2_model, n_trials_tone_v, n_responses_tone_v), 
					lb, ub, p0, Fminbox(inner_optimizer)) ;

			(bic, aic) = get_bic_aic(Optim.minimizer(fit), x_data, log_2std_2_model, n_trials_tone_v, n_responses_tone_v) ;

			return (Optim.minimizer(fit), bic, aic)

		elseif response == 8
			lb = [0.0, 0.0] ;
			ub = [5.0, 5.0] ;
			p0 = [2.0, 2.0] ;

			fit = optimize(p -> log_lhood(p, x_data, log_2std_8_model, n_trials_tone_v, n_responses_tone_v), 
					lb, ub, p0, Fminbox(inner_optimizer)) ;

			(bic, aic) = get_bic_aic(Optim.minimizer(fit), x_data, log_2std_8_model, n_trials_tone_v, n_responses_tone_v) ;

			return (Optim.minimizer(fit), bic, aic)
		end

	elseif curve == :log_std_offset
		if response == 2
			lb = [0.0, 0.0] ;
			ub = [1.0, 5.0] ;
			p0 = [0.1, 2.0] ;

			fit = optimize(p -> log_lhood(p, x_data, log_std_offset_2_model, n_trials_tone_v, n_responses_tone_v), 
					lb, ub, p0, Fminbox(inner_optimizer)) ;

			(bic, aic) = get_bic_aic(Optim.minimizer(fit), x_data, log_std_offset_2_model, n_trials_tone_v, n_responses_tone_v) ;

			return (Optim.minimizer(fit), bic, aic)

		elseif response == 8
			lb = [0.0, 0.0] ;
			ub = [2.0, 5.0] ;
			p0 = [0.2, 2.0] ;

			fit = optimize(p -> log_lhood(p, x_data, log_std_offset_8_model, n_trials_tone_v, n_responses_tone_v), 
					lb, ub, p0, Fminbox(inner_optimizer)) ;

			(bic, aic) = get_bic_aic(Optim.minimizer(fit), x_data, log_std_offset_8_model, n_trials_tone_v, n_responses_tone_v) ;

			return (Optim.minimizer(fit), bic, aic)
		end

	elseif curve == :log_std_2offset
		if response == 2
			lb = [0.0, 0.0, 0.0] ;
			ub = [2.0, 2.0, 5.0] ;
			p0 = [0.2, 0.2, 2.0] ;

			fit = optimize(p -> log_lhood(p, x_data, log_std_2offset_2_model, n_trials_tone_v, n_responses_tone_v), 
					lb, ub, p0, Fminbox(inner_optimizer)) ;

			(bic, aic) = get_bic_aic(Optim.minimizer(fit), x_data, log_std_2offset_2_model, n_trials_tone_v, n_responses_tone_v) ;

			return (Optim.minimizer(fit), bic, aic)

		elseif response == 8
			lb = [0.0, 0.0, 0.0] ;
			ub = [2.0, 2.0, 5.0] ;
			p0 = [0.2, 0.2, 2.0] ;

			fit = optimize(p -> log_lhood(p, x_data, log_std_2offset_8_model, n_trials_tone_v, n_responses_tone_v), 
					lb, ub, p0, Fminbox(inner_optimizer)) ;

			(bic, aic) = get_bic_aic(Optim.minimizer(fit), x_data, log_std_2offset_8_model, n_trials_tone_v, n_responses_tone_v) ;

			return (Optim.minimizer(fit), bic, aic)
		end

	elseif curve == :sig
		if response == 2
			lb = [y_data[end] - 0.05, 1.0 - y_data[1] - 0.05, 1.0, 5.0 - 2.0] ;
			ub = [y_data[end] + 0.05, 1.0 - y_data[1] + 0.05, 15.0, 5.0 + 2.0] ;
			p0 = [y_data[end], 1.0 - y_data[1], 2.0, 5.0] ;
		elseif response == 8
			lb = [y_data[1] - 0.05, 1.0 - y_data[end] - 0.05, -15.0, 5.0 - 2.0] ;
			ub = [y_data[1] + 0.05, 1.0 - y_data[end] + 0.05, -1.0, 5.0 + 2.0] ;
			p0 = [y_data[1], 1.0 - y_data[end], -2.0, 5.0] ;
		end

		#fit = curve_fit(sig_model, x_data, y_data, p0, lower = lb, upper = ub) ;
		#return coef(fit)

		fit = optimize(p -> log_lhood(p, x_data, sig_model, n_trials_tone_v, n_responses_tone_v), 
					lb, ub, p0, Fminbox(inner_optimizer)) ;

		(bic, aic) = get_bic_aic(Optim.minimizer(fit), x_data, sig_model, n_trials_tone_v, n_responses_tone_v) ;

		return (Optim.minimizer(fit), bic, aic)

	elseif curve == :sig_mean_std
		if response == 2
			lb = [5.0 - 2.0, 1.0] ;
			ub = [5.0 + 2.0, 15.0] ;
			p0 = [5.0, 2.0] ;
		elseif response == 8
			lb = [5.0 - 2.0, -15.0] ;
			ub = [5.0 + 2.0, -1.0] ;
			p0 = [5.0, -2.0] ;
		end

		fit = optimize(p -> log_lhood(p, x_data, sig_mean_std_model, n_trials_tone_v, n_responses_tone_v), 
					lb, ub, p0, Fminbox(inner_optimizer)) ;

		(bic, aic) = get_bic_aic(Optim.minimizer(fit), x_data, sig_mean_std_model, n_trials_tone_v, n_responses_tone_v) ;

		return (Optim.minimizer(fit), bic, aic)
	end
end

function log_lhood(p::Array{Float64,1}, x::Array{Float64,1}, f::Function, 
				n_trials_tone_v::Array{Float64,1}, n_responses_tone_v::Array{Float64,1})

	log_lhood = dot(n_responses_tone_v, log.(abs.(f(x, p)))) + 
			dot(n_trials_tone_v - n_responses_tone_v, log.(abs.(ones(length(x)) - f(x, p)))) ;#+
			#sum(log.(binomial.(Int64.(round.(n_trials_tone_v)), Int64.(round.(n_responses_tone_v))))) ;

	return -log_lhood
end

function get_bic_aic(p::Array{Float64,1}, x::Array{Float64,1}, f::Function,
					n_trials_tone_v::Array{Float64,1}, n_responses_tone_v::Array{Float64,1})

	bic = length(p) * log(length(x)) + 2.0 * log_lhood(p, x, f, n_trials_tone_v, n_responses_tone_v) ;

	aic = 2.0 * length(p) + 2.0 * log_lhood(p, x, f, n_trials_tone_v, n_responses_tone_v) ;

	return (bic, aic)
end