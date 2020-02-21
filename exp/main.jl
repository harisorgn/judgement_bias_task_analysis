using XLSX, DataFrames,  DataStructures, CSV
using Statistics
#using Distributions, Random
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
path = "./ho3/1v1_reversed_changed_2khz_db/"

subj_v = klimb_read(path, session_to_analyse, write_flag)

session_subj_v = get_session_subj(subj_v, 0) ;

label_v = ["First probe session", "Second probe session"] ;
#label_v = ["$(i)" for i = 1 : length(session_subj_v)] ;

plot_block_data(session_subj_v, 5, label_v, session_to_analyse)

#plot_block_acc(session_subj_v) ;

