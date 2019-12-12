using XLSX, DataFrames,  DataStructures
using Statistics, Distributions, Random
#using Optim, LineSearches, ForwardDiff, DiffEqDiffTools, LinearAlgebra

include("general_io.jl")
include("klimb.jl")
include("analysis.jl")
include("constants.jl")
include("mi.jl")
include("plot.jl")
include("fit.jl")


session_to_analyse = :probe ;
write_flag = false ;
path = "./ch15/probabilistic/ketamine 2/"

subj_v = klimb_read(path, session_to_analyse, write_flag)

session_subj_v = get_session_subj(subj_v, 0) ;

plot_block_data(session_subj_v, 5, ["Vehicle", "Ketamine"])

#plot_block_acc(session_subj_v) ;

#plot_block_data(session_subj_v, 24, ["First", "Second"])

#=
session_to_analyse = :probe ;
write_flag = false ;

path = "./probe/ketamine/veh/"
s1_subj_v = old_klimb_read(path, session_to_analyse, write_flag)

path = "./probe/ketamine/ket/"
s2_subj_v = old_klimb_read(path, session_to_analyse, write_flag)

plot_block_resp_rt(s1_subj_v, s2_subj_v)
=#
