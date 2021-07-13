--1. Find the popularity percentage for each user on Facebook. The popularity percentage is defined as the total number of friends the user has divided by the total number of users on the platform, then converted into a percentage by multiplying by 100.
--Output each user along with their popularity percentage. Order records in ascending order by user id.
--The 'user1' and 'user2' column are pairs of friends.[StrataScratch Facebook]



WITH new as (SELECT user1,user2
FROM facebook_friends
UNION
SELECT user2,user1
FROM facebook_friends) 

 SELECT user1, COUNT(user1)*100/tot.t as c
FROM new JOIN (SELECT CAST(COUNT(*) AS FLOAT)/2 as t FROM new) as tot ON 1=1
GROUP BY user1, tot.t
ORDER BY user1;





--2. Find the date with the highest total energy consumption from the Facebook data centers. Output the date along with the total energy consumption across all data centers.[StrataScratch Facebook]



WITH new AS (select * from fb_eu_energy
UNION SELECT * FROM fb_asia_energy
UNION SELECT * FROM fb_na_energy)


SELECT date, SUM(consumption)
FROM new 
GROUP BY new.date
    HAVING SUM(consumption)= (
        SELECT SUM(consumption) as max 
        FROM new
        GROUP BY date
        ORDER BY SUM(consumption) DESC LIMIT 1);
        
  
 --3. Find the total number of downloads for paying and non-paying users by date. Include only records where non-paying customers have more downloads than paying customers. 
--The output should be sorted by earliest date first and contain 3 columns date, non-paying downloads, paying downloads.[ StrataScratch Microsoft]
  
--non paying > paying
--make 2 ctes
WITH paying as (
SELECT SUM(downloads) as p_total ,date
FROM ms_user_dimension u
  JOIN ms_acc_dimension a
  ON u.acc_id = a.acc_id
  JOIN ms_download_facts d
  ON u.user_id = d.user_id
WHERE paying_customer='yes'
GROUP BY date
),
non_paying as (
SELECT SUM(downloads) as n_total ,date
FROM ms_user_dimension u
  JOIN ms_acc_dimension a
  ON u.acc_id = a.acc_id
  JOIN ms_download_facts d
  ON u.user_id = d.user_id
WHERE paying_customer='no'
GROUP BY date
)

SELECT n.date, n_total,p_total
FROM paying p JOIN non_paying n
ON p.date=n.date
WHERE n_total > p_total ;

