using CSV, DataStreams, XLSX, DataFrames, PyPlot
using Distributions, HypothesisTests, Discreet, StatsBase, Statistics, Random

include("klimb.jl")
include("analysis.jl")
include("constants.jl")
include("mi.jl")
include("plot.jl")

path = "./exp/ho2/1vs1 probe/" ;
session_to_analyse = :probe

subj_v = klimb_read(path, session_to_analyse)
#klimb_mi(path, session_to_analyse, 1)

switch_d = get_switch_after_incorr(subj_v) ;

switch_tupl_v = collect(values(switch_d)) ;

mask_significant = map(x -> x[1] >= x[2], switch_tupl_v) ;

figure()
ax = gca()
hist(map(x->x[1], switch_tupl_v[mask_significant]), 25, color = "g", label = "Significant")
hist(map(x->x[1], switch_tupl_v[.!mask_significant]), 25, color = "b", alpha = 0.2, label = "Not significant")
xlabel("Switches [%]", fontsize = 16)
ylabel("N [subjects]", fontsize = 16)
ax[:tick_params](labelsize = 16)
legend(fontsize = 16)

println(length(switch_tupl_v[mask_significant]))

same_d = get_same_after_corr(subj_v) ;

same_tupl_v = collect(values(same_d)) ;

mask_significant = map(x -> x[1] >= x[2], same_tupl_v) ;

figure()
ax = gca()
hist(map(x->x[1], same_tupl_v[mask_significant]), 25, color = "g", label = "Significant")
hist(map(x->x[1], same_tupl_v[.!mask_significant]), 25, color = "b", alpha = 0.2, label = "Not significant")
xlabel("Same presses [%]", fontsize = 16)
ylabel("N [subjects]", fontsize = 16)
ax[:tick_params](labelsize = 16)
legend(fontsize = 16)

println(length(collect(keys(switch_d))))

mask_both_significant = map((x,y) -> x[1] >= x[2] && y[1] >= y[2], switch_tupl_v, same_tupl_v) ;

println(length(same_tupl_v[mask_significant]))

println(length(same_tupl_v[mask_both_significant]))

show()