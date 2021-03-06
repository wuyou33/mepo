
$ontext
-----------------------------------------------------
 System data for ERCOT 2007 With only 3 generators

  originally coded in GAMS by Bryan Palmintier 2012

 Ver   Date       Time  Who            What
 ---  ----------  ----- -------------- ---------------------------------
   1  2012-03-14  17:50  bpalmintier   Adapted from ercot2007eGrid_sys.inc ver 4
 -----------------------------------------------------
$offtext

*===== Scenario Dependent Parameters =====

*cost of carbon (in terms of CO2)        [$/t-CO2eq]   
*Note: value overridden by --co2cost=#.# command-line option
 pCostCO2(S) = 0;         

*renewable portfolio standard (% energy) 
*Note: value overridden by --rps=#.# command-line option
$if declared pRPS
 pRPS(S) = 0;
   
*Carbon Cap in million metric tons CO2(eq)
$if declared pCarbonCap
   pCarbonCap(S) = Inf;

*Scaling parameter for demand
$if declared pDemandScale
   pDemandScale(S)=1;

*===== System Assumptions =====
*weighted average cost of capital (utility investment discount rate) [fract]
 pWACC = 0.08;       
   
*cost of non-served energy		[$/MWh = M$/TWh]
pPriceNonServed = 5e4;

*===== Reserves =====
*Planning reserve (unused capacity) during peak period (includes op reserve)
$if declared pPlanReserve
   pPlanReserve = 0.1;

* Response time for Spinning Reserves [minutes]
$if declared pSpinResponseTime      
	pSpinResponseTime = 10.0;

$if declared pQuickStSpinSubFract
    pQuickStSpinSubFract = 0.5;

*Off-line Operating reserve up (non-spin) as a fraction of load
*$if declared pQuickStartLoadFract
*   pQuickStartLoadFract = 0.03;

*On-line Spinning reserve as a fraction of load
$if declared pSpinReserveLoadFract
   pSpinReserveLoadFract = 0.02;

*On-line spinning reserve minimum (typically set to max plant size)
$if declared pSpinReserveMinGW
   pSpinReserveMinGW = 1.350;

*Off-line Replacement reserves to cover deployed spinning reserves
*Set to zero for consistency between runs for LongTermUnitCommitPaper. Should be closer to 1350MW
*TODO: use non-zero value
$if declared pReplaceReserveGW
   pReplaceReserveGW = 0;

*Frequency regulation up as a fraction of load
$if declared pRegUpLoadFract
   pRegUpLoadFract = 0.01;

*Frequency regulation down as a fraction of load
$if declared pRegDownLoadFract
   pRegDownLoadFract = 0.01;
   
*Wind Forecast Error
$if declared pWindForecastError
   pWindForecastError=0.2;
   
*Additional reserves for Wind
* Data from (De Jonghe, et al 2011) Table III
$if declared pWindFlexUpForecast
	pWindFlexUpForecast = 0.125;
	
$if declared pWindFlexUpCapacity
	pWindFlexUpCapacity = 0.065;
	
$if declared pWindFlexDownForecast
	pWindFlexDownForecast = 0.0875;
	
$if declared pWindFlexDownCapacity
	pWindFlexDownCapacity = 0.0625;

*------- Setup default references to data sub-include files
$if not set fuel $setglobal fuel ercot2007_fuel.inc

$if not set demand $setglobal demand ercot2007_dem_yr.inc

$if not set gens $setglobal gens ngcc_coal_wind_gens.inc
$if not set gparams $setglobal gparams eia_aeo2011_gen_params.inc

$if NOT set avail $setglobal avail ercot2007_avail.inc
