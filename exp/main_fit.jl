using CSV, DataStreams, XLSX, DataFrames
using Distributions, HypothesisTests, Discreet, StatsBase, Statistics, Random

include("klimb.jl")
include("analysis.jl")
include("constants.jl")
include("plot.jl")
include("fit.jl")

session_to_analyse = :probe ;
write_flag = false ;
path = "./ch14/multiple amb/1st session/"

subj_v = klimb_read(path, session_to_analyse, write_flag)

x = collect(2.0:0.1:8.0) ;
figure()
ax = gca()
ax.tick_params(labelsize = 18)

cf = fit_psychometric([subj_v[1]], 4, :log_std) ;
plot(x, log_model(x, cf),"-r")

show()