using XLSX, DataFrames,  DataStructures, CSV
using Statistics
#using Distributions, Random

include("general_io.jl")
include("klimb.jl")
include("analysis.jl")
include("constants.jl")
include("mi.jl")
include("plot.jl")
include("fit.jl")


session_to_analyse = :probe ;
write_flag = false ;
path = "./CP101606/"

subj_v = klimb_read(path, session_to_analyse, write_flag)

session_subj_v = get_session_subj(subj_v, 0) ;

#=
(r_h, ~) = get_block_data(session_subj_v[2], 2, 5, 2)
(r_l, ~) = get_block_data(session_subj_v[2], 2, 5, 8)


df = DataFrame(High_first_block = r_h[:,1], Low_first_block = r_l[:,1], 
			High_second_block = r_h[:,2], Low_second_block = r_l[:,2])

CSV.write("Scopolamine_veh_blocks.csv", df)
=#

#label_v = ["First probe session", "Second probe session"] ;
label_v = ["$(i)" for i = 1 : length(session_subj_v)] ;

plot_block_data(session_subj_v, 5, label_v, session_to_analyse)

