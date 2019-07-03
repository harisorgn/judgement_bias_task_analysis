

function perception(p_lhood_2::Float64, p_lhood_8::Float64, p_prev_post_2::Float64, p_prev_post_8::Float64)

	p_post_2 = p_lhood_2 * p_prev_post_2 / 
			(p_lhood_2 * p_prev_post_2 + p_lhood_8 * p_prev_post_8) ;

	p_post_8 = p_lhood_8 * p_prev_post_8 / 
			(p_lhood_2 * p_prev_post_2 + p_lhood_8 * p_prev_post_8) ;

	return [p_post_2, p_post_8]
end

function expected_outcome(p_post_2::Float64, p_post_8::Float64, c_win::Float64, c_loss::Float64)

	e_2 = p_post_2 * c_win * r_2 - (1.0 - p_post_2) * c_loss * r_8 ;
	e_8 = p_post_8 * c_win * r_8 - (1.0 - p_post_8) * c_loss * r_2 ;

	return [e_2, e_8]
end

function action(e_2::Float64, e_8::Float64, r_w::Float64, beta::Float64)

	e_w = r_w ;

	p_2 = exp(beta * e_2) / (exp(beta * e_2) + exp(beta * e_8) + exp(beta * e_w)) ;
	p_8 = exp(beta * e_8) / (exp(beta * e_2) + exp(beta * e_8) + exp(beta * e_w)) ;
	p_w = exp(beta * e_w) / (exp(beta * e_2) + exp(beta * e_8) + exp(beta * e_w)) ;

	r = rand() ;

	if r <= p_2
		return (2, p_2, p_8, p_w)
	elseif r <= p_2 + p_8 && r > p_2
		return (8, p_2, p_8, p_w)
	else
		return (0, p_2, p_8, p_w)
	end

end