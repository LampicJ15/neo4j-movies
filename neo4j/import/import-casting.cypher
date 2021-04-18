CALL apoc.periodic.iterate(
"
CALL apoc.load.csv('/movies/AllMoviesCastingRaw.csv',
{header:  true,
mapping: {id:      {type: 'int'}},
sep: ';'})
YIELD map
RETURN map
",
"
WITH map
MATCH (movie:Movie {id: map.id})
WITH map, movie

CALL apoc.do.when(NOT map.director_name = 'none',
'MERGE (director:Person {name:map.director_name})
WITH director, movie
CREATE (director)-[:DIRECTED]->(movie) RETURN true',
'RETURN true',
{movie: movie, map:map}) YIELD value

WITH movie, map
CALL apoc.do.when(NOT map.producer_name = 'none',
'MERGE (producer:Person {name:map.producer_name})
WITH producer, movie
CREATE (producer)-[:PRODUCED]->(movie) RETURN true',
'RETURN true',
{movie: movie, map:map}) YIELD value

WITH movie, map
CALL apoc.do.when(NOT map.screeplay_name = 'none',
'MERGE (sp:Person {name:map.screeplay_name})
WITH sp, movie
CREATE (sp)-[:WROTE]->(movie) RETURN true',
'RETURN true',
{movie: movie, map:map}) YIELD value

WITH map, movie
CALL apoc.do.when(NOT map.editor_name = 'none',
'MERGE (edit:Person {name:map.editor_name})
WITH edit, movie
CREATE (edit)-[:EDITED]->(movie) RETURN true',
'RETURN true',
{movie: movie, map:map}) YIELD value


WITH map, movie
UNWIND [map.actor1_name,map.actor2_name,map.actor3_name,map.actor4_name, map.actor5_name] AS actorName

WITH actorName, map, movie

CALL apoc.do.when(NOT actorName = 'none',
'MERGE (actor:Person {name:actorName})
WITH actor, movie
CREATE (actor)-[:ACTED_IN]->(movie) RETURN true',
'RETURN true',
{movie: movie, actorName: actorName}) YIELD value
WITH collect(value) AS ignore
RETURN null
", {batchSize: 10000, parallel: false});

CALL apoc.log.info('Movies daset import finished ... ');
