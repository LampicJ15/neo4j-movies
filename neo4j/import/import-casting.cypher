//import actors
USING PERIODIC COMMIT 1000
LOAD CSV WITH HEADERS FROM 'file:///AllMoviesCastingRaw.csv' AS map FIELDTERMINATOR ';'
WITH map
MATCH (movie:Movie {id: toInteger(map.id)})
WITH map, movie
UNWIND [map.actor1_name,map.actor2_name,map.actor3_name,map.actor4_name,map.actor5_name] AS actorName
WITH actorName, movie, map
CALL apoc.do.when(NOT actorName = 'none',
'MERGE (actor:Person {name:actorName})
SET actor:Actor
CREATE (actor)-[:ACTED_IN]->(movie) RETURN true',
'RETURN true',
{movie: movie, actorName: actorName}) YIELD value
RETURN value;

//import directors, editors, ..
USING PERIODIC COMMIT 1000
LOAD CSV WITH HEADERS FROM 'file:///AllMoviesCastingRaw.csv' AS map FIELDTERMINATOR ';'
WITH map
MATCH (movie:Movie {id: toInteger(map.id)})
WITH map, movie
CALL apoc.do.when(NOT map.director_name = 'none',
'MERGE (director:Person {name:map.director_name})
SEt director:Director
CREATE (director)-[:DIRECTED]->(movie) RETURN true',
'RETURN true',
{movie: movie, map:map}) YIELD value
WITH map, movie
CALL apoc.do.when(NOT map.producer_name = 'none',
'MERGE (producer:Person {name:map.producer_name})
SET producer:Producer
CREATE (producer)-[:PRODUCED]->(movie) RETURN true',
'RETURN true',
{movie: movie, map:map}) YIELD value
WITH map, movie
CALL apoc.do.when(NOT map.screeplay_name = 'none',
'MERGE (sp:Person {name:map.screeplay_name})
SET sp:Screenplay
CREATE (sp)-[:WROTE]->(movie) RETURN true',
'RETURN true',
{movie: movie, map:map}) YIELD value
WITH movie, map
CALL apoc.do.when(NOT map.editor_name = 'none',
'MERGE (edit:Person {name:map.editor_name})
SET edit:Editor
CREATE (edit)-[:EDITED]->(movie) RETURN true',
'RETURN true',
{movie: movie, map:map}) YIELD value
RETURN value;