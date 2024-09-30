-- We'll start by looking at Hacker News data
 SELECT * 
 FROM hacker_news;

-- Let's find the top 5 popular Hacker News Stories
 SELECT title, score
 FROM hacker_news 
 ORDER BY score DESC
 LIMIT 5;

 -- Find the total score of all the stories
 SELECT SUM(score)
 FROM hacker_news;

 -- Find the users who have a score greater than 200
SELECT user, SUM(score)
FROM hacker_news
GROUP BY user
HAVING SUM(score) > 200
ORDER BY 2 DESC; 

-- Sum and divide the scores greater than 200 by the total score
SELECT (517 + 309 + 304 + 282) / 6366.0;

-- Find the amount of times a user has posted an irrelavant link
SELECT user, COUNT(*)
FROM hacker_news
WHERE url LIKE '%watch?v=dQw4w9WgXcQ'
GROUP BY 1
ORDER BY 2 DESC; 

-- Find the source that provides the most news to Hacker News
SELECT CASE 
  WHEN url LIKE '%github%' THEN 'GitHub'
  WHEN url LIKE '%medium%' THEN 'Medium'
  WHEN url LIKE '%nytimes%' THEN 'New York Times'
ELSE 'Other'
END AS 'Source',
COUNT(*)
FROM hacker_news
GROUP BY 1;

-- Viewing how the timestamp data is formatted 
SELECT timestamp
FROM hacker_news
LIMIT 10;

-- Using strftime Function to view date data
SELECT timestamp,
  strftime('%H', timestamp)
FROM hacker_news
GROUP BY 1
LIMIT 20; 

-- Discovering what time is the best time to post a story on Hacker News
SELECT strftime('%H', timestamp) AS 'Hour',
  ROUND(AVG(score), 1) AS 'Average Score', 
  COUNT(*) AS 'Number of Stories'
FROM hacker_news
WHERE timestamp IS NOT NULL
GROUP BY 1
ORDER BY 2 DESC; 

