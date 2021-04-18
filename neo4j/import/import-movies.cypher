CALL apoc.periodic.iterate(
"
CALL apoc.load.csv('/movies/AllMoviesDetailsCleaned.csv',
{header:  true,
nullValues : ['none', '0.0', '0',''],
sep: ';',
ignore: ['','overview', 'tagline', 'production_companies_number','production_countries_number', 'spoken_languages_number', 'original_title'],
mapping: {
            id:      {type: 'int'},
            popularity: {type: 'float'},
            revenue: {type: 'int'},
            runtime: {type: 'int'},
            vote_average: {type: 'float'},
            vote_count: {type: 'int'},
            budget: {type: 'int'}
          }
})
YIELD map, list
RETURN apoc.convert.toInteger(list[0]) as movieId, map
",
"
WITH movieId, map
MERGE (movie:Movie {id: movieId})
SET movie.popularity = toFloat(map.popularity), movie.revenue = map.revenue, movie.status = map.
  status, movie.title = map.title, movie.imdbId = map.imdb_id

WITH movie, map
CALL apoc.do.when(map.release_date IS NOT NULL,
'
MERGE (rdate:Date {date: map.release_date})
MERGE (movie)-[:RELEASED_ON]->(rdate)
RETURN true',
'RETURN true',
{movie: movie, map: map}) YIELD value

WITH map, movie
CALL apoc.do.when(map.original_language IS NOT NULL,
'MERGE (lang:Language {name: map.original_language})
MERGE (movie)-[:SPOKEN_IN]->(lang)
RETURN true',
'RETURN true',
{movie: movie, map: map}) YIELD value

WITH map, movie
CALL apoc.do.when(map.runtime IS NOT NULL,
'MERGE (rt:Runtime {value: map.runtime})
MERGE (movie)-[:LASTS]->(rt) RETURN true',
'RETURN true',
{movie: movie, map: map}) YIELD value

WITH map, movie
CALL apoc.do.when(map.production_companies IS NOT NULL,
'MERGE (comp:Company {name: map.production_companies})
MERGE (comp)-[:PRODUCED]->(movie)
RETURN true',
'RETURN true',
{movie: movie, map: map}) YIELD value

WITH map, movie
CALL apoc.do.when(map.production_countries IS NOT NULL,
'MERGE (country:Country {name: map.production_countries})
MERGE (movie)-[:PRODUCED_IN]->(country)
RETURN true',
'RETURN true',
{movie: movie, map: map}) YIELD value

WITH map, movie
CALL apoc.do.when(map.vote_average IS NOT NULL,
'MERGE (rating:Rating {value: map.vote_average})
CREATE (movie)-[:RATED {numberOfRatings:map.vote_count}]->(rating)
RETURN true',
'RETURN true',
{movie: movie, map: map}) YIELD value

WITH map, movie
CALL apoc.do.when(map.budget IS NOT NULL,
'MERGE (budget:Budget {value:map.budget})
MERGE (movie)-[:HAD]->(budget)
RETURN true',
'RETURN true',
{movie: movie, map: map}) YIELD value

WITH map, movie
CALL apoc.do.when(map.genres IS NOT NULL,
'WITH movie, split(map.genres,\"|\") AS genres
UNWIND genres AS genre
MERGE (g:Genre {name: genre})
MERGE (movie)-[:OF_GENRE]->(g)
RETURN true',
'RETURN true',
{movie: movie, map: map}) YIELD value
RETURN true
", {batchSize: 10000, parallel: false});
