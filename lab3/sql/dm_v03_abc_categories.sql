DROP VIEW IF EXISTS dm_v03_abc_categories;
CREATE VIEW dm_v03_abc_categories AS
WITH cat AS (
  SELECT category,
         SUM(item_value)              AS revenue,
         COUNT(*)                     AS items
  FROM core_item
  WHERE order_status = 'delivered'
  GROUP BY category
),
ranked AS (
  SELECT category, revenue, items,
         ROW_NUMBER() OVER (ORDER BY revenue DESC, category) AS rank_num,
         ROUND(revenue * 100.0 / SUM(revenue) OVER (), 4)    AS share_pct,
         ROUND(SUM(revenue * 100.0) OVER (ORDER BY revenue DESC, category)
               / SUM(revenue) OVER (), 4)                    AS cum_share_pct
  FROM cat
)
SELECT category,
       ROUND(revenue, 2) AS revenue,
       items,
       rank_num,
       share_pct,
       cum_share_pct,
       CASE
         WHEN cum_share_pct <= 80 THEN 'A'
         WHEN cum_share_pct <= 95 THEN 'B'
         ELSE 'C'
       END AS abc_class
FROM ranked;
