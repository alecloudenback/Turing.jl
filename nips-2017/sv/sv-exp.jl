using Distributions
using Turing
using HDF5, JLD

TPATH = Pkg.dir("Turing")

include(TPATH*"/example-models/nuts-paper/sv_helper.jl")

y = readsvdata()

# Stochastic volatility (SV)
@model sv_nuts(y, N, dy) = begin
  τ ~ Exponential(1/100)
  ν ~ Exponential(1/100)
  s = TArray{Real}(N)
  s[1] ~ Exponential(1/100)
  for i = 2:N
    s[i] ~ Normal(log(s[i-1]), τ)
    s[i] = exp(s[i])
    dy = typeof(ν)(log(y[i] / y[i-1]) / s[i])
    dy ~ TDist(ν)
  end
end

N = length(y)


# chain = sample(sv_nuts(y, N, NaN), Gibbs(1000,PG(50,1,:s),NUTS(1,200,0.65,:τ,:ν)))
# save(TPATH*"/nips-2017/sv/sv-exps-Gibbs(1000,PG(50,1),NUTS(1,200,0.65))-chain.jld", "chain", chain)

chain = sample(sv_nuts(y, N, NaN), NUTS(1000,200,0.65))
save(TPATH*"/nips-2017/sv/sv-exps-NUTS(1000,200,0.65)-chain.jld", "chain", chain)

describe(chain)