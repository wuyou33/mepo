
$ontext

!!!!!!!!!!!   UNFINISHED  !!!!!!!!!!

----------------------------------------------------
ROLLING Flexible Unit Commitment Model
----------------------------------------------------
  Highly Configurable Electric power system operations model
  
Model formulation based on the formulation described in:
 Palmintier, B., & Webster, M. (???). Efficient Long-Term Unit Commitment. In Preparation for IEEE Transactions on Power Systems


 Command Line Options (defaults shown):
 ======================================
 Data
  Primary data setup file:
   --sys=test_sys.inc     System parameters include file. This file references all data for a model
                          run. Typically single value data such as: cost of carbon, WACC, etc. are
                          included directly, while larger tables are in separate sub-include files.
                          The standard sub-include files are:
                              fuel.inc      Fuel names, prices, and emissions
                              gens.inc      Generator set, operating parameters, and availability
                              demand.inc    Demand block set, duration, and power levels

  Files used to override values set or referenced in sys and sub-includes (assumed to to be
  located in data_dir, except as noted):
   --fuel=(from sys)     Fuel prices and emissions
   --gens=(from sys)     Generation set & tables of parameters & availability/renewable output.
   --gparams=(OPTIONAL from sys)    Default generator parameters to use for any missing values.
   --avail=(from sys)    Generation availability/renewable output
   --demand=(from sys)   Demand include file that defines demand blocks, levels, and duration
   --update=NONE         An optional final include file to override selected settings from other
                          include files. Does not override any explicit command-line values. The
                          path for update file is relative to the model (not data_dir). 
                          IMPORTANT: the update file works in S space, so most parameters must 
                          be indexed by S and you must use the scenario dependent 
                          parameters: pFuel, pDemand, pGen, and pGenAvail. Changes to the 
                          p*Data parameters (pGenData, pDemandData, etc) will NOT be used.
   --scen=NONE           For multiple scenario problems (multi-period or stochastic) specifies
                          the list of scenarios (populates the S set) and their associated
                          weight/probability table, pScenWeight(S).


  Specific Value Overrides (take precedence over all values defined in data files. Use for
  sensitivity analysis, etc.) IMPORTANT, these values are used for ALL scenarios, use an update
  for changing these on a by scenario basis.
   --co2cost=#            Cost of CO2 in $/t-co2e          (default: use sys or update value)
   --demscale=#           Factor to uniformly scale demand (default: use sys or update value)
   --rps=#                Renewable Portfolio Standard     (default: use sys or update value)
   --co2cap=#             Carbon Emission Cap (Mt-co2e)    (default: use sys or update value)

  Model Setup Flags (by default these are not set. Set to any number, including zero, to enable)
   --obj_var=vOpsCost     Variable to minimize in solution. In scenario mode (stochastic UC, 
                            multi-period planning, etc.) The weighted sum across scenarios of
                            this value is used Common options:
                             vOpsCost  (default) Least cost operations
                             vCarbonEmissions  Use with no_nse=1 to find minimum possible co2
                            Technical Note: Any variable indexed by S can be used
   --startup=(off)        Compute startup costs (also enables unit_commit)   (default: ignore)
   --unit_commit=on       Compute unit commitment constraints   (default: use UC constraints --
                           Note: different default from other AdvPower models. When used as
                           as sub-model, the callers value is used instead)
   --ramp=(off)           Flag to limit inter period ramp rates  (default: ignore)
   --ignore_integer=(off) Flag to ignore integer constraints in Unit Commitment if enabled (unit is
                           either committed or not) (default: use integer constraints)
   --avg_avail=(off)      Flag to use the average rather than time dependent availabilities. Using
                           averages is OK for thermal units, but highly simplifies time varying
                           renewables. This simplification is made in the analytic version of the
                           model, but not generally a good idea for numeric estimates. (default: use
                           complete time varying information.)
   --uc_ignore_unit_min=(0)   Threshold for unit_min to ignore All (even continuos) commitment 
                            decisions & constraints. Gens with unit_min less than or equal to 
                            this value will not have commitment variables and use LP 
                            formulations for equations from dispatch. Use uc_int_unit_min for
                            a better approach.
   --uc_int_unit_min=(0)   Threshold for unit_min to ignore INTEGER commitment 
                            decisions & constraints. Gens with unit_min less than or equal to 
                            this value will still have commitment variables, but their valid
                            range is relaxed to be continous. The same equations are used
                            as for those units with integer constraints.
   --rsrv=(none)  Specify Type of reserve calculation. Options are:
        =separate  Enforce separate reserve requirements based on "classic" ancillary
                    services plus additions for renewable uncertainty. This includes Reg Up, 
                    Reg Down, Spin Up, & Quick Start
        =flex      Use combined "flexibility" reserves grouped simply into flex up and flex down
        =both      Compute both separate and flexibility reserves
        =(none)    If not set, no reserve limits are computed
   --no_nse=(off)         Don't allow non-served energy
   --force_renewables=(off) Force all renewable output to be used. This is only feasible until
                           the point where load and op_reserves dictate a max. (until we add storage).
                           When used with cap_fix, it is a bit more widely useful b/c we can limit
                           output to the level of demand. (this is NLP when capacity is a decision)
   --max_start=(off)      Enforce maximum number of startups   (default: ignore)
   --basic_pmin=(off)     Enforce non-UC based minimum output levels for each generator type. 
                           This can be useful for baseload plants with simple (non-UC) operations.
   --pwl_cost=(off)     Use piecewise linear cost (fuel consumption) for generators with 
                           segments defined (in a pGenHrSegments (G, PWL_COEF, HR_SEG) table)
                           other generators use the standard afine approximation defined in 
                           pGen(G, GENA_PARAMS). The default afine approximation defines
                           a linear+offset fuel use using zero power fuel (p0_fuel) and a 
                           constant heat rate (heatrate). (default: use
                           afine approx for all generators)
   --p0_recover=0.85    For units not under unit commitment constraints, a zero intercept fuel
                           curve is used by distributing the p0_fuel (or intercept for 
                           piecewise linear units) across the output range using an adjusted 
                           (higher) heatrate. The p0_recover parameter specifies the power 
                           output level used for full recovery. A value of less than 1.0 is 
                           recommended, otherwise, the linear fit would be universally too low,
                           providing an unfair efficiency bonus for non-UC units. (default 85%)
   --pwl2afine=(off)    Overwrite the heatrate & p0_fuel values in the generator table 
                           pGen with the steepest (least efficient, last) piecewise linear
                           segment. This option can provide better matches to pwl runs when
                           the data is available.
   --min_up_down=(off)  Enforce minimum up and down time constraints (default: ignore)
   --force_gen_size=(off) Force all plant sizes to equal the specified value (in MW)
   --min_gen_size=(off)   Force small plant sizes to be larger than specified value (in MW)

  Additional Model Components & Related
   --calc_water=(off)     Compute water use and limits
         Related options (see shared_dir/WaterEquations for complete details)
           --h2o_limit=(Inf)     System wide maximum water use [Tgal]. Only computed for gens
                                  with specified water usage (h2o_withdraw_var)
           --h2o_cost=(0)        System wide water cost [$/kgal]. Only computed for gens
                                  with specified water usage (h2o_withdraw_var)


  Solver Options
   --max_solve_time=10800  Maximum number of seconds to let the solver run. (Default = 3hrs)
   --mip_gap=0.001         Max MIP gap to treat as valid solution (Default = 0.1%)
   --par_threads=1         Number of parallel threads to use. Specify 0 to use one thread per
                             core (Default = use 1 core)
   --par_mode=1            CPLEX parallel mode 1=deterministic & repeatable, 0=automatic,
                            -1=Opportunistic, but not repeatable (Default = determinstic)
   --lp_method=4           CPLEX code for lp_method to use for pure root node, LP, RMIP, and 
                             final MIP solve.  Options: 0=automatic, 2=Dual Simplex, 4=barrier,
                             6=concurrent (a race between dual simplex and barrier in parallel)
                             (Default = 4, barrier) Use 6 if running in parallel
   --cheat=(off)           use epsilon-optimal branch & bound by removing solutions that are
                            not "cheat" better than the current best. This can speed up the 
                            MIP search, but may miss the true optimal solution. Note that this
                            value is specified in absolute terms of the objective function.
   --rel_cheat=(off)       Similar to cheat, but specified in relative percentage of objective
                            this works in CPLEX only

  File Locations (Note, on Windows & DOS, \'s are used for defaults)
   --data_dir=../data/     Relative path to data file includes
   --out_dir=out/          Relative path to output csv files
   --util_dir=../util/     Relative path to csv printing and other utilities
   --shared_dir=../shared/ Relative path to shared model components
   --out_prefix=UC_        Prefix for all our our output data files
   
  Output Control Flags (by default these are not set. Set to any number, including zero, to enable)
   --debug=(off)           Print out extra material in the *.lst file (timing, variables, 
                            equations, etc)
   --debug_avail=(off)    Display full availability table in *.lst file for debugging
   --no_csv=(off)         Flag to suppress creation of csv output files (default: create csv output)
   --summary_only=(off)   Only create output summary data (default: create additional tables)
   --summary_and_power_only=(off)   Create only summary & power table outputs (Default: all files)
   --out_gen_params=(off) Create output file listing generator parameter input data (Default: skip)
   --out_gen_avail=(off)  Create output file listing generator availability input data (Default: skip)
   --memo=(none)          Free-form text field added to the summary table NO COMMAS (Default: none)
   --gdx=(off)            Export the entire solved model to a gdx file in the out_dir (Default: no gdx file)

  Supports:
    - multiple operations model modes:
        + simple economic dispatch
        + ramp (up & down) constrained economic dispatch
        + integer unit commitment:
           - minimum output for committed generators
           - startup costs (optional)
           - ramp (up & down) constraints (optional)
    - arbitrary number of generation technologies/units with
        + availability factors (separate from capacity credit, see below)
        + minimum power for baseload units
        + technology specific operating reserve capabilities
    - features designed explicitly for proper wind support:
        + RPS (minimum wind energy penetration %)
        + time varying wind availability/output
    - (optional) endogenous operating reserves during each time block (hourly for 8760) including:
        + Spinning Reserves
        + Quick Start Reserves (effectively non-spin)
        + Regulation Up & Down
    - arbitrary number of demand blocks of varying duration
    - heat rates + separate fuel costs for easy scenario analysis
    - carbon intensity
       + imbedded carbon from construction
       + carbon content of fuels
    - carbon constraint (carbon cap)
    - carbon tax
    - non-served energy
    - Arbitrary Scenarios (using set S), only weighted sum of costs is implemented here, 
      calling model needs to handle any additional constraints. Scenarios enabled for all
      parameters EXCEPT: piecewise linear segments, and (most) generator technical constraints 
      (specifically those that affect subsets G_UC, G_RPS, G_RAMP, G_UC_INT, etc). 

Outputs
    - Summary, Power, Commitment, #startups, emissions, wind shedding, cost breakdown.


Additional Features:
    - loading of data from include files to allow an unchanging core model.
        - These file names can be optionally specified at the command line.
    - A final, optional "update" file to allow for adjusting parameters for easy sensitivity
      analysis or to change the values for a model run without changing the default values
    - internal annualizing of capital costs (requires definition of WACC)
    - ability to scale demand
    - ability to ignore integer constraints
    - Force wind mode to require using all wind production with no shedding (only valid for small %wind)

Performance enhancements:
    - ignores unit commitment for plants with no/low unit minimum output such as renewables and
      peakers. This threshold is tunable with --unit_min

Assumptions:
    - Ramping and Startup "loop" such that the state at the endo of the year must match the
      beginning of year. This prevents turning off baseload in anticipation of the "end of the world"


ToDo:
    * Decouple ops into blocks for faster UC?
    * Add hydro
    * Add stochasticity
    - quadratic or affine (linear+offset) heat rate curves for different plants in group
    - replace put2csv with rutherford's equivalent?
    - add min up/down times
    - compute fixed and var cost by gen
    - compute required market based incentives to achieve same results
    - expand in-line comments for equations
    - automatic scaling of demand blocks based on year, baseline, & growth rate
    - Add load following reserves
    - Separate reserves as a function of wind, load ramps, etc.
    - setup solution in a loop with initial start to allow saving of intermediate solutions?
    ? initial guess for some integer constraints

  Originally Coded in GAMS by:
   Bryan Palmintier, MIT
   March 2010

 Version History
Ver   Date       Time  Who            What
---  ----------  ----- -------------- ---------------------------------
  1  2011-03-07  20:26  bpalmintier   Adapted from UnitCommit v34
  2  2012-09-02  17:08  bpalmintier   Replace all $set with $setglobal (to prevent scope errors)
-----------------------------------------------------
$offtext

*================================*
*             Setup              *
*================================*

* First define the shared directory

* ======  Platform Specific Adjustments
* Setup the file separator to use for relative pathnames
$iftheni %system.filesys% == DOS $setglobal filesep "\"
$elseifi %system.filesys% == MS95 $setglobal filesep "\"
$elseifi %system.filesys% == MSNT $setglobal filesep "\"
$else $setglobal filesep "/"
$endif

* By default look for shared components in sibling directory "shared"
$if not set shared_dir $setglobal shared_dir ..%filesep%shared%filesep%

* Enable $ variables from include file to propagate back to this master file
$onglobal

* Include common setup definitions including:
*  -- Platform specific path adjustments
*  -- GAMS options
*  -- debug settings
*  -- standardized AdvPower directories
$include %shared_dir%AdvPwrSetup

* Disable influence of $ settings from include files
$offglobal


* ======  Additional setup
* == Identify if we are the master calling model
$ifthen.we_are_main NOT set model_name 
*Establish the title
$Title "Rolling Unit Commitment Model"
*If so set it
$setglobal model_name RollingUC
*In this case, we also know the capacity is fixed so skip all of the capacity expansion terms
$setglobal fix_cap
*And we want to default to using unit-commitment
$if not set unit_commit $setglobal unit_commit on

* == And we want to identify whether or not we are using a mixed integer solution
$ifthen.mip set ignore_integer
$setglobal use_mip no
$else.mip
$setglobal use_mip yes
$endif.mip

$endif.we_are_main

* == Setup short hand alias for total capacity to use as a control variable
$ifthen set fix_cap
$setglobal capacity_G pGen(G,'cap_cur', S) 
$else
$setglobal capacity_G vCapInUse(G, S) 
$endif

* Setup output prefix
$if NOT set out_prefix $setglobal out_prefix RollUC_

*================================*
*          Loop Setup            *
*================================*

* Enable control over which demand periods are included in each solve
* By not setting d_start and d_end, D_SIM will initialize to empty
$setglobal d_subset on

*================================*
*         Declarations           *
*================================*
* ======  Declare all sets so can use in equations
* Note: be sure to quote descriptions otherwise "/" can not be used in a description.

sets

* Sets for data, actual definitions can be found in include files
    D           "all demand periods"
    D_SIM(D)    "demand periods used in simulation"

* Sets to control looping
    ITER        "Rolling UC iteration counter"
*ToDo: use macro? to set number of iterations
        /i1*i10/
    ;


*================================*
*       Main Rolling Loop        *
*================================*

loop (ITER) do
    
endloop


$terminate

*================================*
*         Declarations           *
*================================*

* ======  Declare all sets so can use in equations
* Note: be sure to quote descriptions otherwise "/" can not be used in a description.

sets
* Sets for table parameters

    DEM_PARAMS  "demand block table parameters from load duration curve"
        /
         dur         "duration of block                 [hrs]"
         power       "average power demand during block [GW]"
        /

    GEN_PARAMS  "generation table parameters"
       /
        c_var_om    "variable O&M cost                           [$/MWh]"
        c_fix_om    "fixed O&M cost                              [M$/GW-yr]"
        heatrate    "heatrate for generator (inverse efficiency) [MMBTU/MWh = BTUe9/GWh]"
        p0_fuel     "fuel use at zero power out (heatrate intercept) [BTUe9/hr]"
        fuel        "name of fuel used                           [name]"
        cap_cur     "Current installed capacity for generation   [GW]"
        co2_ccs     "Fraction of carbon capture & sequestration  [p.u.]"
        co2_embed   "CO2_eq emissions from plant construction    [Mt/GW]"
        p_min       "minimum power output (for baseload)         [p.u.]"
        gen_size    "typical discrete plant size                   [GW]"
        ramp_max    "Maximum hourly ramp rate                    [fract/hr]"
        unit_min    "Minimum power output per committed unit     [GW]"
        c_start_fix "Fixed cost to start up a unit               [K$/start]"
        fuel_start  "Fuel usage to start up a unit               [BTUe9/start]"
        quick_start "Fraction of capacity avail for non-spin reserves [p.u.]"
        reg_up      "Fraction of capacity avail for regulation up reserves [p.u.]"
        reg_down    "Fraction of capacity avail for regulation down reserves [p.u.]"
        spin_rsv    "Fraction of capacity avail for spinning reserves [p.u.]"
        max_start   "Maximum number of startups per plant per year [starts/unit/yr]"
        max_cap_fact "Maximum capacity factor, use for maintanence [p.u.]"
        derate       "Derating factor for simple (non-reserves) cap planning [p.u.]"
       /

    FUEL_PARAMS "fuel table parameters"
        /
         name        "The name as a string (acronym) for comparison  [name]"
         cost        "Unit fuel cost                                 [$/MMBTU = $K/BTUe9]"
         co2         "Carbon Dioxide (eq) emitted                    [t/MMBTU = Kt/BTUe9]"
        /

* Sets for data, actual definitions can be found in include files
    G           "generation types (or generator list)"
        /
         wind
        /
    D           "all demand periods"
    D_SIM(D)    "demand periods used in simulation"
    F           "fuel types"
    S           "scenarios for multi-period and stochastic problems"

* Sets associated with piecewise linear cost (fuel) functions
        HR_SEG       "piece-wise linear fuel use segments (slope=heatrate)"
*      (Note only define the first segment here, assume other segs defined in data files as needed
                /seg1/ 

        PWL_COEF    "Coefficients for piecewise linear representation"
                /
                 slope
                 intercept
                /


* Sets for mapping between other sets
    GEN_FUEL_MAP(G, F)     "map for generator fuel types"

* Subsets for special purposes
    G_UC(G)       "Generators to compute continuous or discrete unit commitment state and constraints"
    G_UC_INT(G)   "Generators with integer on/off values for unit commitment"
    G_RPS(G)      "Generators included in the Renewable Portfolio Standard"
    G_WIND(G)     "Wind generators (for reserve requirements)"
    G_RAMP(G)     "Generators for which to enforce ramping limits"
    G_PWL_COST(G) "Generators for which to use multi-segment piecewise linear fuel use"
    PWL_COST_SEG(G, HR_SEG) "Valid piece-wise linear segments"

* ======  Declare the data parameters. Actual data imported from include files
parameters
* Data Tables
    pDemand    (D, DEM_PARAMS, S)   "table of demand data"
    pGen       (G, GEN_PARAMS, S)   "table of generator data"
    pGenAvail  (D, G, S)            "table of time dependent generator availability"
    pFuel      (F, FUEL_PARAMS, S)  "table of fuel data"
$ifthen set pwl_cost
    pGenHrSegments(G, HR_SEG, PWL_COEF)    "Piecewise Linear Fuel use Table (slope=heatrate)"
$endif

* Additional Parameters
   pScenWeight(S)     "Scenario weighting for cost calcs. Use for probability or time discounting"

   pCostCO2     (S)     "cost of carbon (in terms of CO2 equivalent)                         [$/t-CO2eq = M$/Mt]"
   pRPS         (S)     "fraction of energy from wind                                        [p.u.]"
   pCarbonCap   (S)     "max annual CO2 emissions                                            [Mt CO2e]"
   pDemandScale (S)     "factor by which to scale demand"
   pFractionOfYear(S)   "fraction of year covered by the simulation"

   pMaxNumPlants(G, S)  "upper bound on number of plants for unit commitment"

scalars
   pWACC             "weighted average cost of capital (utility investment discount rate) [p.u.]"
   pPriceNonServed     "Cost of non-served energy                                           [$/MWh]"

* ======  Declare Variables
variables
   vObjective  "Objective: scenario weighted average (EV or discounted ops cost)  [M$]"
   vTotalCost      (S)          "total system cost for scenario               [M$]"
   vOpsCost        (S)          "system operations cost in target year        [M$]"
   vFixedOMCost    (S)          "fixed O&M costs in target year               [M$]"
   vVariableOMCost (S)          "variable O&M costs in target year            [M$]"
   vFuelCost       (S)          "total fuel costs in target year              [M$]"
   vCarbonCost     (S)          "cost of all carbon emissions                 [M$]"

$ifthen set startup
   vStartupCost    (S)          "total startup (fixed) costs, not including fuel & carbon [M$]"
$endif
$ifthen not set no_nse
    vNonServedCost (S)          "total cost of non-served energy              [M$]"
$endif
   vCarbonEmissions(G, S)          "carbon from operations + fraction embedded   [Mt-CO2e]"

* Specify integer variables. If ignore_integer flag is specified these are treated as continous by
* GAMS by using the RMIP solution type.
integer variables
   vUCInt(D,G,S)         "integer match to vUnitCommit for members of G_INT_UC [integer]"

positive variables
   vUnitCommit(D, G, S)  "number of units of each gen type on-line during period     [continuous]"
* Note that even though the startup&shutdown variables will only take integer values, we can treat
* them as continuous because the unit commitment constraint (eState) will only return integer results
* since vUnitCommit is integer. This trick reduces the number binary variables and converts part of
* the otherwise complex integer tree to a larger and fast to solve LP
   vStartUp  (D, G, S)   "number of units of each type that starts up during each period  [integer]"
   vShutDown (D, G, S)   "number of units of each type that shuts down during each period  [integer]"
   ;

positive variables
   vInstantFuel(D, G, S) "instantaneous fuel use by gen per period [BTUe9/hr]"
   vFuelUse  (F, G, S)   "fuel usage by generator & type           [BTUe12]"
   vPwrOut   (D, G, S)   "production of the unit                   [GW]"
   vNonServed(D   , S)   "non-served demand                        [GW]"
   ;

* ======  Declare Equations
equations
$ifthen %model_name% == UnitCommit
   eObjective  "Objective function: scenario weighted average (EV or discounted ops cost)  [M$]"
   eTotalCost  (S)     "total cost = ops                             [M$]"
$endif
   eOpsCost    (S)     "system operations cost for one year of operation  [M$]"
   eFixedOMCost(S)     "system fixed O&Mcosts for one year           [M$]"
   eVarOMCost  (S)     "system variable O&M costs for one year       [M$]"
   eFuelCost   (S)     "system fuel costs for one year               [M$]"
   eCarbonCost (S)     "cost of all carbon emissions                 [M$]"
$ifthen set startup
   eStartupCost(S)      "compute syste-wide unit startup costs                        [M$]"
$endif
$ifthen not set no_nse
   eNonServedCost (S)          "total cost of non-served energy              [M$]"
$endif

   eCarbonEmissions(G, S) "carbon from operations + fraction embedded   [Mt-CO2e]"
   eInstantFuelByGen (D, G, S) "fuel use by gen and demand period       [BTUe9/hr]"
$ifthen set pwl_cost
    ePiecewiseFuelByGen (D, G, HR_SEG, S) "fuel use for gens with piecewise fuel use [BTUe9/hr]"
$endif
   eFuelUse (F, G, S)      "fuel usage by type                           [quad = BTUe15]"

$ifthen NOT set rsrv
   ePwrMax   (D, G, S)  "output w/o reserves lower than available max       [GW]"
   ePwrMin   (D, G, S)  "output w/o reserves greater than installed min     [GW]"
   ePwrMaxUC (D, G, S)  "output w/o reserves lower than committed max       [GW]"
   ePwrMinUC (D, G, S)  "output w/o reserves greater than committed min     [GW]"
$endif

   eDemand   (D   , S)  "output must equal demand                           [GW]"

   eRPS      (S)        "RPS Standard: minimum energy percent from renewables     [p.u.]"
   eCarbonCap(S)        "Limit total emissions                                    [Mt-CO2e]"

$ifthen set force_renewables
$if set fix_cap   eForceRenewables (D, S) "force the use of all renewable output (up to 100% of load) [GW]"
$if not set fix_cap   eForceRenewables (D, G, S) "force the use of all renewable output (up to 100% of load) [GW]"
$endif

$ifthen set ramp
   eRampUpLimitUC  (D, G, S)     "Limit period to period ramp up rates for integer commited plants"
   eRampDownLimitUC(D, G, S)     "Limit period to period ramp down for integer commited plants"
   eRampUpLimit    (D, G, S)     "Limit period to period ramp up rates"
   eRampDownLimit  (D, G, S)     "Limit period to period ramp down rates"
$endif

   eUnitCommit(D, G, S)  "can only commit up to the installed number of units     [continous]"
$ifthen not set uc_lp
*(possibly) Mixed Integer Equations
   eUnitCommitInteger(D, G, S) "Integerization for unit commitment"
$endif

$ifthen set compute_state
   eState     (D, G, S)  "compute unit commitment startup and shutdowns           [integer]"
$endif

$ifthen set max_start
   eMaxStart(G, S)       "enforce maximum number of startups per year             [start/yr]"
$endif
   ;

*================================*
*  Additional Model Formulation  *
*================================*
* Note: this must be included between declarations & equations so that the included file 
* has access to our declarations, and any objective function additions can be used.

* Enable $ variables from included model(s) to propagate back to this master file
$onglobal

* Include Planning Margin if required & we are the main function (CapPlan models include
* these equations directly
$if %model_name%==UnitCommit $if set plan_margin $include %shared_dir%PlanMarginEquations

* Include Reserve constraints if required
$if set rsrv $include %shared_dir%ReserveEquations

* Include Minimum Up and Down time formulation if required
$if set min_up_down $include %shared_dir%MinUpDownEquations

* Include water limiting equations and associated parameters and variables
$if set calc_water $include %shared_dir%WaterEquations

* Disable influence of $ settings from sub-models
$offglobal

*================================*
*       The Actual Model         *
*================================*
*====== objective function and components

* == Objective (eObjective)
*
* The standard objective is total cost (see below for alternative objective options). We use
* our definition of this equation whenever we are the main model. Otherwise we expect our caller
* to define a similar objective function.
* 
$ifthen.we_are_main   %model_name% == UnitCommit
$if not set obj_var $setglobal obj_var vOpsCost

eObjective  ..  vObjective =e= sum[(S), pScenWeight(S) * %obj_var%(S)];

* Allows uniform use of total cost for both operations and planning models
eTotalCost (S)  ..  vTotalCost (S) =e= vOpsCost (S);

$endif.we_are_main

* == Operations Cost (eOpsCost)
* In this equation, A number of terms are always included:
*     -- fixed O&M cost
*     -- variable O&M costs
*     -- Fuel Costs
*     -- Carbon Costs
* In addition, other terms are added if needed based on command-line settings:
*     -- Startup Costs
*     -- Non served energy costs
*     -- Water costs
*
* Units:
*  all M$ unless otherwise noted
eOpsCost(S)    .. vOpsCost(S) =e= vFixedOMCost(S) 
                                + vVariableOMCost(S) 
                                + vFuelCost(S) 
                                + vCarbonCost(S)
$ifthen set startup
                                + vStartupCost(S)
$endif
$ifthen not set no_nse
                                + vNonServedCost(S)
$endif
$ifthen set calc_water
* Note scaling from Mgal (vH2oWithdrawPerGen) to kgal (pH2oCost), and usd (pH20Cost) to Musd (totals)
                                + sum[ (G_H2O_LIMIT), vH2oWithdrawPerGen(G_H2O_LIMIT, S) * pH2oCost(S) /1e3 ]
$endif
                                ;


* == Fixed Operations and Maintence Costs (eFixedOMCost)
*
* Units & Scaling:
*   1x      c_fix_om        M$/GW-yr
eFixedOMCost(S)  .. vFixedOMCost(S) =e= sum[(  G), pGen(G,'c_fix_om', S)*(%capacity_G%)]
                                            * pFractionOfYear(S);

* == Variable Operations and Maintence Costs (eVarOMCost)
*
* Units & Scaling:          external    this eq.
*   1000x   vVarOMCost      M$          k$
*   1x      c_var_om        $/MWh   to  k$/GWh
*   1x      vPwrOut         GW
*   1x      Demand(dur)     hr
eVarOMCost(S)    .. vVariableOMCost(S)*1e3 =e= sum[(D_SIM, G), pGen(G,'c_var_om', S)*vPwrOut(D_SIM, G, S)*pDemand(D_SIM, 'dur', S)];


* == Total Fuel Costs (eFuelCost)
*
* Units & Scaling:          external    this eq.
*   1x      vFuelCost       M$      to  M$
*   1x      Fuel(cost)      $/MMBTU to  M$/BTUe12
*   1x      vFuelUse        BTUe12
eFuelCost(S)     .. vFuelCost(S) =e= sum[(GEN_FUEL_MAP(G,F)), pFuel(F,'cost', S)*vFuelUse(F, G, S)];


* == Carbon Emision Costs (eCarbonCost)
*carbon cost =  carbon price * carbon emissions
* Units & Scaling:          external    this eq.
*   1x      vCarbonCost     M$
*   1x      pCostCO2        $/t     to  M$/MT
*   1x      vCarbonEmmit    kT
eCarbonCost(S)   .. vCarbonCost(S) =e= pCostCO2(S) * sum[(G), vCarbonEmissions(G,S)];


* == Startup Costs (eStartupCost)
* Includes only fixed costs for startup. Costs associated with startup fuel use is captured
* as part of the total fuel use by generator. Hence startup fuel and carbon costs are computed
* as part of fuel and carbon costs respectively
*
* Units & Scaling:              external            this eq.
*   1000x   vStartCost          Musd        to      Kusd
*   1x      c_start_fix         Kusd/start
$ifthen set startup
    eStartupCost(S)  .. vStartupCost(S)*1e3 =e= 
                            sum[(D_SIM,G_UC), 
                                vStartup(D_SIM, G_UC, S) 
                                    * ( pGen(G_UC, 'c_start_fix', S) )
                               ];
*Note: fuel use included elsewhere
$endif

* == Total non-served energy costs (eNonServedCost)
* Units & Scaling:             external    this eq.
*   1x      vNonServedCost      M$
*   1/1000x PriceNonServe       $/MWh   to  M$/GWh
*   1x      vNonServed          GWh

$ifthen not set no_nse
    eNonServedCost(S) .. vNonServedCost(S) =e=
                                sum[(D_SIM), vNonServed(D_SIM, S)*pPriceNonServed*pDemand(D_SIM, 'dur', S)]/1e3;
$endif

*====== Intermediate Calculations

* == Carbon Emissions (eCarbonEmissions) by generator
* carbon emissions (Mt) = (fuel use - ccs) * carbon intensity + embedded carbon * new capacity
*
* Notes: 
*  -- we assume that the CCS system is operational during startup and apply ccs rate to
*      all fuel usage
*
* Units & Scaling:      external        this eq.
*   1x      pFuel(co2)      t/MMBTU     to  Mt/BTUe12
*   1x      vCarbonEm       Mt
*   1x      vFuelUse        BTUe12
*   1x      vNewCapacity    GW
*   1x      co2_embed       Mt/GW
eCarbonEmissions(G, S)   .. vCarbonEmissions(G, S) =e= 
                                sum[(GEN_FUEL_MAP(G,F)), 
                                    vFuelUse(F,G,S) *pFuel(F,'co2', S)*(1-pGen(G,'co2_ccs', S))
                                   ]
$ifthen not set fix_cap
                                + vNewCapacity(G, S)*pGen(G,'co2_embed', S)
$endif
                            ;

                                           
* == Fuel Consumption by generator for each period (eInstantFuelByGen)
* This equation implements an afine approximation (linear + intercept) for fuel use as a
* function of power output. This equation is suppressed and replaced with multiple heatrate 
* segments for generators with piece-wise linear fuel use.
*
* Units & Scaling:      external        this eq.
*   1x  vInstantFuel    BTUe9/hr    to  BTUe9/hr
*   1x  heatrate        MMBTU/MWh   to  BTUe9/GWh
*   1x  p0_fuel         BTUe9/hr
*   1x  vPwrOut         GW
*   1x  vUnitCommit     integer (no units)
eInstantFuelByGen(D, G, S)$( D_SIM(D)
                             and (pGen(G,'gen_size', S) > 0 and not G_PWL_COST(G)) ) .. 
    vInstantFuel(D, G, S) =e= pGen(G,'heatrate', S)*vPwrOut(D,G,S)
                            + pGen(G, 'p0_fuel', S)*vUnitCommit(D,G,S)$G_UC(G)
* For units not under unit commitment, divide up the p0 fuel usage such that it is fully 
* accounted for at the p0_recover output level (typically 85%).
                            + pGen(G, 'p0_fuel', S)/pGen(G,'gen_size', S)/%p0_recover%
                                *vPwrOut(D,G,S)$(not G_UC(G)) 
                            ;
$ifthen set pwl_cost
* Units & Scaling:      external        this eq.
*   1x  vInstantFuel    BTUe9/hr    to  BTUe9/hr
*   1x  slope           MMBTU/MWh   to  BTUe9/GWh
*   1x  intercept       BTUe9/hr
*   1x  vPwrOut         GW
*   1x  vUnitCommit     integer (no units)
ePiecewiseFuelByGen (D, G, HR_SEG, S)$( D_SIM(D) 
                                        and ( PWL_COST_SEG(G, HR_SEG) and pGen(G,'gen_size', S) > 0) ) ..
    vInstantFuel(D, G, S) =g= pGenHrSegments (G, HR_SEG, 'slope')*vPwrOut(D,G,S)
                            + pGenHrSegments (G, HR_SEG, 'intercept')*vUnitCommit(D,G,S)$G_UC(G)
* For units not under unit commitment, divide up the p0 fuel usage such that it is fully 
* accounted for at the p0_recover output level (typically 85%).
                            + pGenHrSegments (G, HR_SEG, 'intercept')/pGen(G,'gen_size',S)/%p0_recover%
                                *vPwrOut(D,G,S)$(not G_UC(G)) 
                            ;
$endif

* == Total Fuel Consuption by Generator (eFuelUse)
* Includes both startup and instantaneous use
*
* Units & Scaling:          external        this eq.
*   1000x   vFuelUse        BTUe12      to  BTUe9
*   1x      vInstantFuel    BTUe9/hr
*   1x      Demand(dur)     hr
*   1x      fuel_start      BTUe9/start
eFuelUse(F,G,S)$(GEN_FUEL_MAP(G,F)) .. vFuelUse(F,G,S)*1000 =e= sum[(D_SIM), 
                                                vInstantFuel(D_SIM, G, S)*pDemand(D_SIM, 'dur', S)
$ifthen set startup
                                                + vStartup(D_SIM, G, S)$(G_UC(G)) * pGen(G, 'fuel_start', S)
$endif
                                            ];


*====== Constraints

* == Supply/Demand Balance (eDemand)
* It is important to use equality here, since we are interested in effects of minimum output limits, etc.
*
* Note: reserves are enforced in separate equations below
*
* Units & Scaling:      external        this eq.
*   all in GW
eDemand (D,S)$D_SIM(D)    .. sum[(G), vPwrOut(D, G,S)]
$ifthen not set no_nse
                    + vNonServed(D,S)
$endif
                    =e= pDemand(D,'power',S);


$ifthen.no_rsrv NOT set rsrv
*====== Generation output less than upper limit(s)
* Here we only worry about non-reserve limits. With reserves these equations will be
* replaced with expanded versions from the shared file AdvPwrReserves. Still there are
* multiple cases of interest:
*
* 1) Simplest (ePwrMax) is power out < installed capacity, with adjustments described below
* 2) For generation subject to unit commitment, things change slightly since we now only output
*    power up to the number of units that are turned on (ePwrMaxUC)
* Furthermore,  we might choose to derate the power output of the plant separately from 
* availability (typically for simple models), this can be done by taking the minimum of availability
* and the derate factor. Since both are parameters, this is a valid (MI)LP formulation. Note that
* this derating is already taken into account for in eUnitCommit for the UC equations.

* == Output must be below the generator upper limits (ePwrMax)
*Note: the $subset(setname) format only defines the equation for members of G that are also in G_UC
*Note: Availability is handled in eState for unit commitment constrained generators
*
* Units & Scaling:
*   vPwrOut & capacity      GW
*   derate & pGenAvail      p.u.
ePwrMax (D, G, S)$( D_SIM(D)
                    and (not G_UC(G)) ) .. 
                vPwrOut(D, G, S)  =l=  %capacity_G% * 
$ifthen set derate
                            min( pGen(G, 'derate', S),
$else
                            (
$endif
                              pGenAvail(D, G, S)
                            );


* == Output Upper Limit for UnitCommitment Gens (ePwrMaxUC)
*
* Units & Scaling:
*   vPwrOut & gen_size      GW
*   vUnitCommit             integer
ePwrMaxUC (D, G, S)$( D_SIM(D)
                      and G_UC(G)
                      and pGen(G, 'gen_size', S) ) .. 
                vUnitCommit(D,G,S) * pGen(G, 'gen_size', S) =g= vPwrOut(D, G, S);


*====== Generation output greater than lower limit(s)
* Here we find a complementary situation to the PwrMax equations described above
* (Still only included if no reserves defined)

* == Power greater than lower limits (ePwrMin)
* For simple models we might use a "technology minimum output" as a proxy for
* baseload plants. This lower limit is applied to entire generator category and is ignored by 
* using p_min=0 or not defining p_min (unspecified parameters default to zero).
*
* Units & Scaling:
*   vPwrOut & capacity      GW
*   p_min                   p.u.
ePwrMin (D, G, S)$D_SIM(D) ..   vPwrOut(D, G, S) =g= %capacity_G% * pGen(G,'p_min', S);


* == Power greater than lower limits for Unit Commitment (ePwrMinUC)
* Minimum power output for commitment generators under UC
*Note: the $subset(setname) format only defines the equation for members of G that are also in G_UC
*
* Units & Scaling:
*   vPwrOut & unit_min      GW
*   vUnitCOmmit             #units
ePwrMinUC (D, G, S)$( D_SIM(D)
                      and G_UC(G) )
                .. vPwrOut(D, G, S) =g= vUnitCommit(D,G,S) * pGen(G, 'unit_min',S);

$endif.no_rsrv


*======  Additional Constraints

* == Renewable Portfolio Standard (eRPS)
* renewable energy / total energy > RPS
*
* Units & Scaling:
*   vPwrOut         GW
*   Demand(dur)     hr
*   pRPS            p.u.
eRPS(S)        ..  sum[(D_SIM, G_RPS), vPwrOut(D_SIM, G_RPS,S)*pDemand(D_SIM, 'dur',S)] =g=
                       pRPS(S)*sum[(G, D_SIM), vPwrOut(D_SIM,G,S)*pDemand(D_SIM, 'dur', S)];


* == Carbon Limit (eCarbonCap)
* Units & Scaling:
*   all in Mt CO2(e)
eCarbonCap(S)  ..  sum[(G), vCarbonEmissions(G, S)] =l= pCarbonCap(S);


* == Force use of renewables if required (eForceRenewables)
*force the use of all renewable output (up to 100% of load)
$ifthen.force_re set force_renewables
$ifthen.fix_cap set fix_cap
* Units & Scaling:
*   vPwrOut, cap_cur, pDemand(power)        GW
*   pGenAvail                               p.u.
* If capacity if fixed, we can use minimum of available power and demand (both parameters)
   eForceRenewables(D, S)$(D_SIM(D)) .. sum[(G)$G_RPS(G), vPwrOut(D, G, S)] =e= 
                   min(  sum[(G)$G_RPS(G), pGen(G,'cap_cur', S)*pGenAvail(D,G,S)], pDemand(D, 'power', S) );
$else.fix_cap
* But if capacity is a decision variable, it is non-linear to use in the min, so we simply
* take all power. This will break if we have instant renewable power out > demand.
*
* Units & Scaling:
*   vPwrOut, cap_cur, vNewCapacity        GW
*   pGenAvail                               p.u.
   eForceRenewables(D, G, S)$( D_SIM(D)
                               and G_RPS(G) )
                .. vPwrOut(D, G, S) =e= 
                   (pGen(G,'cap_cur',S) + vNewCapacity(G,S)) * pGenAvail(D,G,S);
$endif.fix_cap
$endif.force_re


*======  Unit Commitment Constraints

* == Limit commitments to available capacity (eUnitCommit)
*Note: the $subset(setname) format only defines the equation for members of G that are also in G_UC
* Units & Scaling:
*   vUnitCommit             #units (# of gens)
*   gen_size                GW/unit
*   capacity_G              GW
*   pGenAvail, derate       p.u.
eUnitCommit(D,G,S)$( D_SIM(D) 
                     and G_UC(G) ) 
                .. vUnitCommit(D,G,S)
                    =l=  
                    %capacity_G% / pGen(G, 'gen_size',S) * 
$ifthen set derate
                    min( pGen(G, 'derate',S),
$else
                    (
$endif
                    pGenAvail(D, G, S)
                    );

* == Integerization for required gens (eUnitCommitInteger)
* This simple equation works since vUcInt is defined as an integer variable, and hence the
* otherwise continuous vUnitCommit will take on integer values as well for all members of the
* G_UC_INT subset. The redundant continuous variable should be removed during (MI)LP pre-solve
$ifthen not set uc_lp
   eUnitCommitInteger(D,G,S)$(D_SIM(D) and G_UC_INT(G) ) .. vUnitCommit(D,G,S) =e= vUcInt(D,G,S);
$endif

* == If startup costs or restrictions in use, compute startup & shutdowns (eState)
$ifthen set compute_state
*Note: the $subset(setname) format only defines the equation for members of G that are also in G_UC
   eState  (D,G,S)$(D_SIM(D) and G_UC(G))  .. vUnitCommit(D,G,S) =e= vUnitCommit(mDemShift(D,1),G,S) + vStartUp(D,G,S) - vShutDown(D,G,S);
$endif

* == Limit the total number of startups per generator group (eMaxStart)
* NOte: pGen(max_start) already scaled from starts/yr to starts/model_timeframe by AdvPwrDataRead
*
* Units & Scaling:
*   vStartUp        starts, summed over all demand periods.
*   gen_size        GW/unit
*   capacity_G      GW
*   max_start       starts/unit/model_duration
$ifthen set max_start
   eMaxStart(G,S)$( (pGen(G,'gen_size',S) > 0) and (pGen(G, 'max_start',S) < Inf) ) .. 
      sum[(D_SIM), vStartUp(D_SIM,G,S)] =l= %capacity_G% / pGen(G,'gen_size',S) * pGen(G, 'max_start',S);
$endif

*======  Ramping Constraints ======
$ifthen.ramp_eq set ramp

* ===== Ramping for Clusters
* In this case, we restrict ramping to the limits of plants that are on-line for both this period
* and last period + the unit minimums for any units that startup or shutdown. Using the unit
* minimums is logical for startup, but conservative for shutdown because it forces units to ramp
* down before shutting off. It is tempting to use gen_size of shutdowns for ramp down, but this
* is likely incorrect because the plant is probably not running at full output power.
*
* Note: this constraint is made trickier by our use of lumped integer commitment since we don't know
* output levels for individual units.

* == Upward Ramp Limits with Unit Commitment (eRampUpLimitUC)
* Use these integer based limits for technologies with integer unit_commitments
* For UC ramp-up = ramp rate for committed units + startups
*  with startups limited either by min_out or by ramp_rate for new units
*
* Note: We ignore demand block durations and impose this limit between blocks
*
* Units & Scaling:
*   vPwrOut, unit_min       GW
*   gen_size                GW/unit
*   ramp_max                p.u./hr
*   vUnitCommit, vStartup   #units

    eRampUpLimitUC(D,G,S)$( D_SIM(D)
                            and G_UC(G)
                            and G_RAMP(G) ) 
                    .. vPwrOut(D++1, G, S) - vPwrOut(D, G, S)
                        =l=
                        pGen(G, 'ramp_max', S)*pGen(G, 'gen_size', S)
                            * vUnitCommit(D,G,S)
                        + max(pGen(G, 'unit_min',S),
                            pGen(G, 'ramp_max',S)*pGen(G, 'gen_size',S)
                        )*vStartup(D++1,G,S);


* == Downward Ramp Limits with Unit Commitment (eRampDownLimitUC)
* For UC ramp-down = ramp rate for committed units + shutdowns
*  with shutdowns limited either by min_out or by ramp_rate for new units
*
* Note: We ignore demand block durations and impose this limit between blocks
*
* Units & Scaling:
*   vPwrOut, unit_min       GW
*   gen_size                GW/unit
*   ramp_max                p.u./hr
*   vUnitCommit, vShutDown  #units
    eRampDownLimitUC(D,G,S)$( D_SIM(D)
                              and G_UC(G)
                              and G_RAMP(G))
                    .. vPwrOut(mDemShift(D,1), G, S) - vPwrOut(D, G, S) =l=
                        pGen(G, 'ramp_max', S)*pGen(G, 'gen_size', S)
                            * vUnitCommit(mDemShift(D,1),G, S)
                        + max(pGen(G, 'unit_min', S),
                            pGen(G, 'ramp_max', S)*pGen(G, 'gen_size', S)
                          )*vShutDown(D,G,S);


* == Upward Ramp Limits for non-Unit-Commitment generators (eRampUpLimit)
* Use total capacity based limits for everything else
* Rather than using the De Jonghe, et al 2011 ramping formulation based on FlexUp and FlexDown
* we use explicit ramping limit relations. We do this b/c FlexUp and FlexDown try to capture
* flexibility _within_ the hour, rather than between hours as in ramping
*
* This equation replaces eq 14 in De Jonghe, et al 2011, Here we assume that "on-line" capacity
* does not contribute to ramping (its already on) and "off-line" capacity is limited either by
* its ramp limit (as is appropriate for any committed units not at their max, and any new starts)
* or by its quick start ability (as is appropriate for new starts of some plants)
*
* Note: We ignore demand block durations and impose this limit between blocks
*
* Units & Scaling:
*   vPwrOut, capacity       GW
*   ramp_max, quick_start   p.u./hr
*   pGenAvail               p.u.

    eRampUpLimit(D,G,S)$( D_SIM(D)
                          and G_RAMP(G)
                          and not G_UC(G) ) ..
                    vPwrOut(D++1, G, S) - vPwrOut(D, G, S) 
                    =l=
                    max(pGen(G, 'ramp_max', S), pGen(G, 'quick_start', S))
                      * ( %capacity_G% *pGenAvail(D, G, S) - vPwrOut(D, G, S));

* == Downward Ramp Limits for non-Unit-Commitment generators (eRampDownLimit)
* Likewise, this equation replaces eq 15 in De Jonghe, et al 2011. Here we assume "on-line" 
* capacity can be the only contributor to downward ramping, since you have to be running to 
* ramp down. This may need to change with storage
*
* Units & Scaling:
*   vPwrOut, capacity       GW
*   ramp_max                p.u./hr
*   pGenAvail               p.u.

    eRampDownLimit(D,G,S)$( D_SIM(D)
                            and G_RAMP(G)
                            and not G_UC(G) ) ..
                    vPwrOut(mDemShift(D,1), G, S) - vPwrOut(D, G, S)
                    =l=
                    pGen(G, 'ramp_max', S) * ( %capacity_G% *pGenAvail(mDemShift(D,1), G, S) - vPwrOut(mDemShift(D,1), G, S));
$endif.ramp_eq

*================================*
*        Handle The Data         *
*================================*

* Read in standard data file set & handle command-line overrides. Including
*  -- sys, gens, demand, fuel, & avail data
*  -- update file
*  -- command-line overrides including: demscale, rps, co2cost, co2cap
*  -- additional options including: force_gen_size, min_gen_size, basic_pmin, 
*      uc_ignore_unit_min, avg_avail
* Also computes sub-sets for G_UC, G_RPS, G_WIND, G_RAMP
$include %shared_dir%AdvPwrDataRead


* ====== Additional Calculations...

* == Identify generators for piecewise linear approximations
* Start by excluding all generators, which also sets thing properly for the non-pwl_cost case
G_PWL_COST(G) = no;
* Then if pwl_cost is set, we include any generator's that have a non-zero slope or intercept 
* for the first segment, and include any segments with non-zero slope or intercepts
$ifthen set pwl_cost
    G_PWL_COST(G)$( (pGenHrSegments (G, 'seg1', 'slope') <> 0) 
                        or (pGenHrSegments (G, 'seg1', 'intercept')) ) = yes;
    PWL_COST_SEG(G, HR_SEG)$( (pGenHrSegments (G, HR_SEG, 'slope') <> 0) 
                                or (pGenHrSegments (G, HR_SEG, 'intercept') <> 0) ) = yes;
$endif

* == Compute max integers for unit_commitment states
*Note: by default GAMS restricts to the range 0 to 100 so this provides two features:
*  1) allowing for higher integer numbers for small plant types as required for a valid solution
*  2) Restricting the integer search space for larger plants
*Important: For capacity expansion problems, this parameter MUST be changed to account for new plants

$ifthen.max_plants %model_name% == UnitCommit

*Here we simply use the current capacity divided by the plant size.
  pMaxNumPlants(G, S)$pGen(G, 'gen_size', S) = ceil(pGen(G, 'cap_cur', S)/pGen(G, 'gen_size', S));

$ifthen set unit_commit
    vUcInt.up(D_SIM, G_UC, S) = pMaxNumPlants(G_UC, S);
$endif

$endif.max_plants

* ===== Take some initial guesses =====
vNonServed.l(D_SIM, S) = 0;

*================================*
*   Additional Data Processing   *
*================================*

* Enable $ variables from included model(s) to propagate back to this master file
$onglobal

* Include water limiting equations and associated parameters and variables
$if set calc_water $include %shared_dir%WaterDataSetup

* Disable influence of $ settings from sub-models
$offglobal

*================================*
*       Solve & Related          *
*================================*
*Only run the rest of this file if we are the main function.
$ifthen.we_are_main %model_name% == UnitCommit


* ======  Setup the model
* Skip this definition if we are doing a restart
    model %model_name%  /all/;

* ======  Adjust Solver parameters
* Enable/Disable Parallel processing
$if not set par_threads $setglobal par_threads 1
$if not set lp_method $setglobal lp_method 4

*Create a solver option file
$onecho > cplex.opt
* Note: the number of threads can either be specified explicitly or using "0" for use all cores
threads %par_threads%

*Parallel mode. Options:
* 1=deterministic & repeatable, 0=automatic, -1=opportunistic & non-repeatable 
parallelmode %par_mode%

* Conserve memory when possible... hopefully avoid crashes b/c of memory
memoryemphasis 1

* Declare solution method for pure LP, RMIP, and final MIP solve. 
*   Options: 0=automatic, 2=Dual Simplex, 4=barrier, 6=concurrent (a race between
* dual simplex and barrier in parallel)
*
* Sometimes barrier is notably faster for operations problems, but more often dual simplex wins
* Barrier is often better for planning problems
LPmethod %lp_method%
* Solution method for solving the root MIP node. See description and options for LPmethod above
startalg %lp_method%
* Solution method for solving sub MIP nodes. See description and options for LPmethod above
* subalg %lp_method%

* Tighten LP tolerance (default 1e-6). For problems with objective values close to 1, this 
* may be necessary to find the true optimal. In particular, with MILP, using the default can 
* cause the final LP solve to stop short of finding the best node from the MILP branch-and-cut
* Surprisingly, a tighter tolerance can also achieve FASTER run times for MILP, presumably
* because the nodes can be compared more carefully.
epopt 1e-9

* Stay with barrier until the optimal solution is found rather than crossing over to simplex
* This can run much faster for these problems, because the final simplex iterations can be 
* slow and b/c the cross-over itself takes a good bit of time. However, the approach is not
* robust and can fail or be slower than the default behavior. Not recommended with barrier 
* alone (LPmethod = 4) b/c may not converge. Consider for concurrent optimization.
*barcrossalg -1

* Ignore small (dual) infeasibilities in the final LP solve. Without this setting, occasionally
* CPLEX will get unhappy with an infeasibility on the order of 1e-6
relaxfixedinfeas 1

*enable relative epsilon optimal (cheat) parameter
*This value is not used if cheat is defined
relobjdif %rel_cheat%

$offecho

*Tell GAMS to use this option file
%model_name%.optfile = 1;

* ======  Tune performance with some initial guesses and settings to speed up the solution
$if set cheat %model_name%.cheat = %cheat%;


* ====== Check command line options
* Check spelling of command line -- options
* Notes:
*  - all command line options have to have either been used already or be listed
* here to avoid an error. We place it here right before the solve statment such that
* if there is an error, we don't wait till post solution to report the problem
$setddlist ignore_integer summary_only summary_and_power_only memo gdx out_gen_params out_gen_avail out_gen_simple

* ======  Actually solve the model
$ifthen set ignore_integer
     solve %model_name% using RMIP minimizing vObjective;
$else
     solve %model_name% using MIP minimizing vObjective;
$endif

*================================*
*         Postprocessing         *
*================================*

* ======  Post processing computations
* Most of these calculations are standardized in ../shared/calcSummary.gms
$include %shared_dir%calcSummary.gms

* ======  Write Standard Results to CSV files
*-- Suppress CSV output if no_csv flag is set
$if "no_csv = 1" $ontext
$include %shared_dir%writeResults.gms

*-- end of output suppression when no_csv flag is set
$if "no_csv = 1" $offtext


$if set gdx execute_unload '%out_dir%%out_prefix%solve.gdx'

* Write value of all control variables to the list file (search for Environment Report)
$show

$endif.we_are_main
