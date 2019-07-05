
using CSV, DataStreams, XLSX, DataFrames, DataStructures
using Distributions, HypothesisTests, Discreet, StatsBase, Statistics, Random

include("klimb.jl")
include("analysis.jl")
include("constants.jl")
include("mi.jl")
include("plot.jl")
include("fit.jl")




path = "./ch14/multiple amb/1st session/"

if isempty(path)
	file_v = date_sort(filter(x->occursin(".csv", x), readdir())) ;
else
	file_v = date_sort(filter(x->occursin(".csv", x), readdir(path))) ;
end


for file_name in file_v

	dt = read_csv_var_cols(string(path, file_name))
	println()
	#=
	f = open(string(path, file_name))
	println(split(strip(readline(f)), ","))
	println(split(strip(readline(f)), ","))
	println(split(strip(readline(f)), ","))
	println(split(strip(readline(f)), ","))
	println(split(strip(readline(f)), ",")[2])
	close(f)
	=#
end


