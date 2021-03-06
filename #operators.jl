#operator.jl
#This file contains the operator type definitions and base functions

type operator
#each concrete subtype of operator should implement the following methods
#BC::Function, returns value of transform type to be used. 
# These are BC for which Transform to be used in space and time 
#Transforms::function applied using elements of inputted FDS
#transform(i,j,k,t, FDS): performs in place update of FDS according to BC 
#and transform 
	BC::function #A boundary condition, can be either a matrix or function anything indexable. It can be used in different ways
	#If Transforms contains operators then BC will contain indices of which operators should be applied at which timestep index 
	#In addition to which spacial location
	#If Transforms is simply a function that operatates directly on FDS then BC will hold data relevant to the transformation required such 
	#as epsilon and mu.
	Transforms#This contains the operations to be done on FDS
	operator(Transforms, BC::function)=new(Transforms,BC)#Constructor for the operator. 

function applyOperator!(i,j,k,t,opp::operator,FDS)#Applys the operators transforms, if Transforms contains functions then they are applied
#However, operators will frequently contain other operators with their own BC IE refractive index...etc. 
	applyOperator!(i,j,k,t,FDS.Transforms[BC(i,j,k,t)], FDS)#Applies the operator in Transforms based on what the BC conditions require.
end

function applyOperator!(i,j,k,t,opp::function, FDS)#If we get to a base class of operator then the base class will 
	opp(i,j,k,t,FDS,BC)#Apply the operator Transform to the FDS at index i,j,k,t
	#Once we reach a base operator (IE an operator that has Transforms = a function that updates FDS) then it simply operates on the data
	#This terminates the hierarchical recursive operator structure. 
end


