# Movies Graph

The repository contains a ready-made Neo4j graph containing cypher scripts for importing the 
dataset [350 000+ movies from themoviedb.org](https://www.kaggle.com/stephanerappeneau/350-000-movies-from-themoviedborg).
It serves as a great example on how to import and transform tabular data into a property graph model, and
 a very good test environment for using cypher in data exploration.
 
## Model
Dataset [350 000+ movies from themoviedb.org](https://www.kaggle.com/stephanerappeneau/350-000-movies-from-themoviedborg) 
contains over 300k movies, from end of 19th century to august 2017. With this data we populate our graph 
(model of the graph is shown below). The graph model is pretty self-explanatory.


![](./visual/movies-graph.png)

## Environment setup

**Prerequisites**:  *Make sure you have already installed both Docker Engine and Docker Compose.*

1. First clone the repository in the desired directory `git clone https://github.com/LampicJ15/neo4j-movies.git`.
2. `cd neo4j-movies`
3. Run `docker-compose up -d` (hint: run `docker-compose logs -f` to track log files).
4. Log onto Neo4j browser: http://localhost:7474/browser/ with the username: *neo4j* and password: *neo4j* and start executing queries and exploring the graph.

## Data Import

When you run `docker-compose up -d` the data import also starts automatically.
When you log into the Neo4j browser you should see that the number of nodes and relationships
keeps growing.

We do not bother you with the data import, we take care of it and keep your rested for exploring data with Cypher. 
But If you are still wondering what happens under the hood, well then let's explain it:

The data and cypher scripts responsible for data import are located in the `neo4j/import` directory.
- When the database starts we first define graph constraints to make our import more efficient. 
Graph constraints are located in the `schema.cypher` file.

- We then import data about the movies by executing the `import-movies.cypher` file and details about the movie cast and crew by executing the content of the `import-casting.cypher` script. 

The order in which the Cypher scripts are executed is specified in the `neo4j.conf` file located in the `neo4j/conf` directory.

*Note*: Importing the data may take some time, so give it a couple of minutes ;). 
When we finish with the import we should se the following message in the database logs `Movies daset import finished ...` 
At the end the database should contain 773 035 nodes and 2 917 460 relationships.

After you are done with exploring the database run

`docker-compose down -v` (the `-v` is to clear the docker volumes used by the database)

## Data Exploring

After the import, everything is up to your imagination when exploring the data.
You can make your own movie recommender or traverse the graph to see how your favourite 
actors are connected to Kevin Bacon (problem known as [Six Degrees of Bacon](https://en.wikipedia.org/wiki/Six_Degrees_of_Kevin_Bacon)).

### Sample Queries
Below we give some sample cypher queries for exploring the movies graph.

- Find all the movies that Christian Bale acted in.
```
MATCH (:Person {name:"Christian Bale"})-[:ACTED_IN]->(movie:Movie)
RETURN movie
```
- Find directors that worked with Leonardo DiCaprio most often.
```
MATCH (:Person {name:"Leonardo DiCaprio"})-[:ACTED_IN]->(movie:Movie)<-[:DIRECTED]-(director:Person)
RETURN director.name, count(director) AS collabs, collect(movie.title) AS movies
ORDER BY collabs DESC LIMIT 5
```

- Retrieve the path from how your favourite actor is related to Kevin Bacon. For example below we show
how a Slovenian actor Jurij Zrnec is related to Kevin Bacon.
```
MATCH (KevinB:Person { name: 'Kevin Bacon' }),(Jurij:Person { name: 'Jurij Zrnec' }), p = shortestPath((KevinB)-[:ACTED_IN*]-(Jurij))
RETURN p
```
We get the following path:

![](./visual/jz-bacon.png)
