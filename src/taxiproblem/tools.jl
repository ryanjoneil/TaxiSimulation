###################################################
## taxiproblem/tools.jl
## various tools (not exported)
###################################################

"""
    `minutesSeconds`, returns current minute and second
"""
function minutesSeconds(t::Float64)
    minutes = floor(Int,t/60)
	return minutes, floor(Int, t-60*minutes)
end

"""
    `emptyActions`, empty list of taxiActions for a TaxiProblem
"""
emptyActions(pb::TaxiProblem)=
TaxiActions[TaxiActions(t.id, Int[t.initPos], Float64[], CustomerAssignment[]) for t in pb.taxis]

"""
    `rejectedCustomers`, compute set of rejected customers
"""
function rejectedCustomers(pb::TaxiProblem, actions::Vector{TaxiActions})
    rejected = IntSet(eachindex(pb.custs))
    for act in actions, c in act.custs
        delete!(rejected, c.id)
    end
    return rejected
end

"""
    `updateTcall`, change the request times (!not a deep copy!)
    - either with fixed offset time or with uniform random
"""
function updateTcall(pb::TaxiProblem, time::Float64; random::Bool = false)
    pb2 = copy(pb)
    if random
        pb2.custs = Customer[Customer(c.id,c.orig,c.dest, max(0., c.tmin-rand()*time), c.tmin, c.tmax, c.fare) for c in pb.custs]
    else
        pb2.custs = Customer[Customer(c.id,c.orig,c.dest, max(0., c.tmin-time), c.tmin, c.tmax, c.fare) for c in pb.custs]
    end
    return pb2
end

"""
    `pureOffline`, Returns a taxi problem with all tcall set to zero
"""
pureOffline(pb::TaxiProblem) = updateTcall(pb::TaxiProblem, Inf, random=false)

"""
    `pureOnline`, Returns a taxi problem with all tcall set to tmin
"""
pureOnline(pb::TaxiProblem) = updateTcall(pb::TaxiProblem, 0., random=false)

"""
    `updateTmax`, change the lengths of time-windows (!not a deep copy!)
    - either with fixed offset time or with uniform random
"""
function updateTmax(pb::TaxiProblem, time::Float64; random::Bool = false)
    pb2 = copy(pb)
    if random
        pb2.custs = Customer[Customer(c.id, c.orig, c.dest, c.tcall, c.tmin, min(c.tmin + rand()*time, pb.simTime), c.fare) for c in pb.custs]
    else
        pb2.custs = Customer[Customer(c.id, c.orig, c.dest, c.tcall, c.tmin, min(c.tmin + time, pb.simTime), c.fare) for c in pb.custs]
    end
    return pb2
end

"""
    `noTmax`, Returns a taxi problem with all tmaxt set to nTime
"""
noTmax(pb::TaxiProblem) = updateTmax(pb, Inf, random=false)
