
using LsqFit

@. sig_model(x, p) = (1.0 - p[1] - p[2]) / (1.0 + exp(p[3] * (x - p[4]))) + p[1] 

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



function fit_psychometric(subj_v::Array{subj_t,1}, x_data::Array{Float64,1}, response::Int64, curve::Symbol)

	tone_v = sort!(unique(subj_v[1].tone_v)) ;

	filter!(x -> x > 0, tone_v) ;

	y = Array{Array{Float64,1},1}(undef, length(tone_v)) ;

	for i = 1 : length(tone_v)
		y[i] = [length(subj.tone_v[map((x,y) -> x == tone_v[i] && y == response, subj.tone_v, subj.response_v)]) / 
				length(subj.tone_v[map((x,y) -> x == tone_v[i] && y != 0, subj.tone_v, subj.response_v)])
				for subj in subj_v] ;
	end

	y_data = [mean(y_i) for y_i in y] ;

	if curve == :log_std
		if response == 2
			lb = [1.0] ;
			ub = [15.0] ;
			p0 = [2.0] ;
		elseif response == 8
			lb = [-15.0] ;
			ub = [-1.0] ;
			p0 = [-2.0] ;
		else
			println("Invalid response index")
			return -1
		end

		fit = curve_fit(log_std_model, x_data, y_data, p0, lower = lb, upper = ub) ;

	elseif curve == :log_2std
		if response == 2
			lb = [0.0, 0.0] ;
			ub = [5.0, 5.0] ;
			p0 = [2.0, 2.0] ;

			fit = curve_fit(log_2std_2_model, x_data, y_data, p0, lower = lb, upper = ub) ;
		elseif response == 8
			lb = [0.0, 0.0] ;
			ub = [5.0, 5.0] ;
			p0 = [2.0, 2.0] ;

			fit = curve_fit(log_2std_8_model, x_data, y_data, p0, lower = lb, upper = ub) ;
		else
			println("Invalid response index")
			return -1
		end

	elseif curve == :log_std_offset
		if response == 2
			lb = [0.0, 0.0] ;
			ub = [1.0, 5.0] ;
			p0 = [0.1, 2.0] ;

			fit = curve_fit(log_std_offset_2_model, x_data, y_data, p0, lower = lb, upper = ub) ;
		elseif response == 8
			lb = [0.0, 0.0] ;
			ub = [1.0, 5.0] ;
			p0 = [0.1, 2.0] ;

			fit = curve_fit(log_std_offset_8_model, x_data, y_data, p0, lower = lb, upper = ub) ;
		else
			println("Invalid response index")
			return -1
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
		else
			println("Invalid response index")
			return -1
		end

		fit = curve_fit(sig_model, x_data, y_data, p0, lower = lb, upper = ub) ;
	end

	println(coef(fit))
	println(fit.resid)
	return coef(fit)
end
