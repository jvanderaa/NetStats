IMG_NAME=jvanderaa/netstats
IMG_VERSION=0.0.1
.DEFAULT_GOAL := test

.PHONY: build
build:
	docker build -t $(IMG_NAME):$(IMG_VERSION) . 

.PHONY: cli
cli:
	docker run -it \
		-v $(shell pwd):/local \
		$(IMG_NAME):$(IMG_VERSION) bash

.PHONY: run_attached
run_attached:
	docker run -it \
		-v $(shell pwd)/telegraf.conf:/etc/telegraf/telegraf.conf:ro \
		-p 9273:9273 \
		$(IMG_NAME):$(IMG_VERSION)

.PHONY: run
run:
	docker run -itd \
		-v $(shell pwd)/telegraf.conf:/etc/telegraf/telegraf.conf:ro \
		-p 9273:9273 \
		$(IMG_NAME):$(IMG_VERSION)

.PHONY: test
test:	lint unit

.PHONY: lint
lint:
	@echo "Starting  lint"
	docker run -v $(shell pwd):/local $(IMG_NAME):$(IMG_VERSION) sort --check requirements.txt
	docker run -v $(shell pwd):/local $(IMG_NAME):$(IMG_VERSION) black --check .
	docker run -v $(shell pwd):/local $(IMG_NAME):$(IMG_VERSION) make pylint
	docker run -v $(shell pwd):/local $(IMG_NAME):$(IMG_VERSION) bandit --recursive --config .bandit.yml .
	docker run -v $(shell pwd):/local $(IMG_NAME):$(IMG_VERSION) yamllint --strict .
	@echo "Completed lint"

.PHONY: unit
unit:
	@echo "Starting  unit tests"
	docker run -v $(shell pwd):/local $(IMG_NAME):$(IMG_VERSION) pytest -vv
	@echo "Completed unit tests"

.PHONY: cli


# Using to pass arguments to pylint that would fail in docker run command
.PHONY: pylint
pylint:
	find ./ -name "*.py" | xargs pylint