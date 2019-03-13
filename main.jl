using CSV, DataStreams, XLSX, DataFrames, PyPlot
using Distributions, HypothesisTests, Discreet, StatsBase, Statistics, Random

include("klimb.jl")
include("analysis.jl")
include("constants.jl")
include("mi.jl")
include("plot.jl")


session_to_analyse = :probe ;
write_flag = false ;
path = "./exp/probe/baseline/"

#klimb_mi(path, session_to_analyse, 10) 
subj_v = klimb_read(path, session_to_analyse, write_flag)

plot_switch(subj_v)

#=
path = "./exp/probe/ketamine/veh/" ;
subj_veh_v = old_klimb_read(path, session_to_analyse, write_flag)

path = "./exp/probe/ketamine/ket/" ;
subj_ket_v = old_klimb_read(path, session_to_analyse, write_flag)

plot_ket_switch(subj_veh_v, subj_ket_v) 
=#

