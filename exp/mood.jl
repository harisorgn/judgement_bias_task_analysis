using DifferentialEquations
using Random, Distributions
using PyPlot

@inline wiener_randn(rng::AbstractRNG,::Type{T}) where T = randn(rng,T)
@inline function wiener_randn(rng::AbstractRNG,proto::Array{T}) where T
  randn(rng,size(proto))
end
@inline function wiener_randn(rng::AbstractRNG,proto)
  convert(typeof(proto),randn(rng,size(proto)))
end

@inline function wn_dist(W,dt,rng)
  if typeof(W.dW) <: AbstractArray && !(typeof(W.dW) <: SArray)
    return @fastmath sqrt(abs(dt))*(wiener_randn(rng,W.dW) .+ dist_offset)
  else
    return @fastmath sqrt(abs(dt))*(wiener_randn(rng,typeof(W.dW)) + dist_offset)
  end
end

function wn_bridge(W,W0,Wh,q,h,rng)
  if typeof(W.dW) <: AbstractArray
    return @fastmath sqrt((1-q)*q*abs(h))*(wiener_randn(rng,W.dW) .+ dist_offset)+q*Wh
  else
    return @fastmath sqrt((1-q)*q*abs(h))*(wiener_randn(rng,typeof(W.dW)) + dist_offset)+q*Wh
  end

end

function w_dist(t)
	return sqrt(abs(t)) * (rand(wd, 1)[1] .- t)
end

function f(du, u, p, t)
	du[1] = 0.0 ;
	du[2] = 0.0 ;
end

function g(du, u, p, t)
	du[1] = u[1] * p[1] ;
	du[2] = - u[2] * p[2] ;
end

#W = WienerProcess(0.0, 0.0) ;

const dist_offset = - 0.0 ;

rng = MersenneTwister(1234);

W = NoiseProcess{false}(0.0, 0.0, nothing, wn_dist, wn_bridge ; rng = rng) ;

dt = 1.0 ;

u0 = [6.0, 4.0] ;
tspan = (0.0, 10.0) ;
p = [0.1, 0.1] ;

#=
prob = NoiseProblem(W, (0.0, 20.0))
sol = solve(prob; dt = 1.0)

figure()
ax = gca()

plot(sol)

show()
=#


prob = SDEProblem(f, g, u0, tspan, p, noise = W) ;

sol = solve(prob, dt = dt, saveat = 1.0) ;

figure()
ax = gca()

#plot(sol[1,:], "-b")
#plot(sol[2,:], "-r")
plot(sol[1,:] - sol[2,:], "-k")

show()

