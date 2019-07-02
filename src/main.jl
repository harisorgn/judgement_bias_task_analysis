
using Distributions, HypothesisTests, Discreet, StatsBase, Statistics, Random, Optim, CSV, PyPlot

include("/adm/exp/klimb.jl")
include("/adm/exp/analysis.jl")

include("constants.jl")
include("agent.jl")
include("task.jl")
include("model_fit.jl")

#=
session_to_analyse = :probe ;
write_flag = false ;
path = "/adm/exp/ho2/4vs1 probe/"

subj_v = klimb_read(path, session_to_analyse, write_flag) ;

const rat = subj_v[1] ;

r_w_range = [2.9] ;
min_v = Array{Float64,1}(undef, length(r_w_range)) ;


for w = 1 : length(r_w_range)

	r_w = r_w_range[w] ;

	res = optimize(x -> obj_func(x, r_w), [0.8, 1.5, 1.0, 1.0], NelderMead(), 
				Optim.Options(iterations = Int64(1e5))) ;

	min_v[w] = Optim.minimum(res) ;

	println(Optim.minimizer(res))
	println(Optim.minimum(res))
	println(Optim.converged(res))
	println("------------------------------------------")
end

figure()
ax = gca()

plot(r_w_range, min_v)
show()
=#

# [1.2262, 1.62935, 0.386373, 0.644459]

const r_w = 2.0 ;

(tone_v, response_v, rt_v) = task(1.2262, 1.62935, 0.386373, 0.644459)

mask_amb = map(x -> x == 5, tone_v) ;

println(rt_v[mask_amb])
println(response_v[mask_amb])