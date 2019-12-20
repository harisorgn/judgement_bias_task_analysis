using XLSX, DataFrames,  DataStructures, CSV
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
path = "./ch15/probabilistic/ketamine 1/"

subj_v = klimb_read(path, session_to_analyse, write_flag)

session_subj_v = get_session_subj(subj_v, 0) ;

session_mh_m = get_block_data(session_subj_v[2], 5, 5, 2) ;
session_ml_m = get_block_data(session_subj_v[2], 5, 5, 8) ;

CSV.write("High_ketamine.csv", DataFrame(session_mh_m), header = ["Block 1", "Block 2", "Block 3", "Block 4", "Block 5"])

#plot_block_data(session_subj_v, 5, ["Vehicle", "Ketamine"])

#plot_block_acc(session_subj_v) ;

