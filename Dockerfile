FROM inwt/r-batch:latest

ADD . .

RUN apt-get -y update \
  && apt-get install -y --no-install-recommends \
      git \
  && apt-get autoremove -y \
  && apt-get autoclean -y \
  && rm -rf /var/lib/apt/lists/* \
  && installPackage

CMD ["check"]
