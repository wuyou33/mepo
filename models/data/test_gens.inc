
$ontext
-----------------------------------------------------
Test Generator data for capacity planning for use with ToyCapPlan model

 The simple test system is meant to provide a consistant comparison for testing performance
 and checking against accepted "answers"

  Sample generation data.
  
  Existing capacity based on "optimal" mix using StaticCapPlan GAMS model (r124). This allows
  consistant use with operations only models and CapPlanDp MATLAB code using "from data" for
  baseline system sizing.

  Source:
    DoE Annual Energy Outlook, 2010 Table 8.2 Generator Cost Assumptions

  with some numbers based on:
    Royal Academy of Engineering. (2004). The cost of generating electricity. 
    London: Royal Academy of Engineering.
  specifically:
   - life estimates

  Technology Mapping:
                  DOE AEO2010
    Nuke       Advanced Nuclear
    Coal       Scrubbed Coal, New
    CCGT       Adv Gas/Oil Comb Cycle
    CT         Adv Comb Turbine
    Wind       Wind

 Notes & Assumptions:
   - Capital Costs are Total Overnight costs (including Contingency & Optimism)
   - Heatrates are 2009 heatrates
   - Costs in 2008 $'s
   - Royal Academy costs (2004 pounds) estimated as 2008 $ by multiplying by 2

 originally coded in GAMS by Bryan Palmintier 2010-04-08

Ver   Date       Time   Who           What
---  ----------  -----  ------------- ---------------------------------
  1  2011-11-07  11:26  bpalmintier   Adapted from gens.inc v10. Data matches back to SVN r96
  2  2012-02-03  16:40  bpalmintier   SCALED units (GW, etc)
  3  2012-02-18  22:00  bpalmintier   Added derate
  4  2012-09-02  17:08  bpalmintier   Replace all $set with $setglobal (to prevent scope errors)
----------------------------------------------------- 
$offtext
               
* -- Setup default (empty) path to csv include file. Typically this will be overridden.
$if NOT set data_dir    $setglobal data_dir   

* ---- Define the list of generation technologies
sets
         GEN_PARAMS  generation table parameters
*Note by including this list again here, we can add attributes in this document without breaking
*Old models such as ToyCapPlan
               /
                cap_credit  "Capacity Credit during peak block           [p.u.]"
                c_var_om    "variable O&M cost                           [$/MWh]"
                c_fix_om    "fixed O&M cost                              [M$/GW-yr]"
                c_cap       "total capital cost                          [M$/GW]"
                life        "economic lifetime for unit                  [yr]"
                heatrate    "heatrate for generator (inverse efficiency) [MMBTU/MWh = BTUe9/GWh]"
                fuel        "name of fuel used                           [name]"
                cap_cur     "Current installed capacity for generation   [GW]"
                cap_max     "Maximum installed capacity for generation   [GW]"
                co2_embed   "CO2_eq emissions from plant construction    [Mt/GW]"
                co2_ccs     "Fraction of carbon capture & sequestration  [p.u.]"
                p_min       "minimum power output (for baseload)         [p.u.]"
                lead_time   "Delay from construction to operation        [yr]"
                gen_size    "typical discrete plant size                 [GW]"
                ramp_max    "Maximum hourly ramp rate                    [fract/hr]"
                unit_min    "Minimum power output per committed unit     [GW]"
                c_start_fix "Fixed cost to start up a unit               [K$/start]"
                fuel_start  "Fuel usage to start up a unit               [BTUe9/start]"
                quick_start "Fraction of capacity avail for non-spin reserves [p.u.]" 
                reg_up      "Fraction of capacity avail for regulation up reserves [p.u.]" 
                reg_down    "Fraction of capacity avail for regulation down reserves [p.u.]" 
                spin_rsv    "Fraction of capacity avail for spinning reserves [p.u.]" 
                derate      "Derating factor for simple (non-reserves) cap planning [p.u.]"
               /

         G           generation
               /Nuke
                Coal
                CCGT
                CT
                Wind
               /
                             
               
*-- Parts 1-4: Generator Table Parameters
* ----- Import parameters from CSV file
* Make GAMS OK with using comma delimited (CSV-like) data fields
$ondelim

table    pGenData(G, GEN_PARAMS)   "Generation Data Table"
name,       c_var_om,   c_fix_om,   c_cap,      life,       fuel,       heatrate,   lead_time,  cap_cur,    cap_max,    co2_embed,  co2_ccs,    p_min,      cap_credit, gen_size, ramp_max,     unit_min,    c_start_fix,       fuel_start,   quick_start,  reg_up,  reg_down, spin_rsv,   max_start,   derate
Nuke,       0.51,       92.040,     3820,       40,         u235,       10.488,     6,          0,             Inf,        0,          0,          0,          0.9,      1.350,       0.01,       1.250,         100,               10,             0,       0,         0,       0,             2,      0.9       
Coal,       4.69,       28.150,     2223,       30,         coal,       9.2,        4,          28.200,        Inf,        0,          0,          0,          0.85,     0.600,       0.1,        0.300,          20,               10,             0,       0.002,     0.002,   0.017,        50,      0.85
CCGT,       2.04,       11.960,      968,       30,         ng,         6.752,      3,          19.600,        Inf,        0,          0,          0,          0.85,     0.400,       0.8,        0.150,           5,                1,             0,       0.025,     0.025,   0.25,        300,      0.89
CT,         3.24,       10.770,      648,       20,         ng,         9.289,      2,          33.580,        Inf,        0,          0,          0,          0.85,     0.230,       6,          0.010,           0.100,            0,             1,       0.05,      0.05,    0.5,         Inf,      0.91
Wind,       0,          30.980,     1966,       20,         wind,       1,          3,           7.200,        Inf,        0,          0,          0,          0.1,      0.50,        1,          0,               0,                0,             0,       0,         0,       0,           Inf,      1.0
;

* Return to normal GAMS space delimited data formats
$offdelim
