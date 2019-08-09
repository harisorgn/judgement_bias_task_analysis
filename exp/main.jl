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
write_flag = true ;
path = "./jb9/reversed/"

subj_v = klimb_read(path, session_to_analyse, write_flag)

#subj_v = old_klimb_read(path, session_to_analyse, write_flag)

#plot_rt(subj_v)

#=
session_to_analyse = :probe ;
write_flag = true ;
path = "./probe/ketamine/veh/"

subj_v = old_klimb_read(path, session_to_analyse, write_flag)

path = "./probe/ketamine/ket/"
subj_ket_v = old_klimb_read(path, session_to_analyse, write_flag)
append!(subj_v, subj_ket_v) ;

ff_v = Array{Float64,1}() ;
fs_v = Array{Float64,1}() ;
sf_v = Array{Float64,1}() ;
ss_v = Array{Float64,1}() ;

considered_subj_v = Array{String, 1}() ;

for subj in subj_v
	
	M_f = map((x,y) -> x == 5 && y !=0, subj.tone_v[1:Int64(round(length(subj.tone_v)/2.0))], 
										subj.response_v[1:Int64(round(length(subj.tone_v)/2.0))]) ;

	M_s = map((x,y) -> x == 5 && y !=0, subj.tone_v[Int64(round(length(subj.tone_v)/2.0)) + 1 : end], 
										subj.response_v[Int64(round(length(subj.tone_v)/2.0)) + 1 : end]) ;

	MH_f = map((x,y) -> x == 5 && y == 2, subj.tone_v[1:Int64(round(length(subj.tone_v)/2.0))], 
										subj.response_v[1:Int64(round(length(subj.tone_v)/2.0))]) ;

	MH_s = map((x,y) -> x == 5 && y == 2, subj.tone_v[Int64(round(length(subj.tone_v)/2.0)) + 1 : end], 
										subj.response_v[Int64(round(length(subj.tone_v)/2.0)) + 1 : end]) ;

	ML_f = map((x,y) -> x == 5 && y == 8, subj.tone_v[1:Int64(round(length(subj.tone_v)/2.0))], 
										subj.response_v[1:Int64(round(length(subj.tone_v)/2.0))]) ;

	ML_s = map((x,y) -> x == 5 && y == 8, subj.tone_v[Int64(round(length(subj.tone_v)/2.0)) + 1 : end], 
										subj.response_v[Int64(round(length(subj.tone_v)/2.0)) + 1 : end]) ;

	if count(x -> x == subj.id, considered_subj_v) == 1
		append!(sf_v, 100.0 * count(x -> x == true, MH_f) / count(x -> x == true, M_f)) ;
		append!(ss_v, 100.0 * count(x -> x == true, MH_s) / count(x -> x == true, M_s)) ;
		push!(considered_subj_v, subj.id) ;
	elseif count(x -> x == subj.id, considered_subj_v) == 0 && !(subj.id in exclude_v)
		append!(ff_v, 100.0 * count(x -> x == true, MH_f) / count(x -> x == true, M_f)) ;
		append!(fs_v, 100.0 * count(x -> x == true, MH_s) / count(x -> x == true, M_s)) ;
		push!(considered_subj_v, subj.id) ;
	end
end

println(pvalue(EqualVarianceTTest(ff_v, fs_v)))
println(pvalue(EqualVarianceTTest(sf_v, ss_v)))


figure()
ax = gca()

scatter(fill(1.0, length(ff_v)), ff_v, alpha = 0.5, color = "black")

errorbar(1.0, mean(ff_v), yerr = std(ff_v) / sqrt(length(ff_v)), 
				marker = "D", markersize = 10, capsize = 10, color = "black")

scatter(fill(2.0, length(fs_v)), fs_v, alpha = 0.5, color = "black")

errorbar(2.0, mean(fs_v), yerr = std(fs_v) / sqrt(length(fs_v)), 
				marker = "D", markersize = 10, capsize = 10, color = "black")

scatter(fill(3.0, length(sf_v)), sf_v, alpha = 0.5, color = "black")

errorbar(3.0, mean(sf_v), yerr = std(sf_v) / sqrt(length(sf_v)), 
				marker = "D", markersize = 10, capsize = 10, color = "black")

scatter(fill(4.0, length(ss_v)), ss_v, alpha = 0.5, color = "black")

errorbar(4.0, mean(ss_v), yerr = std(ss_v) / sqrt(length(ss_v)), 
				marker = "D", markersize = 10, capsize = 10, color = "black")

plot([1.0, 2.0, 3.0, 4.0], [mean(ff_v), mean(fs_v), mean(sf_v), mean(ss_v)], "-k")

println(pvalue(EqualVarianceTTest(append!(ff_v, fs_v), append!(sf_v, ss_v))))

path = "./probe/ketamine/veh nomaineffect/"

subj_v = old_klimb_read(path, session_to_analyse, write_flag)

path = "./probe/ketamine/ket nomaineffect/"
subj_ket_v = old_klimb_read(path, session_to_analyse, write_flag)
append!(subj_v, subj_ket_v) ;

ff_v = Array{Float64,1}() ;
fs_v = Array{Float64,1}() ;
sf_v = Array{Float64,1}() ;
ss_v = Array{Float64,1}() ;

considered_subj_v = Array{String, 1}() ;

for subj in subj_v
	
	M_f = map((x,y) -> x == 5 && y !=0, subj.tone_v[1:Int64(round(length(subj.tone_v)/2.0))], 
										subj.response_v[1:Int64(round(length(subj.tone_v)/2.0))]) ;

	M_s = map((x,y) -> x == 5 && y !=0, subj.tone_v[Int64(round(length(subj.tone_v)/2.0)) + 1 : end], 
										subj.response_v[Int64(round(length(subj.tone_v)/2.0)) + 1 : end]) ;

	MH_f = map((x,y) -> x == 5 && y == 2, subj.tone_v[1:Int64(round(length(subj.tone_v)/2.0))], 
										subj.response_v[1:Int64(round(length(subj.tone_v)/2.0))]) ;

	MH_s = map((x,y) -> x == 5 && y == 2, subj.tone_v[Int64(round(length(subj.tone_v)/2.0)) + 1 : end], 
										subj.response_v[Int64(round(length(subj.tone_v)/2.0)) + 1 : end]) ;

	ML_f = map((x,y) -> x == 5 && y == 8, subj.tone_v[1:Int64(round(length(subj.tone_v)/2.0))], 
										subj.response_v[1:Int64(round(length(subj.tone_v)/2.0))]) ;

	ML_s = map((x,y) -> x == 5 && y == 8, subj.tone_v[Int64(round(length(subj.tone_v)/2.0)) + 1 : end], 
										subj.response_v[Int64(round(length(subj.tone_v)/2.0)) + 1 : end]) ;

	if count(x -> x == subj.id, considered_subj_v) == 1
		append!(sf_v, 100.0 * count(x -> x == true, MH_f) / count(x -> x == true, M_f)) ;
		append!(ss_v, 100.0 * count(x -> x == true, MH_s) / count(x -> x == true, M_s)) ;
		push!(considered_subj_v, subj.id) ;
	elseif count(x -> x == subj.id, considered_subj_v) == 0 && !(subj.id in exclude_v)
		append!(ff_v, 100.0 * count(x -> x == true, MH_f) / count(x -> x == true, M_f)) ;
		append!(fs_v, 100.0 * count(x -> x == true, MH_s) / count(x -> x == true, M_s)) ;
		push!(considered_subj_v, subj.id) ;
	end
end

println(pvalue(EqualVarianceTTest(ff_v, fs_v)))
println(pvalue(EqualVarianceTTest(sf_v, ss_v)))


scatter(fill(1.0, length(ff_v)), ff_v, alpha = 0.5, color = "red")

errorbar(1.0, mean(ff_v), yerr = std(ff_v) / sqrt(length(ff_v)), 
				marker = "D", markersize = 10, capsize = 10, color = "red")

scatter(fill(2.0, length(fs_v)), fs_v, alpha = 0.5, color = "red")

errorbar(2.0, mean(fs_v), yerr = std(fs_v) / sqrt(length(fs_v)), 
				marker = "D", markersize = 10, capsize = 10, color = "red")

scatter(fill(3.0, length(sf_v)), sf_v, alpha = 0.5, color = "red")

errorbar(3.0, mean(sf_v), yerr = std(sf_v) / sqrt(length(sf_v)), 
				marker = "D", markersize = 10, capsize = 10, color = "red")

scatter(fill(4.0, length(ss_v)), ss_v, alpha = 0.5, color = "red")

errorbar(4.0, mean(ss_v), yerr = std(ss_v) / sqrt(length(ss_v)), 
				marker = "D", markersize = 10, capsize = 10, color = "red")

plot([1.0, 2.0, 3.0, 4.0], [mean(ff_v), mean(fs_v), mean(sf_v), mean(ss_v)], "-r")

println(pvalue(EqualVarianceTTest(append!(ff_v, fs_v), append!(sf_v, ss_v))))

show()
=#

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

