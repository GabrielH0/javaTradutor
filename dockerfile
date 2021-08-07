FROM gcc:10

COPY . /usr/src/java

WORKDIR /usr/src/java

RUN apt-get update && \
    apt-get install flex -y && \
    apt-get install bison -y

CMD ["tail", "-f", "/dev/null"]