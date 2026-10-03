SELECT table_name
FROM information_schema.tables
WHERE table_schema = current_schema()
  AND table_type = 'BASE TABLE';


  SELECT *
  FROM exercises;


  SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'exercises';
