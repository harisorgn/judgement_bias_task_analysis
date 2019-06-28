using CSV, DataStreams, XLSX, DataFrames
using Distributions, HypothesisTests, Discreet, StatsBase, Statistics, Random

include("klimb.jl")
include("analysis.jl")
include("constants.jl")
include("plot.jl")
include("fit.jl")

session_to_analyse = :probe ;
write_flag = false ;
path = "./ho2/1vs1 probe/"

subj_v = klimb_read(path, session_to_analyse, write_flag)

x = collect(2.0:0.1:8.0) ;
figure()
ax = gca()
ax.tick_params(labelsize = 18)

cf = fit(subj_v, 4, :log) ;
plot(x, log_model(x, cf),"-r")

#cf = fit(subj_v, 1, :log) ;
#plot(x, log_model(x, cf),"-r")


path = "./ho2/4vs1 probe/1st session/"

subj_v = klimb_read(path, session_to_analyse, write_flag)

cf = fit(subj_v, 4, :log) ;

plot(x, log_model(x, cf),"-g")

path = "./ho2/4vs1 probe/2nd session/"

subj_v = klimb_read(path, session_to_analyse, write_flag)

cf = fit(subj_v, 4, :log) ;

plot(x, log_model(x, cf),"-b")

show()