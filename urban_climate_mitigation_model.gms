* Model code for the paper "Urban land use and transportation planning for
* climate change mitigation: A theoretical framework"
* By Prof. Benjamin D. Leibowicz
* The University of Texas at Austin
* 6/19/2019

* In the model, a social planner maximizes the common utility level of all
* households in an urban area by optimizing the spatial allocation of
* households to residential zones, investments in road and public transit
* infrastructures, and transportation mode shares. Residential and
* transportation GHG emissions yield damages that reduce utility.

Sets
i        set of residential zones / 1 * 2 /;
Alias(i,j);

Parameters
* Fundamental model parameters
a(i)     area of zone i
         / 1     4
           2     4 /
x(i)     distance from zone i to the city center
         / 1     2
           2     3 /
n        total population of households in the urban area        / 100 /
bb       total budget                                            / 2000 /
rr       investment cost for road capacity                       / 1 /
s        investment cost for public transit                      / 2 /
p        variable user cost for public transit                   / 0.001 /
er       GHG emissions coefficient for road travel               / 0.01 /
et       GHG emissions coefficient for public transit            / 0.002 /
eq       GHG emissions coefficient for residences                / 0.001 /
g        damage coefficient for GHG emissions                    / 2 /
* Parameters for model functions (specific to assumed functional forms)
rccoef   road travel variable user cost coefficient              / 0.003 /
rcexpN   road travel variable user cost exponent on Nr(i)        / 1.8 /
rcexpR   road travel variable user cost exponent (-) on R(i)     / 0.2 /
lucoef   land component of utility coefficient                   / 3 /
luconv   land unit conversion for utility and energy             / 250 /
becoef   building energy consumption coefficient                 / 2 /
beexp    building energy consumption exponent                    / 0.5 /
;

Variables
U        common household utility level (objective that the planner maximizes);

Positive Variables
* Fundamental model variables
Nr(i)    number of households in zone i who travel by road
Nt(i)    number of households in zone i who travel by public transit
C(i)     non-land consumption by each household in zone i
R(i)     road capacity added for zone i
E        total urban area GHG emissions
* Variables included for convenience to specify functions of the model
V(i)     land component of the utility function in zone i
B(i)     building energy consumption of each household in zone i
T(i)     road transportation variable user cost in zone i
;

Equations
* Fundamental model equations
population       total urban area population constraint
utility(i)       defines utility and ensures spatial equilibrium in utility
budget           budget constraint
emissions        computes total urban area GHG emissions
* Equations included for convenience to specify function forms for the model
landutility(i)           land component of the utility function
buildingenergy(i)        building energy consumption function
roadcost(i)              road transportation variable user cost function
;

* Fundamental model equations
population..     sum(i, Nr(i) + Nt(i)) =e= n;

utility(i)..     V(i) + C(i) - g*E =e= U;

budget.. sum(i, (Nr(i) + Nt(i))*C(i) + x(i)*(Nr(i)*T(i) + rr*R(i) + (s + p)*Nt(i))) =l= bb;

emissions.. sum(i, x(i)*(er*Nr(i) + et*Nt(i)) + eq*(Nr(i) + Nt(i))*B(i)) =e= E;

* Equations included for convenience to specify functional forms
landutility(i).. V(i) =e= lucoef*log((1 + luconv*a(i)/(Nr(i) + Nt(i))));

buildingenergy(i).. B(i) =e= becoef * (1 + luconv*a(i)/(Nr(i) + Nt(i)))**beexp;

roadcost(i)..    T(i) =e= rccoef * Nr(i)**rcexpN * (1 / (R(i)**rcexpR));


Model planning / all /;

* Set small lower bounds on some variables to avoid zero-related errors
Nr.lo(i) = 0.000001;
Nt.lo(i) = 0.000001;
R.lo(i) = 0.000001;
* Choose some initial values to help the solver
Nr.l(i) = 1;
Nt.l(i) = 1;
C.l(i) = 10;

Solve planning using NLP maximizing U;

* Generate an output file containing all model outputs
execute_unload 'urban_climate_mitigation_results.gdx';


