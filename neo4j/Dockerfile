FROM graphfoundation/ongdb:3.5

RUN apt update
RUN apt install -y wget
RUN apt install -y unzip

ADD ./conf /conf

ADD ./import /import

RUN unzip /import/movies.zip -d /import

RUN wget https://github.com/neo4j-contrib/neo4j-apoc-procedures/releases/download/3.5.0.14/apoc-3.5.0.14-all.jar -P /var/lib/neo4j/plugins/

ENTRYPOINT ["/sbin/tini", "-g", "--", "/docker-entrypoint.sh"]

CMD ["neo4j"]
