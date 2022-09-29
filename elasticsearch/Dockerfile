ARG ELK_VERSION
FROM elasticsearch:${ELK_VERSION}

RUN ./bin/elasticsearch-plugin install -b "https://github.com/medcl/elasticsearch-analysis-ik/releases/download/v7.9.1/elasticsearch-analysis-ik-7.9.1.zip"

EXPOSE 9200 9300