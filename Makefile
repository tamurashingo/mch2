
PROD_CONTAINER := mch2_prod
DEV_CONTAINER := mch2_dev

setup:
	docker image build -t mch2 .


up:
	docker run -it --rm -v $(PWD):/app -p 4005:4005 -p 5000:5000 --name $(PROD_CONTAINER) \
            --entrypoint ros mch2 run \
            -e "(ql:quickload :swank)" \
            -e "(setf swank::*loopback-interface* \"0.0.0.0\")" \
            -e "(swank:create-server :dont-close t :style :spawn)" \
            -e "(ql:quickload :mch2)" \
            -e "(mch2.server:start-server)"

down:
	docker stop $(PROD_CONTAINER)


dev.up:
	docker run -itd --rm -v $(PWD):/app -p 4005:4005 -p 5000:5000 --name $(DEV_CONTAINER) mch2

dev.console:
	docker exec -it $(DEV_CONTAINER) /bin/bash

dev.down:
	docker stop $(DEV_CONTAINER)
