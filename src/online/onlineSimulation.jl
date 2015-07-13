"""
Simulates the online problem by initializing an Online Method, updating customers 
using TCall, then proccesses the returned TaxiActions to produce a TaxiSolution
"""
function onlineSimulation(pb::TaxiProblem, om::OnlineMethod; period::Float64 = 1.0)
	custs = sort(pb.custs, by = x -> x.tcall)
	initialCustomers = Vector{Customer}
	laterCustomers = Vector{Customer}

	simplePb = copy(pb)
	simplePb.custs = Vector{Customer}

	initialize!(om, simplePb)
	totalTaxiActions = Array(TaxiActions, length(pb.taxis))

	currentStep = 1
	currentIndex = 1
	while (currentStep * period < pb.nTime)
		newCustomers = Vector{Customer}
		for index = currentIndex:length(custs)
			if custs[index].tcall > (currentStep - 1) * period
				newCustomers = custs[currentIndex:(index - 1)]
				currentIndex = index
				break
			end
		end
		
		newTaxiActions = update!(om, min(currentStep * period, pb.nTime), newCustomers)
		for (k,totalAction) in enumerate(totalTaxiActions)
			if newTaxiActions[k].path[1][1] >= (currentStep - 1) * period && newTaxiActions[k].custs[1][2] >= (currentStep - 1) * period
				append!(totalAction.path,newTaxiActions[k].path)
				append!(totalAction.custs,newTaxiActions[k].custs)
			end
		end
		currentStep += 1
	end

	# for (k, totalAction) in enumerate(totalTaxiActions)
	# 	if totalAction.custs[end].timeIn <= pb.nTime < totalAction.custs[end].timeOut
	# 		finalPath = getPath(pb, dst(totalAction.path[end][2]), pb.custs[totalAction.custs[end].id].dest)
	# 		append!(totalAction.path, finalPath)
	# 	end
	# end

	customersNotTaken = falses(length(pb.custs))
	for taxi in totalTaxiActions, customer in totalTaxiActions[taxi].custs
		customersNotTaken[customer] = true
	end

	totalCost = solutionCost(pb, totalTaxiActions)

	return TaxiSolution(totalTaxiActions, customersNotTaken, totalCost)
end