###################################################
## taxiproblem.jl
## types defining a taxi-problem and solution
###################################################

"""
    `Customer` All data needed to describe a customer
"""
immutable Customer
    "customer id"
    id::Int
    "Pick-up node in the graph"
    orig::Int
    "drop-off node in the graph"
    dest::Int
    "time of call for online simulations (seconds)"
    tcall::Float64
    "Earliest time for pickup (seconds)"
    tmin::Float64
    "Latest time for pickup (seconds)"
    tmaxt::Float64
    "Fare paid by customer for the ride (dollars)"
    price::Float64
end

function Base.show(io::IO, c::Customer)
    @printf(io,"Cust %d, %d=>%d, t=(%.2f,%.2f,%.2f), p=%.2f", c.id, c.orig, c.dest, c.tcall, c.tmin, c.tmaxt, c.price)
end

"""
    `Taxi`: All data needed to represent a taxi"
"""
immutable Taxi
    id::Int
    initPos::Int
    initTime::Float64
end

function Base.show(io::IO, t::Taxi)
    @printf(io,"Taxi %d, init-loc=%d init-time=%.2f", t.id, t.initPos, t.initTime)
end

"""
    `TaxiProblem`: All data needed for simulation
"""
type TaxiProblem
    "The routing network of the taxi problem"
    network::Network
    "road times (seconds)"
    roadtime::AbstractArray{Float64,2}
    "road costs (dollars)"
    roadcost::AbstractArray{Float64,2}
    "routing information"
    paths::RoutingPaths
    "path travel times (seconds)"
    traveltime::Array{Float64,2}
    "path travel costs (dollars)"
    travelcost::Array{Float64,2}
    "customers"
    custs::Vector{Customer}
    "taxis"
    taxis::Vector{Taxi}
    "last possible pick-up time (seconds)"
    nTime::Float64
    "cost of waiting one second (dollars)"
    waitingCost::Float64
    "time to pickup or dropoff a customer (seconds)"
    customerTime::Float64
end

function Base.show(io::IO, pb::TaxiProblem)
    nLocs = nNodes(pb.network); nRoads = nRoads(pb.network)
    println(io, "Taxi Problem")
    println(io, "City with $nLocs locations and $nRoads roads")
    if pb.nTime == 0
        println(io, "No simulation created yet")
    else
        @printf(io, "Simulation with %i customers and %i taxis for %.2f minutes\n",
            length(pb.custs), length(pb.taxis), pb.nTime/60.)
    end
end

"""
    `CustomerAssignment`:  assignement of a customer to a taxi
"""
immutable CustomerAssignment
    "customer's ID"
    custID::Int
    "taxi's ID"
    taxiID::Int
    "pickup time"
    timeIn::Float64
    "dropoff time"
    timeOut::Float64
end

function Base.show(io::IO, t::CustomerAssignment)
    @printf(io,"Taxi %d serves customer %d during [%.2f,%.2f]", t.custID, t.taxiID, t.timeIn, t.timeOut)
end

"""
    `TaxiActions`: actions of a taxi during a simulation (path, timings and customers)
"""
type TaxiActions
    "taxi's ID"
    taxiID::Int
    "path in the network (list of nodes)"
    path::Vector{Int}
    "times of each road travel"
    times::Vector{Float64}
    "customers assigned to taxi, sorted by pick-up time"
    custs::Vector{CustomerAssignment}
end

function Base.show(io::IO, t::TaxiActions)
    @printf(io,"Actions of taxi %d: serves %d customers - drives %d roads", t.taxiID, length(t.custs), length(t.path))
end

"""
    `TaxiSolution`: a solution to a TaxiProblem
"""
type TaxiSolution
    "corresponding TaxiProblem"
    pb::TaxiProblem
    "actions of each taxi"
    actions::Vector{TaxiActions}
    "customers not taken"
    notTaken::BitVector
    "solution's revenue"
    revenue::Float64
end

function Base.show(io::IO, sol::TaxiSolution)
    nCusts = length(sol.pb.custs); nTaxis = length(sol.pb.taxis)
    println(io, "TaxiSolution, problem with $nCusts and $nTaxis taxis")
    @printf(io, "Revenue : %.2f dollars\n", sol.revenue)
    println(io, "$nt customers not served. ")
end