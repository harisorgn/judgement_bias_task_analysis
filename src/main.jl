using DataFrames,  DataStructures
using Distributions, Statistics, Random, CSV, PyPlot, Tables
using NLopt, BlackBoxOptim

include("/adm/exp/klimb.jl")
include("/adm/exp/analysis.jl")
include("/adm/exp/general_io.jl")

include("constants.jl")
include("agent.jl")
include("task.jl")
include("model_fit.jl")


session_to_analyse = :probe ;
write_flag = false ;
path = "/adm/exp/ho2/4vs1 probe/1st session/"

subj_v = klimb_read(path, session_to_analyse, write_flag) ;

unique_subj_v = get_unique_subj_v(subj_v) ;
const rat = unique_subj_v[1] ;

r_w_range = 1.0:0.2:10.0 ;
min_v = Array{Float64,1}(undef, length(r_w_range)) ;
#=
opt = Opt(:LN_COBYLA, 5) ;
opt.lower_bounds = [0.0, 0.0, 0.0, 0.0, 0.0] ;
opt.upper_bounds = [Inf, Inf, Inf, Inf, 0.5]

for w = 1 : length(r_w_range)

	r_w = r_w_range[w] ;

	opt.max_objective = (x, grad) -> obj_func(x, grad, r_w) ;

	(optf, optx, ret) = optimize(opt, [0.8, 1.5, 1.0, 1.0, 0.1])

	min_v[w] = optf ;

	println(optf)
	println(optx)
	println(ret)
	println("------------------------------------------")
end

figure()
ax = gca()

plot(r_w_range, min_v)
show()
=#

const c_loss = 0.0 ;

opt = Opt(:LN_SBPLX, 6) ;
opt.lower_bounds = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0] ;
opt.upper_bounds = [Inf, Inf, Inf, Inf, Inf, 0.5] ;

opt.max_objective = (x, grad) -> obj_func(x, grad) ;

(optf, optx, ret) = optimize(opt, [10.0, 5.0, 1.5, 1.0, 3.5, 0.2])

println(optf)
println(optx)
println(ret)


#=
grad = Array{Float64,1}(undef, 6)

res = bboptimize( x -> obj_func(x, grad); 
	SearchRange = [(0.0, 100.0), (0.0, 100.0), (0.0, 100.0), (0.0, 100.0), (0.0, 0.5), (0.0, 100.0)],
	NumDimensions = 6)

println(best_fitness(res))
println(best_candidate(res))
=#