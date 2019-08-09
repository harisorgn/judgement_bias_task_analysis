using NLsolve

function f2!(F, x)

	F[1] = exp(-(0.08^2.0) / (2.0 * (x[1]^2.0))) / (x[1] * sqrt(2.0 * pi)) - 0.5 ;

end

function f8!(F, x)

	F[1] = exp(-(0.44^2.0) / (2.0 * (x[1]^2.0))) / (x[1] * sqrt(2.0 * pi)) - 0.5 ;

end

println(nlsolve(f2!, [0.5]))

println(nlsolve(f8!, [1.0]))