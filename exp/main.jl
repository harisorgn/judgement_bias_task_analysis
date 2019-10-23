using XLSX, DataFrames,  DataStructures
using Statistics, Distributions, HypothesisTests, Random
using Optim, LineSearches, ForwardDiff, DiffEqDiffTools, LinearAlgebra
using RecursiveArrayTools
using MultivariateStats

include("general_io.jl")
include("klimb.jl")
include("analysis.jl")
include("constants.jl")
include("mi.jl")
include("plot.jl")
include("fit.jl")

session_to_analyse = :probe ;
write_flag = false ;
path = "./probe/baseline/"

subj_v = klimb_read(path, session_to_analyse, write_flag)

plot_resp_rt_prev_reward(subj_v)

#plot_rr(subj_v, 20)

#subj_v = old_klimb_read(path, session_to_analyse, write_flag)

#plot_rt(subj_v)

#plot_psychometric(subj_v, -1, -1, -1, fit = false, curve = :all)

#plot_rt_prev(subj_v)

#plot_switch(subj_v)

#=
path = "./exp/probe/ketamine/veh/" ;
subj_veh_v = old_klimb_read(path, session_to_analyse, write_flag)

path = "./exp/probe/ketamine/ket/" ;
subj_ket_v = old_klimb_read(path, session_to_analyse, write_flag)

plot_ket_switch(subj_veh_v, subj_ket_v) 
=#

