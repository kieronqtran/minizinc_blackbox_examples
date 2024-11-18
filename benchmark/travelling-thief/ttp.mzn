%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                Travelling Thief Problem
%
% Solves the TTP as described in https://sites.google.com/view/ttp-gecco2023/home
% 
% You need to rent a knapsack and travel through all cities picking items as you go
% in such a way as to (a) visit all cities at least once starting and ending at
% city 1, and (b) not go over the knapsack's capacity, while maximising the value
% of the knapsack items when you arrive back at city 1 and minimising the rental of
% the knapsack, which depends on the travel time taking into account that the travel
% speed decreases with the weight of the items.
% 
% Note: there are no items in city 1 and there are always K items in each city
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% PARAMETERS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%

int: ncities;
int: nitems;
int: bb_distance_n;

set of int: CITY = 1..ncities; % cities we must visit at least once
set of int: ITEM = 1..nitems;  % items that are available to pick up 
int: knapsack_capacity;        % capacity of the knapsack (cannot be over)
int: min_speed;                % minimum speed to travel from one city to another
int: max_speed;                % maximum speed to travel from one city to another
float: renting_ratio;          % cost 0..100 of renting the knapsack as a ratio of the time travelling

array [CITY, CITY] of int: distances; % distance between each two cities
array [ITEM] of record(int: profit, int: weight, CITY: city): items;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%% FUNCTIONALLY DEPENDENT PARAMETERS %%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
int: itemsPerCity = card(ITEM) div (card(CITY)-1); % number of items in each city
constraint assert(card(ITEM) mod (card(CITY)-1) == 0, "not all cities have the same amount of items");

% maps cities to its items
array [CITY, 1..itemsPerCity] of ITEM: city_items = array2d(
    CITY, 1..itemsPerCity,
    [1 | _ in 1..itemsPerCity] ++ [item | c in CITY, item in { i | i in ITEM where items[i].city = c }]
);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% MAIN VARIABLES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% whether an item is picked or not
array [ITEM] of var bool: chosen::output; 

% city visited at a given time; the first and last must be 1 so the last 1 is implied
set of int: TIME = 1..ncities;
array [TIME] of var CITY: order::output;  

% order = [1, 6, 5, 7, 3, 9, 4, 10, 8, 2];
% chosen = [false, true, false, false, false, false, false, false, false,
%        false, false, false, false, true, false, false, false, false,
%        false, false, false, false, false, false, false, false, false];

% constraint forall(i in ITEM where chosen[i])(trace("\(chosen[i]):\(items[i])\n", chosen[i]));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% MAIN CONSTRAINTS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
include "globals.mzn";

% no city can be visited twice (recall that the last visit to 1 is implied)
constraint all_different(order);     

% the first city must be 1
constraint order[1] = 1; 

% the capacity of the knapsack cannot be exceeded
constraint sum (i in ITEM) (chosen[i] * items[i].weight) <= knapsack_capacity;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% OBJECTIVE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 

% weight of the knapsack at any given time 
set of int: WEIGHT = 0..knapsack_capacity;
array [TIME] of var WEIGHT: weight; 

% velocity of the traveller ar any point in time (which depends on the weight)
array [TIME] of var float: velocity:: output = [max_speed - (max_speed - min_speed) * weight[t] / knapsack_capacity | t in TIME];

var int: profit :: output = sum (i in ITEM) (chosen[i] * items[i].profit);
var float: rental :: output = sum (t in TIME) ((distances[order[t], if t == max(TIME) then 1 else order[enum_next(t)] endif]) / velocity[t]);
var float: total_travel_time :: output = renting_ratio * rental;

% in the first trip (from city 1 to whatever) the knapsack is empty
constraint weight[1] = 0;
% 
constraint forall (t in TIME where t > 1) (
    weight[t] = weight[enum_prev(t)] + sum (i in 1..itemsPerCity) (
        let {
            any: item = city_items[order[t], i]
        } in chosen[item] * items[item].weight
    )
);

array [TIME] of var 0..sum(distances) div 2: distAtTime;

constraint distAtTime[max(TIME)] = distances[order[max(TIME)], 1];
% 
constraint forall (t in TIME where t < max(TIME)) (
    distAtTime[t] = distAtTime[enum_next(t)] + distances[order[t], order[enum_next(t)]]
);

array [CITY] of var TIME: time = inverse(order);
array [TIME, 1..itemsPerCity] of var bool: chosen_order = [
        (t, i): chosen[city_items[order[t], i]] | t in TIME, i in 1..itemsPerCity
    ];

var float: objective = profit - total_travel_time;

solve :: seq_search([
    int_search(order, input_order, indomain_min),
    bool_search([chosen_order[t, i] | t in reverse(TIME), i in 1..itemsPerCity], input_order, indomain_max)
]) maximize objective;

array [ITEM, ITEM] of bool: dominated = [
    (i, j): items[i].weight >= items[j].weight
         /\ items[i].profit <= items[j].profit | i, j in ITEM
];

constraint forall (i, j in ITEM where i != j /\ dominated[i, j]) (
    (chosen[i] /\ distAtTime[time[items[i].city]] >= distAtTime[time[items[j].city]]) -> chosen[j]
);
