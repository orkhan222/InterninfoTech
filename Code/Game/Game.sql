-- 1.Extract `P_ID`, `Dev_ID`, `PName`, and `Difficulty_level` of all players at Level 0.
SELECT 
    pd.P_ID, 
    ld.Dev_ID, 
    pd.PName, 
    ld.Difficulty AS Difficulty_level
FROM 
    Player_details pd
JOIN 
    level_details2 ld
ON 
    pd.P_ID = ld.P_ID
WHERE 
    ld.Level = 0;

-- 2. Fins the total number of stages crossed at each difficulty level for Level 2 with players.
SELECT 
    Difficulty, 
    SUM(Stages_crossed) AS Total_Stages_Crossed
FROM 
    level_details2
WHERE 
    Level = 2
GROUP BY 
    Difficulty;
-- 3. Find `Level1_code`wise average `Kill_Count` where `lives_earned` is 2, and at least 3
-- stages are crossed.
-- using `zm_series` devices. Arrange the result in decreasing order of the total number of
-- stages crossed.
SELECT 
    pd.L1_Code,
    AVG(ld.Kill_Count) AS Average_Kill_Count
FROM 
    Player_details pd
JOIN 
    level_details2 ld ON pd.P_ID = ld.P_ID
WHERE 
    ld.Lives_Earned = 2
    AND ld.Stages_crossed >= 3
    AND ld.Dev_ID LIKE 'zm_%'
GROUP BY 
    pd.L1_Code
ORDER BY 
    SUM(ld.Stages_crossed) DESC;

-- 4.Extract `P_ID` and the total number of unique dates for those players who have played
-- games on multiple days.
SELECT 
    P_ID, 
    COUNT(DISTIP_DATE(ESTAMP)) AS Total_Unique_Days
FROM 
    ki level_details2
WHERE 
    Level_Details2

-- 5.Find `P_ID` and levelwise sum of `kill_counts` where `kill_count` is greater than the
-- average kill count for Medium difficulty.
SELECT 
    P_id,
    Level,
    SUM(Kill_Count) AS Total_Kill_Count
FROM 
    level_details2
WHERE 
    Kill_Count > (SELECT AVG(Kill_Count) FROM level_details2 WHERE Difficulty = 'Medium')
GROUP BY 
    P_id, 
    Level;
-- 6.Find `Level` and its corresponding `Level_code`wise sum of lives earned, excluding Level
-- 0. Arrange in ascending order of level.
SELECT 
    pd.Level,
    pd.Level_code, 
    SUM(ld.Lives_Earned) AS Total_Lives_Earned
FROM 
    Player_details pd
JOIN 
    level_details2 ld ON pd.P_ID = ld.P_ID
WHERE 
    pd.Level != 0
GROUP BY 
    pd.Level, pd.Level_code
ORDER BY 
    pd.Level ASC;
-- 7.Find the top 3 scores based on each `Dev_ID` and rank them in increasing order using
-- `Row_Number`. Display the difficulty as well.
WITH RankedScores AS (
    SELECT
        Dev_ID,
        Score,
        Difficulty,
        ROW_NUMBER() OVER (PARTITION BY Dev_ID ORDER BY Score DESC) AS Rank
    FROM
        level_details2
)
SELECT
    Dev_ID,
    Score,
    Difficulty,
    Rank
FROM
    RankedScores
WHERE
    Rank <= 3
ORDER BY
    Dev_ID, Rank ASC;
-- 8.Find the `first_login` datetime for each device ID.
SELECT 
    Dev_ID, 
    MIN(TimeStamp) AS first_login
FROM 
    level_details2
GROUP BY 
    Dev_ID
ORDER BY 
    Dev_ID;
-- 9.Find the top 5 scores based on each difficulty level and rank them in increasing order
-- using `Rank`. Display `Dev_ID` as well.
WITH ScoreRanks AS (
    SELECT
        Dev_ID,
        Score,
        Difficulty,
        RANK() OVER (PARTITION BY Difficulty ORDER BY Score DESC) AS Rank
    FROM
        level_details2
)
SELECT
    Dev_ID,
    Score,
    Difficulty,
    Rank
FROM
    ScoreRanks
WHERE
    Rank <= 5
ORDER BY
    Difficulty, Rank ASC;
-- 10.Find the device ID that is first logged in (based on `start_datetime`) for each player
-- (`P_ID`). Output should contain player ID, device ID, and first login datetime.
SELECT 
    P_ID, 
    Dev_ID, 
    MIN(start_datetime) AS first_login_datetime
FROM 
    level_details2
GROUP BY 
    P_ID, Dev_ID
ORDER BY 
    P_ID, first_login_datetime;
-- 11.For each player and date, determine how many `kill_counts` were played by the player
-- so far.
-- a) Using window functions
-- b) Without window functions
SELECT 
    P_ID, 
    TimeStamp::date AS Date, 
    SUM(Kill_Count) OVER (PARTITION BY P_ID ORDER BY TimeStamp::date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS Cumulative_Kill_Count
FROM 
    level_details2
ORDER BY 
    P_ID, Date;
-- Without window functions
SELECT 
    a.P_ID, 
    a.TimeStamp::date AS Date, 
    SUM(b.Kill_Count) AS Cumulative_Kill_Count
FROM 
    level_details2 a
JOIN 
    level_details2 b ON a.P_ID = b.P_ID AND b.TimeStamp::date <= a.TimeStamp::date
GROUP BY 
    a.P_ID, a.TimeStamp::date
ORDER BY 
    a.P_ID, a.TimeStamp::date;

-- 12.Find the cumulative sum of stages crossed over `start_datetime` for each `P_ID`,
-- excluding the most recent `start_datetime`.
WITH OrderedEntries AS (
    SELECT
        P_ID,
        start_datetime,
        Stages_crossed,
        ROW_NUMBER() OVER (PARTITION BY P_ID ORDER BY start_datetime DESC) AS rn
    FROM
        level_details2
)
SELECT
    P_ID,
    start_datetime,
    SUM(Stages_crossed) OVER (PARTITION BY P_ID ORDER BY start_datetime ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING) AS Cumulative_Stages_Crossed
FROM
    OrderedEntries
WHERE
    rn > 1
ORDER BY
    P_ID, start_datetime;

-- 13.Extract the top 3 highest sums of scores for each `Dev_ID` and the corresponding `P_ID`.
WITH ScoreSums AS (
    SELECT
        Dev_ID,
        P_ID,
        SUM(Score) AS Total_Score
    FROM
        level_details2
    GROUP BY
        Dev_ID, P_ID
),
RankedScores AS (
    SELECT
        Dev_ID,
        P_ID,
        Total_Score,
        DENSE_RANK() OVER (PARTITION BY Dev_ID ORDER BY Total_Score DESC) AS Rank
    FROM
        ScoreSums
)
SELECT
    Dev_ID,
    P_ID,
    Total_Score
FROM
    RankedScores
WHERE
    Rank <= 3
ORDER BY
    Dev_ID, Rank;


-- 14.Find players who scored more than 50% of the average score, scored by the sum of
-- scores for each `P_ID`.
WITH PlayerScores AS (
    SELECT
        P_ID,
        SUM(Score) AS Total_Score
    FROM
        level_details2
    GROUP BY
        P_ID
),
AverageScore AS (
    SELECT
        AVG(Total_Score) AS Avg_Score
    FROM
        PlayerScores
)
SELECT
    ps.P_ID,
    ps.Total_Score
FROM
    PlayerScores ps, AverageScore av
WHERE
    ps.Total_Score > 0.5 * av.Avg_Score;


-- 15.Create a stored procedure to find the top `n` `headshots_count` based on each `Dev_ID`
-- and rank them in increasing order using `Row_Number`. Display the difficulty as well.
CREATE OR REPLACE PROCEDURE GetTopHeadshots (IN n INT)
LANGUAGE SQL
AS $$
BEGIN
    WITH HeadshotRanks AS (
        SELECT
            Dev_ID,
            headshots_count,
            Difficulty,
            ROW_NUMBER() OVER (PARTITION BY Dev_ID ORDER BY headshots_count DESC) AS rn
        FROM
            level_details2
    )
    SELECT
        Dev_ID,
        headshots_count,
        Difficulty,
        rn
    FROM
        HeadshotRanks
    WHERE
        rn <= n
    ORDER BY
        Dev_ID, rn;
END;
$$;
