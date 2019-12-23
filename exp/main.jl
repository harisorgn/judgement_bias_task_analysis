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
write_flag = true ;
path = "./ho3/1v1/"

subj_v = klimb_read(path, session_to_analyse, write_flag)

session_subj_v = get_session_subj(subj_v, 0) ;

plot_block_data(session_subj_v, 5, ["first", "second"])

#plot_block_data(session_subj_v, 5, ["Vehicle", "Ketamine"])

#plot_block_acc(session_subj_v) ;

