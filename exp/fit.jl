
using LsqFit

@. sig_model(x, p) = p[1] / (1.0 + exp(-p[2] * (x - p[3])))
@. gauss_model(x, p) = exp(-((x - p[1])^2.0) / (2.0 * p[2]^2.0)) / sqrt(2.0 * pi * p[2]^2.0)

function jac_sig_model(x, p)
	J = Array{Float64}(undef, length(x), length(p)) ;
	@. J[:,1] = 1.0 / (1.0 + exp(-p[2] * (x - p[3]))) ;
	@. J[:,2] = (p[1] * (x - p[3]) * exp(-p[2]*(x - p[3]))) / (1.0 + exp(-p[2]*(x - p[3])))^2.0 ;
	@. J[:,3] = - (p[1] * p[2] * exp(-p[2]*(x - p[3]))) / (1.0 + exp(-p[2]*(x - p[3])))^2.0 ;
	return J
end

function jac_gauss_model(x, p)
	J = Array{Float64}(undef, length(x), length(p)) ;
	@. J[:,1] = exp(-((x - p[1])^2.0) / (2.0 * p[2]^2.0)) / sqrt(2.0 * pi * p[2]^2.0) * 
				(x - p[1]) / (p[2]^2.0) ;
	@. J[:,2] = exp(-((x - p[1])^2.0) / (2.0 * p[2]^2.0)) / sqrt(2.0 * pi * p[2]^2.0) * 
				(((x - p[1])^2.0) / p[2]^3.0 + 1.0 / p[2]) ;
	return J
end

function fit(subj_v::Array{subj_t,1}, press::Int64, curve::Symbol)

	xdata = [2.0, 5.0, 8.0] ;

	y1 = [length(subj.tone_v[map((x,y) -> x == 2 && y == press, subj.tone_v, subj.press_v)]) / 
		length(subj.tone_v[map((x,y) -> x == 2 && y != 0, subj.tone_v, subj.press_v)])
		for subj in subj_v] ;
	y2 = [length(subj.tone_v[map((x,y) -> x == 5 && y == press, subj.tone_v, subj.press_v)]) / 
		length(subj.tone_v[map((x,y) -> x == 5 && y != 0, subj.tone_v, subj.press_v)])
		for subj in subj_v] ;		
	y3 = [length(subj.tone_v[map((x,y) -> x == 8 && y == press, subj.tone_v, subj.press_v)]) / 
		length(subj.tone_v[map((x,y) -> x == 8 && y != 0, subj.tone_v, subj.press_v)])
		for subj in subj_v] ;	

	ydata = [mean(y1), mean(y2), mean(y3)] ;

	if curve == :gauss
		if press == 4
			lb_p1 = 2.0 - 0.1 ;
			ub_p1 = 2.0 + 0.1 ;
			p0_1 = 2.0 ;
			p0_2 = 2.0 ;
		elseif press == 1
			lb_p1 = 8.0 - 0.1 ;
			ub_p1 = 8.0 + 0.1 ;
			p0_1 = 8.0 ;
			p0_2 = 2.0 ;
		else
			println("Invalid response index")
			return -1
		end

		fit = curve_fit(gauss_model, jac_gauss_model, xdata, ydata, p0, lower = lb, upper = ub) ;

	elseif curve == :sig
		if press == 4
			lb = [ydata[1] - 0.05, -15.0, 5.0 - 2.0] ;
			ub = [ydata[1] + 0.05, -1.0, 5.0 + 2.0] ;
			p0 = [ydata[1], -2.0, 5.0] ;
		elseif press == 1
			lb = [ydata[3] - 0.05, 1.0, 5.0 - 2.0] ;
			ub = [ydata[3] + 0.05, 15.0, 5.0 + 2.0] ;
			p0 = [ydata[3], 2.0, 5.0] ;
		else
			println("Invalid response index")
			return -1
		end

		fit = curve_fit(sig_model, jac_sig_model, xdata, ydata, p0, lower = lb, upper = ub) ;

	end

	println(coef(fit))
	println(fit.resid)
end
