;extensions [profiler]



Globals [
  TIME

  min-data
  max-data

  overall_resources

  number_of_turtles
  turtle_center_of_env_CF
  width_env_fact
  max_distance
  min_distance

  ; distributions
  distribution
  distribution_resources
  distribution_PCF
  distribution_SCF
  distribution_ECF


  ; KPIs
  level-of-achievability
  resource_shortage
  personal-conversion-factor-shortage
  social-conversion-factor-shortage
  environmental-conversion-factor-shortage

  temp
  temp1
  temp2
  temp3
  temp4
  temp5

  temp6
  temp7

  temp8
  temp9


]

Breed [temp_turtles temp_turtle]
Breed [fin_turtles fin_turtle]

fin_turtles-own [
  id
  initial_resource
  age
  age_max
  death_risk_factor
  initial_environmental_conversion_factor

  min_range_distribution_resources
  max_range_distribution_resources

  min_range_distribution_PCFs
  max_range_distribution_PCFs

  min_range_distribution_SCFs
  max_range_distribution_SCFs

  basis_resource
  resource
  personal_conversion_factor
  max_personal_conversion_factor
  average_PC
  social_conversion_factor
  environmental_conversion_factor

  temp_evaluation_PCF_for_SCF
  temp_evaluation_ECF_for_SCF

  social_network
  achievability

  spreading_sin_curve_hete
  social_network_size_hete
  networks_ratio_hete

  weight_resources
  weight_PCF
  weight_SCF
  weight_ECF

]

temp_turtles-own[
  id



]

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Setup ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to setup

  ca
  reset-ticks
;  profiler:start
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; set overall structure ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  set TIME 0

  set number_of_turtles 1089
  let temp_id 0
  create-fin_turtles number_of_turtles [
    set id temp_id
    set temp_id temp_id + 1]

  set min-data 0
  set max-data 10

  let c 0
  ask fin_turtles [
    set shape "person"
    set color black
    set size 0.7]

  ; place temporary turtles

  set temp_id 0
  create-temp_turtles number_of_turtles [
    set id temp_id
    set temp_id temp_id + 1]

  let a min-pxcor
  let b min-pycor
  ask temp_turtles [
    set shape "dot"
    set color white
    set xcor a
    set ycor b
    setxy xcor ycor
    if a = max-pxcor [
      set a min-pxcor - 1
      set b b + 1]
    set a a + 1]

  set overall_resources_t0 0
  set overall_resources overall_resources_t0
  set width_env_fact 0.1

  ; here we create distributions (all are average to 5)

  set distribution []
  if Distributions = "uniform" [
    repeat number_of_turtles [
      set distribution lput 5 distribution]]

  if Distributions = "linear" [
    let counter_agent_lin 0
    repeat number_of_turtles [
      ask fin_turtle counter_agent_lin [let bb (counter_agent_lin / (number_of_turtles - 1) * 10)
        set bb (bb * width-distributions-resources) + (5 - (10 * width-distributions-resources / 2))
        set distribution fput bb distribution]
      set counter_agent_lin counter_agent_lin + 1]]

  if Distributions = "scale_free" [
    let correction 49.71
    let gamma 0.4
    let counter_agent_scale 0
    repeat number_of_turtles [
      ask fin_turtle counter_agent_scale [let cc ((counter_agent_scale + 1)^(0 - gamma)) * correction
        set cc (cc - 5) * width-distributions-resources + 5
        set distribution lput cc distribution]
      set counter_agent_scale counter_agent_scale + 1]]

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; set data resources ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;; resources can here be assigned randomly, or depending on different structures (e.g. depending on network as well) ;;; this is (part of) an analogy of real populations


  ; here we give a min and max range to agents for them to look for
  let agent_count 0
  let width int((1 - clustering-resources) * number_of_turtles)
  repeat number_of_turtles [
    ask fin_turtle agent_count [
      let width_agent width / 2
      set min_range_distribution_resources who - width_agent
      let min_numb_rest 0
      let max_numb_rest 0
      if min_range_distribution_resources < 0 [
        set min_numb_rest 0 - min_range_distribution_resources
        set min_range_distribution_resources 0]

      set max_range_distribution_resources who + width_agent + min_numb_rest
      if max_range_distribution_resources > number_of_turtles [
        set max_numb_rest max_range_distribution_resources - number_of_turtles
        set max_range_distribution_resources number_of_turtles
        set min_range_distribution_resources min_range_distribution_resources - max_numb_rest]

      set min_range_distribution_resources int(min_range_distribution_resources)
      set max_range_distribution_resources int(max_range_distribution_resources)
      set agent_count agent_count + 1]]

  set distribution_resources distribution


  ; here agents pick up one number in their range of the distribution
  ;;;;;;;;;; here the ranges gives more freedom in values to pick up. Other option could be to force agents to pick the most extreme values ;;;;;;;;

  let agent_count_2 0
  let distribution_resources_temp distribution_resources
  repeat number_of_turtles [
    ask fin_turtle agent_count_2 [
      let check_value -1
      let value_checked_list []
      let item_chosen -1
      let checker 1
      while [check_value = -1][
        let ranger max_range_distribution_resources - min_range_distribution_resources
        set item_chosen random (max_range_distribution_resources - min_range_distribution_resources) + min_range_distribution_resources
        set check_value item item_chosen distribution_resources_temp
        if member? item_chosen value_checked_list = false [
          set value_checked_list lput item_chosen value_checked_list]
        if (length value_checked_list >= (max_range_distribution_resources - min_range_distribution_resources)) and (check_value = -1)
        [set check_value item item_chosen distribution_resources]
      set checker checker + 1]
      set distribution_resources_temp replace-item item_chosen distribution_resources_temp -1
      set basis_resource check_value
    set agent_count_2 agent_count_2 + 1]]

  ;;;;;;; placement of turtles ;;;;;;;;

  set turtle_center_of_env_CF temp_turtle 1089

  let dmin 22
  let dmax 0

  ask turtle_center_of_env_CF [
    ask other temp_turtles
    [set dmax distance myself
      if dmax > max_distance [set max_distance dmax]]]

  let list_distances_turtles []
  ask turtle_center_of_env_CF [
    set list_distances_turtles lput 0 list_distances_turtles
    ask other temp_turtles [
      let temp_distance distance myself
      set list_distances_turtles lput temp_distance list_distances_turtles
    ]
    set list_distances_turtles sort-by < list_distances_turtles]

  let list_resources []
  let agent_count_3 0
  repeat number_of_turtles [
    ask fin_turtle agent_count_3 [
      let temp_list_2 []
      set temp_list_2 lput basis_resource temp_list_2
      set temp_list_2 lput who temp_list_2
      set list_resources lput temp_list_2 list_resources
    ]
    set agent_count_3 agent_count_3 + 1
  ]
  set list_resources sort-by [[?1 ?2] -> first ?1 < first ?2] list_resources

  let temp_xcor_1 0
  let temp_ycor_1 0

  foreach list_resources [ ?1 ->
    ask fin_turtle (item 1 ?1) [
      let preferred_distance 0
      ifelse who = 0 [set preferred_distance 0]
      [set preferred_distance item who list_distances_turtles]
      let checker 0
      let temp_xcor_2 [xcor] of fin_turtle 0
      let temp_ycor_2 [ycor] of fin_turtle 0

      ask fin_turtle 0 [
        ask one-of temp_turtles with [(distancexy temp_xcor_1 temp_ycor_1 = preferred_distance)][
          set temp_xcor_2 pxcor
          set temp_ycor_2 pycor]]
      ask temp_turtles-at temp_xcor_2 temp_ycor_2 [die]
      setxy temp_xcor_2 temp_ycor_2]]

  let min_resource min [basis_resource] of fin_turtles
  let max_resource max [basis_resource] of fin_turtles

  ask fin_turtles [
    ask patch-here [let h [basis_resource] of myself
      let i 0
      ifelse (max_resource - min_resource) = 0 [set i 107]
      [set i ((h - max_resource) * (0 - 1)) / ((max_resource - min_resource) / 4) + 105]
      set pcolor i]]

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; set data personal conversion factors ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


  ; here we recreate the distributions made earlier, but set to an average of 3.5 (as average_PC is between 2 and 5)
  if Distributions = "uniform" [
    set distribution_PCF []
    repeat number_of_turtles [
      set distribution_PCF lput 3.5 distribution_PCF]]

  if Distributions = "linear" [
    set distribution_PCF []
    let counter_agent_lin_dist 0
    repeat number_of_turtles [
      ask fin_turtle counter_agent_lin_dist [
        let bb (counter_agent_lin_dist / (number_of_turtles - 1) * 3)
        set bb (bb * width-distributions-PCFs) + (3.5 - (3 * width-distributions-PCFs / 2))
        set distribution_PCF fput bb distribution_PCF]
      set counter_agent_lin_dist counter_agent_lin_dist + 1]]

  if Distributions = "scale_free" [
    set distribution_PCF []
    let correction_scf 34.79
    let gamma_scf 0.4
    let counter_agent__scf 0
    repeat number_of_turtles [
      ask fin_turtle counter_agent__scf [let cc ((counter_agent__scf + 1)^(0 - gamma_scf)) * correction_scf
        set cc (cc - 5) * width-distributions-PCFs + 5
        set distribution_PCF lput cc distribution_PCF]
      set counter_agent__scf counter_agent__scf + 1]]


  ; here we give a min and max range to agents for them to look for
  let agent_count_7 0
  let width_2 int((1 - clustering-PCFs) * number_of_turtles)
  repeat number_of_turtles [
    ask fin_turtle agent_count_7 [
      let width_agent width_2 / 2
      set min_range_distribution_PCFs who - width_agent
      let min_numb_rest 0
      let max_numb_rest 0
      if min_range_distribution_PCFs < 0 [
        set min_numb_rest 0 - min_range_distribution_PCFs
        set min_range_distribution_PCFs 0]

      set max_range_distribution_PCFs who + width_agent + min_numb_rest
      if max_range_distribution_PCFs > number_of_turtles [
        set max_numb_rest max_range_distribution_PCFs - number_of_turtles
        set max_range_distribution_PCFs number_of_turtles
        set min_range_distribution_PCFs min_range_distribution_PCFs - max_numb_rest]

      set min_range_distribution_PCFs int(min_range_distribution_PCFs)
      set max_range_distribution_PCFs int(max_range_distribution_PCFs)
      set agent_count_7 agent_count_7 + 1]]

  ; here agents pick up an average conversion factor from the distribution
  let agent_count_4 0
  let distribution_PCF_temp distribution_PCF
  repeat number_of_turtles [
    ask fin_turtle agent_count_4 [
      let check_value -1
      let value_checked_list []
      let item_chosen -1
      let checker 1
      while [check_value = -1][
        let ranger max_range_distribution_PCFs - min_range_distribution_PCFs
        set item_chosen random (max_range_distribution_PCFs - min_range_distribution_PCFs) + min_range_distribution_PCFs
        set check_value item item_chosen distribution_PCF_temp
        if member? item_chosen value_checked_list = false [
          set value_checked_list lput item_chosen value_checked_list]
        if (length value_checked_list >= (max_range_distribution_PCFs - min_range_distribution_PCFs)) and (check_value = -1)
        [set check_value item item_chosen distribution_PCF]
      set checker checker + 1]
      set distribution_PCF_temp replace-item item_chosen distribution_PCF_temp -1
      set average_PC check_value
    set agent_count_4 agent_count_4 + 1]]

  ; here agents pick up a death_risk_factor from the distribution (same as the PCF distribution)
  let agent_count_5 0
  let distribution_death_risk_temp distribution_PCF
  repeat number_of_turtles [
    ask fin_turtle agent_count_5 [
      let check_value -1
      let value_checked_list []
      let item_chosen -1
      let checker 1
      while [check_value = -1][
        let ranger max_range_distribution_PCFs - min_range_distribution_PCFs
        set item_chosen random (max_range_distribution_PCFs - min_range_distribution_PCFs) + min_range_distribution_PCFs
        set check_value item item_chosen distribution_death_risk_temp
        if member? item_chosen value_checked_list = false [
          set value_checked_list lput item_chosen value_checked_list]
        if (length value_checked_list >= (max_range_distribution_PCFs - min_range_distribution_PCFs)) and (check_value = -1)
        [set check_value item item_chosen distribution_PCF]
      set checker checker + 1]
      set distribution_death_risk_temp replace-item item_chosen distribution_death_risk_temp -1
      set death_risk_factor check_value
    set agent_count_5 agent_count_5 + 1]]

  ; here agents determine their age and age_max
  ask fin_turtles [
    let random_ini_max_age random-float 1
    set age_max (random_ini_max_age * (100 ^ death_risk_factor)) ^ (1 / death_risk_factor)
    let random_ini_age random-float 1
    set age (((random_ini_age * (100 ^ death_risk_factor)) ^ (1 / death_risk_factor)) * -1) + 100
    if age >= age_max
    ;[set age random-float age_max] ; may need to be improved, and check if not too much young agents
    [set age random-float age_max]
  ]

  ; here agents determine their max individual personal conversion factors
  ask fin_turtles [

      let mini 0
      let maxi average_PC * 2
      set spreading_sin_curve_hete average_PC

    let h ((age / 90) * (180 + 45)) - 45
    set max_personal_conversion_factor ((sin h) * spreading_sin_curve_hete) + average_PC
    if max_personal_conversion_factor < 0 [set max_personal_conversion_factor 0]

    ; here they determine their conversion factor, based on the max conversion factor ;;;;;;;;;;;;;;; still to be implemented

    ifelse risk_personal_conversion_factor = true
    [set personal_conversion_factor max_personal_conversion_factor]
    [set personal_conversion_factor max_personal_conversion_factor]
  ]


    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; set data environmental conversion factors ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  let distribution_distances_to_center []
  ask fin_turtles [
    let temp_list_id_dist []
    set temp_list_id_dist lput who temp_list_id_dist
    set temp_list_id_dist lput (distance fin_turtle 0) temp_list_id_dist
    set distribution_distances_to_center lput temp_list_id_dist distribution_distances_to_center
  ]
  set distribution_distances_to_center sort-by [[?1 ?2] -> first ?1 < first ?2] distribution_distances_to_center

  let length_distribution_distances_to_center length distribution_distances_to_center
  let numb_turtles_to_choose_between int(length_distribution_distances_to_center * (1 - clustering-ECFs) + 0.5)
  set distribution_distances_to_center distribution_distances_to_center


  let list_numb_turtles_to_choose_between []
  let counter_turtles_to_select length_distribution_distances_to_center - numb_turtles_to_choose_between
  if counter_turtles_to_select >= 1089 [set counter_turtles_to_select 1088]
  while [counter_turtles_to_select < length_distribution_distances_to_center] [
    set list_numb_turtles_to_choose_between lput item counter_turtles_to_select distribution_distances_to_center list_numb_turtles_to_choose_between
    set counter_turtles_to_select counter_turtles_to_select + 1]

  let item_at_center n-of 1 list_numb_turtles_to_choose_between

  set turtle_center_of_env_CF one-of fin_turtles with [who = item 0 item 0 item_at_center]

  let k 0
  ask turtle_center_of_env_CF [
    ask other fin_turtles
    [set k distance myself
      if k > max_distance [set max_distance k]]]

  ; so here rescale to Width_distributions_ECFs

  let list_environmental_conversion_factor []
  ask fin_turtles [
    let environmental_conversion_factor_before_scaling sin((distance turtle_center_of_env_CF / max_distance) * 90) * (1 / width_env_fact)
    set environmental_conversion_factor (environmental_conversion_factor_before_scaling / 10) * (width-distributions-ECFs * 10) + (5 - (5 * width-distributions-ECFs))

  set list_environmental_conversion_factor lput environmental_conversion_factor list_environmental_conversion_factor
  ]

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; establishment of weights ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  ;;; variable can be created here to alterate the importance of each (resource and conversion) factor
  ;;; the establishement of weights should be done before the establishment of social conversion factors (as the ones depends on the others)

  ask fin_turtles [
  ifelse heterogeneity_weights = true [
      let aa 0
      let bb 0
      let cc 0
      let dd 0
      let temp_list []
      let counter 3
      let points_to_give threshold_achievability_res_CF * 4

      set aa random-float 10
      set temp_list lput aa temp_list
      set counter counter - 1
      set points_to_give points_to_give - aa

      let mini1 (points_to_give - (10 * counter))
      let mini2 [0] set mini2 lput mini1 mini2
      let mini3 max mini2

      let maxi1 (points_to_give - (1 * counter))
      let maxi2 [10] set maxi2 lput maxi1 maxi2
      let maxi3 min maxi2

      set bb random-float (maxi3 - mini3) + mini3
      set temp_list lput bb temp_list
      set counter counter - 1
      set points_to_give points_to_give - bb

      set mini1 (points_to_give - (10 * counter))
      set mini2 [0] set mini2 lput mini1 mini2
      set mini3 max mini2

      set maxi1 (points_to_give - (1 * counter))
      set maxi2 [10] set maxi2 lput maxi1 maxi2
      set maxi3 min maxi2

      set cc random-float (maxi3 - mini3) + mini3
      set temp_list lput cc temp_list
      set counter counter - 1
      set points_to_give points_to_give - cc

      set dd points_to_give

      set temp_list lput dd temp_list
      set temp_list shuffle temp_list

      set weight_resources item 0 temp_list
      set weight_PCF item 1 temp_list
      set weight_SCF item 2 temp_list
      set weight_ECF item 3 temp_list
    ][
  set weight_resources threshold_achievability_res_CF
  set weight_PCF threshold_achievability_res_CF
  set weight_SCF threshold_achievability_res_CF
  set weight_ECF threshold_achievability_res_CF
  ]]

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; set data social conversion factors ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  ;;; Here the network of agents is created (an agentset)
  ;;; Now the social conversion factor is dependent on the personal conversion factors of the social network (this might need to be changed)


  ; here we recreate the distributions made earlier, but set to an average of 4.5 (as social_network_size is between 1 and 8)
  if Distributions = "uniform" [
    set distribution_SCF []
    let bin_counter 0
    repeat number_of_turtles [
      ifelse (bin_counter mod 2) = 0
      [set distribution_SCF lput 4 distribution_SCF]
      [set distribution_SCF lput 5 distribution_SCF]
      set bin_counter bin_counter + 1]]

  if Distributions = "linear" [
    set distribution_SCF []
    let counter_agent_lin_soc 0
    repeat number_of_turtles [
      ask fin_turtle counter_agent_lin_soc [
        let bb (counter_agent_lin_soc / (number_of_turtles - 1) * 7)
        set bb (bb * width-distributions-SCFs) + (4.5 - (7 * width-distributions-SCFs / 2))
        set bb int(bb + 0.5)
        set distribution_SCF fput bb distribution_SCF]
      set counter_agent_lin_soc counter_agent_lin_soc + 1]]

  if Distributions = "scale_free" [
    set distribution_SCF []
    let correction_scf_soc 44.74
    let gamma_scf_soc 0.4
    let counter_agent_scf_soc 0
    repeat number_of_turtles [
      ask fin_turtle counter_agent_scf_soc [let cc ((counter_agent_scf_soc + 1)^(0 - gamma_scf_soc)) * correction_scf_soc
        set cc (cc - 5) * width-distributions-SCFs + 5
        set cc int(cc + 0.5)
        set distribution_SCF lput cc distribution_SCF]
      set counter_agent_scf_soc counter_agent_scf_soc + 1]]


  ; here we give a min and max range to agents for them to look for
  let agent_count_8 0
  let width_3 int((1 - clustering-SCFs) * number_of_turtles)
  repeat number_of_turtles [
    ask fin_turtle agent_count_8 [
      let width_agent width_3 / 2
      set min_range_distribution_SCFs who - width_agent
      let min_numb_rest 0
      let max_numb_rest 0
      if min_range_distribution_SCFs < 0 [
        set min_numb_rest 0 - min_range_distribution_SCFs
        set min_range_distribution_SCFs 0]

      set max_range_distribution_SCFs who + width_agent + min_numb_rest
      if max_range_distribution_SCFs > number_of_turtles [
        set max_numb_rest max_range_distribution_SCFs - number_of_turtles
        set max_range_distribution_SCFs number_of_turtles
        set min_range_distribution_SCFs min_range_distribution_SCFs - max_numb_rest]

      set min_range_distribution_SCFs int(min_range_distribution_SCFs)
      set max_range_distribution_SCFs int(max_range_distribution_SCFs)
      set agent_count_8 agent_count_8 + 1]]

  ; here agents pick up a number of interactions from the distribution (same as the PCF distribution)
  let agent_count_6 0
  let distribution_SCF_temp distribution_SCF
  repeat number_of_turtles [
    ask fin_turtle agent_count_6 [
      let check_value -1
      let value_checked_list []
      let item_chosen -1
      let checker 1
      while [check_value = -1][
        let ranger max_range_distribution_SCFs - min_range_distribution_SCFs
        set item_chosen random (max_range_distribution_SCFs - min_range_distribution_SCFs) + min_range_distribution_SCFs
        set check_value item item_chosen distribution_SCF_temp
        if member? item_chosen value_checked_list = false [
          set value_checked_list lput item_chosen value_checked_list]
        if (length value_checked_list >= (max_range_distribution_SCFs - min_range_distribution_SCFs)) and (check_value = -1)
        [set check_value item item_chosen distribution_SCF]
        set checker checker + 1]
      set distribution_SCF_temp replace-item item_chosen distribution_SCF_temp -1
      set social_network_size_hete check_value
      set agent_count_6 agent_count_6 + 1]]

  set temp8 int(social-network-size + 0.5)
  set temp9 network-ratio


  ask fin_turtles
  [ ; check how network ratio is determined in case of heterogeneity. Could ensure that this ratio differs per agents and follows a distribution as well.
    set social_network_size_hete temp8
    set networks_ratio_hete temp9
    let social_network_size_neighbors int(((int(social_network_size_hete) + 0.5) * networks_ratio_hete) + 0.5)
    let social_network_size_random (int(social_network_size_hete) + 0.5) - social_network_size_neighbors

    let temp_social_network_size_neighbors social_network_size_neighbors
    let max_distance_neighbors 2

    let list_neighbors_counts [8 24 44 68 108 144]
    let counter_list_neighbors 0

    while [item counter_list_neighbors list_neighbors_counts < temp_social_network_size_neighbors][
      set max_distance_neighbors max_distance_neighbors + 1
      set counter_list_neighbors counter_list_neighbors + 1]

    let social_network_neighbors n-of social_network_size_neighbors other fin_turtles with [distance myself < max_distance_neighbors]
    let social_network_random n-of social_network_size_random other fin_turtles with [member? fin_turtle who social_network_neighbors = False]
    set social_network (turtle-set social_network_neighbors social_network_random)]



  let hightest_personal_conversion_factor_1 max [personal_conversion_factor] of fin_turtles
  let hightest_environmental_conversion_factor_1 max [environmental_conversion_factor] of fin_turtles

  ask fin_turtles [
    set temp_evaluation_PCF_for_SCF resource * (personal_conversion_factor / hightest_personal_conversion_factor_1)
    set temp_evaluation_ECF_for_SCF resource * (environmental_conversion_factor / hightest_environmental_conversion_factor_1)]

    ask fin_turtles [
    ; the social_conversion_factor is here a count of other agents in network that can be helpful to cope with possible lack of PCF and ECFs (also lack of resources?)
    ; We assume that one other agent counts as a count if both its PCF and ECF are above the threshold
    set social_conversion_factor count social_network with [(temp_evaluation_PCF_for_SCF >= weight_PCF) and (temp_evaluation_ECF_for_SCF >= weight_ECF)]
]


  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; initial evaluation of achievability ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  ;;; so achievability should be determined by transformations of resources by the three PCFs

  set temp6 max [personal_conversion_factor] of fin_turtles ; temp6 is hightest_personal_conversion_factor
  set temp7 max [environmental_conversion_factor] of fin_turtles  ; temp7 is hightest_personal_conversion_factor
  ask fin_turtles [
    set resource basis_resource
    let g 0
    let f runresult (word function_evaluation_achievability)
    ifelse f = true
    [set color black set achievability true]
    [set color red set achievability false]]

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; KPIs ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


  set level-of-achievability ((count fin_turtles with [achievability = True]) / number_of_turtles)


  set temp4 0
end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Go ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to go
  set TIME ticks

  set temp mean [environmental_conversion_factor] of fin_turtles

  set temp2 mean [personal_conversion_factor] of fin_turtles

  set resource_shortage 0
  set personal-conversion-factor-shortage 0
  set social-conversion-factor-shortage 0
  set environmental-conversion-factor-shortage 0

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; update resources ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  set overall_resources overall_resources + (random-float rate_change_resources - (rate_change_resources / 2))
  ask fin_turtles [set resource basis_resource + (basis_resource * overall_resources)]

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; update personal conversion factor ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  ; could introduce heterogeneity between agents here
  set temp3 0

  ask fin_turtles [
    set age age + 0.1

    if age >= age_max
    [set age 0
      let random_ini_max_age random-float 1
      set age_max (random_ini_max_age * (100 ^ death_risk_factor)) ^ (1 / death_risk_factor)]

    let h ((age / 90) * (180 + 45)) - 45
    set max_personal_conversion_factor ((sin h) * spreading_sin_curve_hete) + average_PC

    ifelse risk_personal_conversion_factor = true
    [set personal_conversion_factor max_personal_conversion_factor]
    [set personal_conversion_factor max_personal_conversion_factor]
  ]


  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; update environmental conversion factor ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  ; We assume that it stays the same now


  ;  ask turtle_center_of_env_CF [
  ;    set turtle_center_of_env_CF one-of fin_turtles with [distance myself <= (int(range_of_spreading) + 0.5) ]]


  ;  ask fin_turtles [
  ;    set environmental_conversion_factor sin((distance turtle_center_of_env_CF / max_distance) * 90) * (1 / width_env_fact)]

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; update social conversion factor ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  let hightest_personal_conversion_factor_2 max [personal_conversion_factor] of fin_turtles
  let hightest_environmental_conversion_factor_2 max [environmental_conversion_factor] of fin_turtles

  ask fin_turtles [
    set temp_evaluation_PCF_for_SCF resource * (personal_conversion_factor / hightest_personal_conversion_factor_2)
    set temp_evaluation_ECF_for_SCF resource * (environmental_conversion_factor / hightest_environmental_conversion_factor_2)]

  ask fin_turtles [
    ; the social_conversion_factor is here a count of other agents in network that can be helpful to cope with possible lack of PCF and ECFs (also lack of resources?)
    ; We assume that one other agent counts as a count if both its PCF and ECF are above the threshold
    set social_conversion_factor count social_network with [(temp_evaluation_PCF_for_SCF >= weight_PCF) and (temp_evaluation_ECF_for_SCF >= weight_ECF)]
]


  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; evaluation of achievability ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  ;;; variable can be created here to alterate the importance of each (resource and conversion) factor

  set temp6 max [personal_conversion_factor] of fin_turtles ; temp6 is hightest_personal_conversion_factor
  set temp7 max [environmental_conversion_factor] of fin_turtles  ; temp7 is hightest_personal_conversion_factor
  ask fin_turtles [


    let g 0
    let f runresult (word function_evaluation_achievability)
    ifelse f = true
    [set color black set achievability true]
    [set color red set achievability false]]

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; KPIs ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  set level-of-achievability ((count fin_turtles with [achievability = True]) / number_of_turtles)

  set resource_shortage resource_shortage / number_of_turtles
  set personal-conversion-factor-shortage personal-conversion-factor-shortage / number_of_turtles
  set social-conversion-factor-shortage social-conversion-factor-shortage / number_of_turtles
  set environmental-conversion-factor-shortage environmental-conversion-factor-shortage / number_of_turtles

  tick
  if ticks > 2000 [
    ;profiler:stop
    ;print profiler:report
    ;profiler:reset
    stop
  ]

end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Modules ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



;to-report rescaling [f w x y z]
;  set f ((f - y) / (z - y)) * (x - w)
;  report f
;end

to-report min_to_reach
  let f false
  let temp_evaluation_PCF resource * (personal_conversion_factor / temp6)
  let temp_evaluation_ECF resource * (environmental_conversion_factor / temp7)

  set min_amount_capable_network_required int (min_amount_capable_network_required + 0.5)

  if ((temp_evaluation_PCF >= weight_PCF) and (temp_evaluation_ECF >= weight_ECF)) or (social_conversion_factor >= min_amount_capable_network_required)
    [set f true]
;  print f
  statistics
  report f
end

to-report threshold_additions
  let f false
  set social_conversion_factor mean [personal_conversion_factor] of social_network
  ;if (resource + personal_conversion_factor + social_conversion_factor + environmental_conversion_factor) >= (threshold_achievability_res_CF * 4)
  if (resource * weight_resources + personal_conversion_factor * weight_PCF + social_conversion_factor * weight_SCF + environmental_conversion_factor * weight_ECF) / (weight_resources + weight_PCF + weight_SCF + weight_ECF) >= (threshold_achievability_res_CF)
  [set f true]
  statistics
  report f
end

to-report threshold_multiplications
  let f false
  set social_conversion_factor mean [personal_conversion_factor] of social_network
  if (resource * weight_resources * personal_conversion_factor * weight_PCF * social_conversion_factor * weight_SCF * environmental_conversion_factor * weight_ECF) >= (threshold_achievability_res_CF * threshold_achievability_res_CF)  ;;;;; check this, might not exactly be right
  [set f true]
  statistics
  report f
end

to-report threshold_additions_with_min_to_reach
  let f false
  set social_conversion_factor mean [personal_conversion_factor] of social_network
  if ((resource * weight_resources + personal_conversion_factor * weight_PCF + social_conversion_factor * weight_SCF + environmental_conversion_factor * weight_ECF) / (weight_resources + weight_PCF + weight_SCF + weight_ECF) >= (threshold_achievability_res_CF * 4)) and (resource >= weight_resources) and (personal_conversion_factor >= weight_PCF) and (social_conversion_factor >= weight_SCF) and (environmental_conversion_factor >= weight_ECF)
  [set f true]
  statistics
  report f
end

to-report threshold_multiplications_with_min_to_reach
  let f false
  set social_conversion_factor mean [personal_conversion_factor] of social_network
  if ((resource * weight_resources * personal_conversion_factor * weight_PCF * social_conversion_factor * weight_SCF * environmental_conversion_factor * weight_ECF) >= (threshold_achievability_res_CF * threshold_achievability_res_CF)) and (resource >= weight_resources) and (personal_conversion_factor >= weight_PCF) and (social_conversion_factor >= weight_SCF) and (environmental_conversion_factor >= weight_ECF)
  ;;;;; check above line, might not exactly be right
  [set f true]
  statistics
  report f
end

to statistics
  if resource < threshold_achievability_res_CF [set resource_shortage resource_shortage + 1]
  if (resource * (personal_conversion_factor / temp6)) < threshold_achievability_res_CF [set personal-conversion-factor-shortage personal-conversion-factor-shortage + 1]
  ;if social_conversion_factor < min_amount_capable_network_required [set social-conversion-factor-shortage social-conversion-factor-shortage + 1]
  if (resource * (environmental_conversion_factor / temp7)) < threshold_achievability_res_CF [set environmental-conversion-factor-shortage environmental-conversion-factor-shortage + 1]
  if ((resource * (personal_conversion_factor / temp6)) < threshold_achievability_res_CF) and ((resource * (environmental_conversion_factor / temp7)) < threshold_achievability_res_CF) and (social_conversion_factor < min_amount_capable_network_required) [set social-conversion-factor-shortage social-conversion-factor-shortage + 1]
end
@#$#@#$#@
GRAPHICS-WINDOW
244
12
681
450
-1
-1
13.0
1
10
1
1
1
0
1
1
1
-16
16
-16
16
0
0
1
ticks
30.0

BUTTON
72
78
135
111
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

BUTTON
73
36
136
69
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

PLOT
712
162
1283
361
Level of feasibility
Time
ratio
0.0
10.0
0.0
1.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot level-of-achievability"

CHOOSER
286
491
510
536
function_evaluation_achievability
function_evaluation_achievability
"min_to_reach" "threshold_additions" "threshold_multiplications" "threshold_additions_with_min_to_reach" "threshold_multiplications_with_min_to_reach"
0

TEXTBOX
34
255
184
273
Agent networks
11
0.0
1

SLIDER
30
309
210
342
social-network-size
social-network-size
1
8
5.0
1
1
NIL
HORIZONTAL

SLIDER
30
349
209
382
network-ratio
network-ratio
0
1
0.5
0.05
1
NIL
HORIZONTAL

SLIDER
286
541
510
574
threshold_achievability_res_CF
threshold_achievability_res_CF
0
20
2.0
1
1
NIL
HORIZONTAL

TEXTBOX
289
468
439
486
Achievability
11
0.0
1

PLOT
1303
95
1616
364
overall_resources
NIL
NIL
0.0
10.0
-1.0
1.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot overall_resources"

PLOT
712
383
1616
621
Shortages leading to lack of feasibility
NIL
NIL
0.0
10.0
0.0
1.0
true
true
"" ""
PENS
"personal_conversion_factor_shortage" 1.0 0 -7500403 true "" "plot personal-conversion-factor-shortage"
"social_conversion_factor_shortage" 1.0 0 -2674135 true "" "plot social-conversion-factor-shortage"
"environmental_conversion_factor_shortage" 1.0 0 -955883 true "" "plot environmental-conversion-factor-shortage"

SLIDER
1368
10
1554
43
overall_resources_t0
overall_resources_t0
-1
1
0.0
0.05
1
NIL
HORIZONTAL

SLIDER
1368
50
1554
83
rate_change_resources
rate_change_resources
0
0.2
0.01
0.01
1
NIL
HORIZONTAL

TEXTBOX
35
183
185
201
Personal factors
11
0.0
1

SLIDER
33
205
210
238
spreading_sin_curve
spreading_sin_curve
0
10
10.0
1
1
NIL
HORIZONTAL

SWITCH
606
683
828
716
heterogeneity_weights
heterogeneity_weights
1
1
-1000

CHOOSER
28
411
208
456
Distributions
Distributions
"uniform" "linear" "scale_free"
2

TEXTBOX
29
388
179
406
Distributions
11
0.0
1

SLIDER
26
663
247
696
width-distributions-resources
width-distributions-resources
0
1
1.0
0.01
1
NIL
HORIZONTAL

TEXTBOX
28
470
178
488
Clustering
11
0.0
1

SWITCH
607
645
813
678
risk_personal_conversion_factor
risk_personal_conversion_factor
1
1
-1000

SLIDER
28
605
208
638
clustering-ECFs
clustering-ECFs
0
1
0.5
0.01
1
NIL
HORIZONTAL

SLIDER
28
529
208
562
clustering-PCFs
clustering-PCFs
0
1
0.5
0.01
1
NIL
HORIZONTAL

SLIDER
28
567
208
600
clustering-SCFs
clustering-SCFs
0
1
0.5
0.01
1
NIL
HORIZONTAL

SLIDER
286
579
510
612
min_amount_capable_network_required
min_amount_capable_network_required
0
10
1.0
1
1
NIL
HORIZONTAL

TEXTBOX
27
646
177
664
Heterogeneity
11
0.0
1

SLIDER
26
698
247
731
width-distributions-PCFs
width-distributions-PCFs
0
1
0.5
0.01
1
NIL
HORIZONTAL

SLIDER
26
734
247
767
width-distributions-SCFs
width-distributions-SCFs
0
1
1.0
0.01
1
NIL
HORIZONTAL

SLIDER
26
770
247
803
width-distributions-ECFs
width-distributions-ECFs
0
1
1.0
0.01
1
NIL
HORIZONTAL

TEXTBOX
33
275
183
305
(the higher the network ratio, the higher the ratio of neighbors in the total amount of interactions)
8
0.0
1

TEXTBOX
713
18
973
111
Agents that consider the opportunity to be feasible are colored in black, the others in red.\n\nPatch colors represent the amount of resources that an agent has (the darker the blue, the richer the agent)
11
0.0
1

SLIDER
33
492
205
525
clustering-resources
clustering-resources
0
1
0.5
0.5
1
NIL
HORIZONTAL

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.0.2
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
