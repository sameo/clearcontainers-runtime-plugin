PLUGIN_NAME=sameo/clear-containers-plugin
PLUGIN_TAG=1.0

all: clean docker rootfs create

clean:
	@echo "### rm ./plugin"
	@rm -rf ./plugin

docker:
	@echo "### docker build: builder image"
	@docker build -q -t builder -f Dockerfile .
	@echo "### extract clear-containers-runtime-plugin"
	@docker create --name tmp builder
	@docker cp tmp:/go/bin/clearcontainers-runtime-plugin .
	@docker rm -vf tmp
	@docker rmi builder
	@echo "### docker build: rootfs image with clearcontainers-runtime-plugin"
	@docker build -q -t ${PLUGIN_NAME}:rootfs .

rootfs:
	@echo "### create rootfs directory in ./plugin/rootfs"
	@mkdir -p ./plugin/rootfs
	@docker create --name tmp ${PLUGIN_NAME}:rootfs
	@docker export tmp | tar -x -C ./plugin/rootfs
	@echo "### copy config.json to ./plugin/"
	@cp config.json ./plugin/
	@docker rm -vf tmp

create:
	@echo "### remove existing plugin ${PLUGIN_NAME}:${PLUGIN_TAG} if exists"
	@docker plugin rm -f ${PLUGIN_NAME}:${PLUGIN_TAG} || true
	@echo "### create new plugin ${PLUGIN_NAME}:${PLUGIN_TAG} from ./plugin"
	@docker plugin create ${PLUGIN_NAME}:${PLUGIN_TAG} ./plugin

enable:
	@echo "### enable plugin ${PLUGIN_NAME}:${PLUGIN_TAG}"
	@docker plugin enable ${PLUGIN_NAME}:${PLUGIN_TAG}

push:  clean docker rootfs create enable
	@echo "### push plugin ${PLUGIN_NAME}:${PLUGIN_TAG}"
	@docker plugin push ${PLUGIN_NAME}:${PLUGIN_TAG}
