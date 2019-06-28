using CSV, DataStreams, XLSX, DataFrames
using Distributions, HypothesisTests, Discreet, StatsBase, Statistics, Random

include("klimb.jl")
include("analysis.jl")
include("constants.jl")
include("mi.jl")
include("plot.jl")
include("fit.jl")


session_to_analyse = :probe ;
write_flag = false ;
path = "./ho2/1vs1 probe/"

#klimb_mi(path, session_to_analyse, 10) 
subj_v = klimb_read(path, session_to_analyse, write_flag)

fit(subj_v, 4, :sig) ;

#subj_psycho_v = get_psychometric(subj_v, -1, -1)	
#plot_psychometric(subj_psycho_v)

#plot(subj_v[16].rr_v)
#plot(fill(mean(subj_v[16].rr_v), length(subj_v[16].rr_v)), "--k")
#show()

#plot_rt_prev(subj_v)

#plot_switch(subj_v)

#=
path = "./exp/probe/ketamine/veh/" ;
subj_veh_v = old_klimb_read(path, session_to_analyse, write_flag)

path = "./exp/probe/ketamine/ket/" ;
subj_ket_v = old_klimb_read(path, session_to_analyse, write_flag)

plot_ket_switch(subj_veh_v, subj_ket_v) 
=#

