
using Distributions, HypothesisTests, Discreet, StatsBase, Statistics, Random, Optim, CSV

include("/adm/exp/klimb.jl")
include("/adm/exp/analysis.jl")

include("constants.jl")
include("agent.jl")
include("task.jl")
include("model_fit.jl")

session_to_analyse = :probe ;
write_flag = false ;
path = "/adm/exp/ho2/4vs1 probe/"

subj_v = klimb_read(path, session_to_analyse, write_flag) ;

const rat = subj_v[1] ;
const r_w = 4.0 ;

#rat = get_exp_stats(subj_v[1]) ;

res = optimize(obj_func, [0.8, 1.5, 1.0, 1.0], NelderMead(), 
			Optim.Options(iterations = Int64(1e5))) ;

println(Optim.minimizer(res))
println(Optim.minimum(res))

# [1.0162, 1.66093, 1.26707, 1.17299, 4.43551]