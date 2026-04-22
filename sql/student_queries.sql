-- ============================================================
--   Student Performance — SQL Analitik Sorğular
--   Verilənlər bazası: SQLite (students.db)
-- ============================================================

-- Cədvəl strukturu:
-- students(student_id, gender, race_ethnicity, parental_education,
--          lunch, test_prep, math_score, reading_score, writing_score,
--          average_score)

-- ── 1. Cinslər üzrə orta ballar ─────────────────────────────────────────────
SELECT
    gender,
    ROUND(AVG(math_score),2)    AS avg_math,
    ROUND(AVG(reading_score),2) AS avg_reading,
    ROUND(AVG(writing_score),2) AS avg_writing,
    ROUND(AVG(average_score),2) AS avg_total,
    COUNT(*)                    AS total_students
FROM students
GROUP BY gender
ORDER BY avg_total DESC;

-- ── 2. Test hazırlığının fənn ballarına təsiri ───────────────────────────────
SELECT
    test_prep,
    COUNT(*)                                AS student_count,
    ROUND(AVG(math_score),2)                AS avg_math,
    ROUND(AVG(reading_score),2)             AS avg_reading,
    ROUND(AVG(writing_score),2)             AS avg_writing,
    ROUND(AVG(average_score),2)             AS avg_total
FROM students
GROUP BY test_prep;

-- ── 3. Valideyn təhsili → akademik nəticə ────────────────────────────────────
SELECT
    parental_education,
    COUNT(*)                    AS students,
    ROUND(AVG(average_score),2) AS avg_score,
    MIN(average_score)          AS min_score,
    MAX(average_score)          AS max_score
FROM students
GROUP BY parental_education
ORDER BY avg_score DESC;

-- ── 4. Top 10 tələbə ─────────────────────────────────────────────────────────
SELECT
    student_id, gender, race_ethnicity, parental_education,
    math_score, reading_score, writing_score,
    ROUND(average_score,2) AS avg_score
FROM students
ORDER BY average_score DESC
LIMIT 10;

-- ── 5. Nahar + test hazırlığı kombinasiyası (4 seqment) ─────────────────────
SELECT
    lunch, test_prep,
    COUNT(*)                    AS students,
    ROUND(AVG(average_score),2) AS avg_score
FROM students
GROUP BY lunch, test_prep
ORDER BY avg_score DESC;

-- ── 6. Etnik qrup sıralaması — Window Function ilə ──────────────────────────
SELECT
    race_ethnicity,
    ROUND(AVG(math_score),2)    AS avg_math,
    ROUND(AVG(reading_score),2) AS avg_reading,
    ROUND(AVG(writing_score),2) AS avg_writing,
    ROUND(AVG(average_score),2) AS avg_total,
    RANK() OVER (ORDER BY AVG(average_score) DESC) AS rank_overall
FROM students
GROUP BY race_ethnicity
ORDER BY rank_overall;

-- ── 7. Hər sinifdə qiymət bölgüsü (A-F) ─────────────────────────────────────
SELECT
    CASE
        WHEN average_score >= 90 THEN 'A (90-100)'
        WHEN average_score >= 80 THEN 'B (80-89)'
        WHEN average_score >= 70 THEN 'C (70-79)'
        WHEN average_score >= 60 THEN 'D (60-69)'
        ELSE                          'F (<60)'
    END                                           AS grade,
    COUNT(*)                                      AS students,
    ROUND(COUNT(*) * 100.0 / 1000, 1)            AS percentage
FROM students
GROUP BY grade
ORDER BY grade;

-- ── 8. Kecid faizi cins üzrə ────────────────────────────────────────────────
SELECT
    gender,
    COUNT(*) AS total,
    ROUND(SUM(CASE WHEN math_score    >= 60 THEN 1.0 ELSE 0 END)/COUNT(*)*100,1) AS pct_math,
    ROUND(SUM(CASE WHEN reading_score >= 60 THEN 1.0 ELSE 0 END)/COUNT(*)*100,1) AS pct_reading,
    ROUND(SUM(CASE WHEN writing_score >= 60 THEN 1.0 ELSE 0 END)/COUNT(*)*100,1) AS pct_writing
FROM students
GROUP BY gender;

-- ── 9. CTE: Hər valideyn qrupunda ən yaxşı tələbə ───────────────────────────
WITH ranked AS (
    SELECT *,
           RANK() OVER (
               PARTITION BY parental_education
               ORDER BY average_score DESC
           ) AS rnk
    FROM students
)
SELECT student_id, gender, race_ethnicity, parental_education,
       math_score, reading_score, writing_score,
       ROUND(average_score,2) AS avg_score
FROM ranked
WHERE rnk = 1
ORDER BY avg_score DESC;

-- ── 10. Kumulyativ kecid faizi (running total) ────────────────────────────────
SELECT
    student_id,
    math_score,
    ROUND(
        SUM(CASE WHEN math_score >= 60 THEN 1 ELSE 0 END)
            OVER (ORDER BY student_id ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
        * 100.0
        / ROW_NUMBER() OVER (ORDER BY student_id),
    1) AS running_pass_pct_math
FROM students
LIMIT 20;
