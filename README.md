# Movies Graph
 A graph model of movies  from themoviedb.org



```
CALL apoc.cypher.runSchemaFile("file:///schema.cypher");
CALL apoc.cypher.runFile("file:///AllMoviesDetailsCleaned.csv");
CALL apoc.cypher.runFile("file:///AllMoviesCastingRaw.csv");
```

![](./visual/movies-graph.png)