#=
struct agent_stats
	rt_2_corr::Float64 
	rt_2_incorr::Float64
	rt_8_corr::Float64
	rt_8_incorr::Float64
	p_2_corr::Float64
	p_8_corr::Float64
end
=#

struct agent_stats
	tone_v::Array{Int64,1}
	response_v::Array{Int64,1}
	rt_2_corr_v::Array{Float64,1} 
	rt_2_incorr_v::Array{Float64,1}
	rt_5_2_v::Array{Float64,1} 
	rt_5_8_v::Array{Float64,1}
	rt_8_corr_v::Array{Float64,1}
	rt_8_incorr_v::Array{Float64,1}
end

struct exp_stats
	rt_2_corr_d::Normal 
	rt_2_incorr_d::Normal
	rt_8_corr_d::Normal
	rt_8_incorr_d::Normal
	n_2_corr::Float64
	n_2_incorr::Float64
	n_8_corr::Float64
	n_8_incorr::Float64
end

lb(x::Float64) = (x < 1e-6 || isnan(x)) ? 1e-6 : x

function obj_func(x::Array{Float64}, r_w::Float64)

	log_lhood = 0.0 ;

	#=
	agent = task(x[1], x[2], x[3], x[4], x[5]) ;

	#=
	log_lhood = log(pdf(rat.rt_2_corr_d, agent.rt_2_corr)) + 
				log(pdf(rat.rt_2_incorr_d, agent.rt_2_incorr)) +
				log(pdf(rat.rt_8_corr_d, agent.rt_8_corr)) +
				log(pdf(rat.rt_8_incorr_d, agent.rt_8_incorr)) +
				log(agent.p_2_corr^(rat.n_2_corr) *(1.0 - agent.p_2_corr)^(rat.n_2_incorr)) +
				log(agent.p_8_corr^(rat.n_8_corr) *(1.0 - agent.p_8_corr)^(rat.n_8_incorr)) ;

	return log_lhood
	=#

	for i = 1 : length(rat.rt_v)
		if rat.tone_v[i] == 2
			if rat.response_v[i] == 4
				log_lhood += log(lb(count(x -> abs(x - rat.rt_v[i]) < dt, agent.rt_2_corr_v) /
							length(agent.tone_v[map((x,y) -> x == 2 && y == 2, agent.tone_v, agent.response_v)]))) ;
			elseif rat.response_v[i] == 1
				log_lhood += log(lb(count(x -> abs(x - rat.rt_v[i]) < dt, agent.rt_2_incorr_v) /
							length(agent.tone_v[map((x,y) -> x == 2 && y == 8, agent.tone_v, agent.response_v)]))) ;
			end
		elseif rat.tone_v[i] == 5
			if rat.response_v[i] == 4
				log_lhood += log(lb(count(x -> abs(x - rat.rt_v[i]) < dt, agent.rt_5_2_v) /
							length(agent.tone_v[map((x,y) -> x == 5 && y == 2, agent.tone_v, agent.response_v)]))) ;
			elseif rat.response_v[i] == 1
				log_lhood += log(lb(count(x -> abs(x - rat.rt_v[i]) < dt, agent.rt_5_8_v) /
							length(agent.tone_v[map((x,y) -> x == 5 && y == 8, agent.tone_v, agent.response_v)]))) ;
			end
		elseif rat.tone_v[i] == 8 
			if rat.response_v[i] == 4
				log_lhood += log(lb(count(x -> abs(x - rat.rt_v[i]) < dt, agent.rt_8_incorr_v) /
							length(agent.tone_v[map((x,y) -> x == 8 && y == 2, agent.tone_v, agent.response_v)]))) ;
			elseif rat.response_v[i] == 1
				log_lhood += log(lb(count(x -> abs(x - rat.rt_v[i]) < dt, agent.rt_8_corr_v) /
							length(agent.tone_v[map((x,y) -> x == 8 && y == 8, agent.tone_v, agent.response_v)]))) ;
			end
		end
	end
	=#

	for i = 1 : length(rat.rt_v)

		(p_2_v, p_8_v, p_w_v) = trial_fit(x[1], x[2], x[3], x[4], rat.tone_v[i], r_w) ;

		n_steps = Int64(floor(rat.rt_v[i] / dt)) ;
		p_rt = 1.0 ;
		for j = 1 : n_steps
			#log_lhood += log(lb(p_w_v[j])) ;
			p_rt *= p_w_v[j] ;
		end

		if rat.response_v[i] == 4
			#log_lhood += log(lb(p_2_v[n_steps + 1])) ;
			p_rt *= p_2_v[n_steps + 1] ;
		elseif rat.response_v[i] == 1
			#log_lhood += log(lb(p_8_v[n_steps + 1])) ;
			p_rt *= p_8_v[n_steps + 1] ;
		end

		log_lhood += log(lb(p_rt)) ;
	end
	return -log_lhood
end

function get_exp_stats(subj::subj_t)

	m_rt_2_corr = mean(subj.rt_v[map((x,y) -> x == 2 && y == 4, subj.tone_v, subj.response_v)]) ;
	m_rt_2_incorr = mean(subj.rt_v[map((x,y) -> x == 2 && y == 1, subj.tone_v, subj.response_v)]) ;

	m_rt_8_corr = mean(subj.rt_v[map((x,y) -> x == 8 && y == 1, subj.tone_v, subj.response_v)]) ;
	m_rt_8_incorr = mean(subj.rt_v[map((x,y) -> x == 8 && y == 4, subj.tone_v, subj.response_v)]) ;

	std_rt_2_corr = std(subj.rt_v[map((x,y) -> x == 2 && y == 4, subj.tone_v, subj.response_v)]) ;
	std_rt_2_incorr = std(subj.rt_v[map((x,y) -> x == 2 && y == 1, subj.tone_v, subj.response_v)]) ;

	std_rt_8_corr = std(subj.rt_v[map((x,y) -> x == 8 && y == 1, subj.tone_v, subj.response_v)]) ;
	std_rt_8_incorr = std(subj.rt_v[map((x,y) -> x == 8 && y == 4, subj.tone_v, subj.response_v)]) ;

	n_2_corr = length(subj.response_v[map((x,y) -> x == 2 && y == 4, subj.tone_v, subj.response_v)]) ;	
	n_2_incorr = length(subj.response_v[map((x,y) -> x == 2 && y == 1, subj.tone_v, subj.response_v)]) ;

	n_8_corr = length(subj.response_v[map((x,y) -> x == 8 && y == 1, subj.tone_v, subj.response_v)]) ;
	n_8_incorr = length(subj.response_v[map((x,y) -> x == 8 && y == 4, subj.tone_v, subj.response_v)]) ;

	println(std_rt_2_corr / sqrt(n_2_corr))
	println(std_rt_2_incorr / sqrt(n_2_incorr))
	println(std_rt_8_corr / sqrt(n_8_corr))
	println(std_rt_8_incorr / sqrt(n_8_incorr))
	println("--------------------------------------------")

	return exp_stats(Normal(m_rt_2_corr, std_rt_2_corr / sqrt(n_2_corr)),
					Normal(m_rt_2_incorr, std_rt_2_incorr / sqrt(n_2_incorr)),
					Normal(m_rt_8_corr, std_rt_8_corr / sqrt(n_8_corr)),
					Normal(m_rt_8_incorr, std_rt_8_incorr / sqrt(n_8_incorr)),
					n_2_corr,
					n_2_incorr,
					n_8_corr,
					n_8_incorr)
end

function get_agent_stats(tone_v::Array{Int64,1}, response_v::Array{Int64,1}, rt_v::Array{Float64,1})
	#=
	rt_2_corr = mean(rt_v[map((x,y) -> x == 2 && y == 2, tone_v, response_v)]) ;
	rt_2_incorr = mean(rt_v[map((x,y) -> x == 2 && y == 8, tone_v, response_v)]) ;

	rt_8_corr = mean(rt_v[map((x,y) -> x == 8 && y == 8, tone_v, response_v)]) ;
	rt_8_incorr = mean(rt_v[map((x,y) -> x == 8 && y == 2, tone_v, response_v)]) ;

	p_2_corr = length(response_v[map((x,y) -> x == 2 && y == 2, tone_v, response_v)]) /
				length(response_v[map((x,y) -> x == 2 && y != 0, tone_v, response_v)]) ;

	p_8_corr = length(response_v[map((x,y) -> x == 8 && y == 8, tone_v, response_v)]) /
				length(response_v[map((x,y) -> x == 8 && y != 0, tone_v, response_v)]) ;

	return agent_stats(rt_2_corr, rt_2_incorr, rt_8_corr, rt_8_incorr, 
						p_2_corr, p_8_corr)
	=#

	rt_2_corr_v = rt_v[map((x,y) -> x == 2 && y == 2, tone_v, response_v)] ;
	rt_2_incorr_v = rt_v[map((x,y) -> x == 2 && y == 8, tone_v, response_v)] ;

	rt_5_2_v = rt_v[map((x,y) -> x == 5 && y == 2, tone_v, response_v)] ;
	rt_5_8_v = rt_v[map((x,y) -> x == 5 && y == 8, tone_v, response_v)] ;

	rt_8_corr_v = rt_v[map((x,y) -> x == 8 && y == 8, tone_v, response_v)] ;
	rt_8_incorr_v = rt_v[map((x,y) -> x == 8 && y == 2, tone_v, response_v)] ;

	return agent_stats(tone_v, response_v, 
					rt_2_corr_v, rt_2_incorr_v, 
					rt_5_2_v, rt_5_8_v, 
					rt_8_corr_v, rt_8_incorr_v)
end