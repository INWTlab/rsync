FROM inwt/r-batch:latest

ADD . .

RUN installPackage

CMD ["check"]
