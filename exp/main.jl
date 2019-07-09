using XLSX, DataFrames,  DataStructures
using Statistics, Distributions, HypothesisTests, Random
using Optim, LineSearches, ForwardDiff, DiffEqDiffTools, LinearAlgebra
using RecursiveArrayTools

include("general_io.jl")
include("klimb.jl")
include("analysis.jl")
include("constants.jl")
include("mi.jl")
include("plot.jl")
include("fit.jl")


session_to_analyse = :probe ;
write_flag = false ;
path = "./ch14/multiple amb/1st session/"

subj_v = klimb_read(path, session_to_analyse, write_flag)

plot_psychometric(subj_v, fit = true, curve = :all)

#plot_rt_prev(subj_v)

#plot_switch(subj_v)

#=
path = "./exp/probe/ketamine/veh/" ;
subj_veh_v = old_klimb_read(path, session_to_analyse, write_flag)

path = "./exp/probe/ketamine/ket/" ;
subj_ket_v = old_klimb_read(path, session_to_analyse, write_flag)

plot_ket_switch(subj_veh_v, subj_ket_v) 
=#

