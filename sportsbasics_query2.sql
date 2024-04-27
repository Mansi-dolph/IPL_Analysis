SELECT * FROM sports_basics.dim_match_summary;
select * ,extract(year from matchDate) as season
from dim_match_summary join fact_bating_summary using(match_id);
-- Query 1
select Batsmanname,sum(runs) as total_run
from fact_bating_summary
group by 1
order by 2 desc;

-- query 2
with cte as(select *,extract(year from matchdate) season from fact_bating_summary 
join dim_match_summary using(match_id)),
cte2 as(select batsmanName,season,sum(runs) run_season_wise,sum(balls) as ball_faced,
sum(case when `lost/not_lost`='out'then 1 else 0 end) as time_out
from cte
group by batsmanname,season)
select batsmanname,(sum(run_season_wise)/sum(time_out)) as average_batting
from cte2
where ball_faced>=60
group by batsmanname
having count(*)=3
order by average_batting desc
limit 10;

-- query 3
with cte as(select *,extract(year from matchdate) season from fact_bating_summary 
join dim_match_summary using(match_id)),
cte2 as(select batsmanName,season,sum(runs) run_season_wise,sum(balls) as ball_faced
from cte
group by batsmanname,season)
select batsmanname,(sum(run_season_wise)/sum(ball_faced)) as strike_rate
from cte2
where ball_faced>=60
group by batsmanname
having count(*)=3
order by strike_rate desc
limit 30;



-- query 4
SELECT * FROM sports_basics.fact_bowling_summary;
select bowlerName,sum(wickets) as total_wicket
from fact_bowling_summary
group by bowlerName
order by 2 desc
limit 10;


-- query 5
with cte as(SELECT * ,extract(year from matchDate) as season 
FROM sports_basics.fact_bowling_summary
join dim_match_summary using (match_id)),
cte2 as(select sum(runs) as run_conceded,sum(wickets) as wickets_taken,bowlerName,sum(overs*6) as no_of_balls,season
from cte
group by season, bowlerName),
cte3 as(select sum(run_conceded) run_given,sum(wickets_taken) wick_taken,bowlerName
from cte2 
where no_of_balls>=60
group by bowlerName
having count(*)=3)
select bowlerName,(run_given/wick_taken) as bowling_avg
from cte3
order by bowling_avg asc
limit 10;

-- query 6
with cte as(SELECT * ,(overs*6) as tot_balls,extract(year from matchDate) as season 
FROM sports_basics.fact_bowling_summary
join dim_match_summary using (match_id)),
cte2 as(select bowlerName,season,sum(tot_balls) no_of_balls,sum(overs) no_of_overs_played,sum(runs) as tot_run_conceded
from cte
group by season,BowlerName)
select bowlername,sum(tot_run_conceded)/sum(no_of_overs_played) as economy_rate
from cte2
where no_of_balls>=60
group by bowlername
having count(*)=3
order by economy_rate 
limit 10;

-- query 7
with cte as(SELECT batsmanname,(sum(runs)) as total_runs,(sum(4s*4)+sum(6s*6)) as total_boundaries,sum(balls) balls_faced,
extract(year from matchdate) as season
from fact_bating_summary join dim_match_summary using(match_id)
group by batsmanName,season),
cte2 as(select * from cte
group by batsmanname
having count(*)=3)
select batsmanname,(sum(total_boundaries)/sum(total_runs)) *100 as boundary_per
from cte2
where balls_faced>=60
group by batsmanname
order by 2 desc
limit 5;

-- query 8
with cte as (select  bowlername,extract(year from matchdate) as season,
sum(overs*6) total_deliveries ,sum(0s)as dot_ball
from fact_bowling_summary join dim_match_summary using(match_id)
group by bowlerName, season)
select bowlername,sum(dot_ball)/sum(total_deliveries)*100 as dot_percentage
from cte
where total_deliveries>=60
group by bowlername
having count(*)=3
order by dot_percentage desc
limit 5;

-- query 9
with cte as(select team1,extract(year from matchdate) season
from dim_match_summary
union all
select team2,extract(year from matchdate)
from dim_match_summary),
cte2 as(select team1,count(team1) participated_by_season,season
from cte
group by season,team1),
cte3 as(select team1,sum(participated_by_season) no_of_participation
from cte2
group by team1
order by 2 desc),
cte4 as(select winner,count(winner) no_of_times_winner,extract(year from matchdate) season
from dim_match_summary
group by extract(year from matchdate),winner),
cte5 as(select winner,sum(no_of_times_winner) as tot_match_winner
from cte4
group by winner)
select *,(tot_match_winner)/(no_of_participation)*100 as winning_per
from cte3 join cte5 on cte3.team1=cte5.winner
order by winning_per desc
limit 4;

-- query 10
select winner, sum(case when team2=winner then 1 else 0 end ) win
from dim_match_summary
group by winner
order by win desc
limit 4;










