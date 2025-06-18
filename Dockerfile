FROM fukamachi/sbcl

RUN apt-get update

ENV CL_SOURCE_REGISTRY=/app

RUN mkdir /app
WORKDIR /app
COPY . /app

EXPOSE 4005
EXPOSE 5000

ENTRYPOINT [ "ros", "run", \
      "-e", "(ql:quickload :swank)", \
      "-e", "(setf swank::*loopback-interface* \"0.0.0.0\")", \
      "-e", "(swank:create-server :dont-close t :style :spawn)" ]
