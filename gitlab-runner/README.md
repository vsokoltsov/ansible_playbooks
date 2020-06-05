# Gitlab Runner

## Pre-Run

* Generate ssh keys (if you want to use custom. Default are provided in `credentials` section)
* `chmod +x resources.sh`
* Populate environment variables in `.env` file (sample of variables in `.env.sample`)
* `./resources.sh init`

## Run

* `./resources.sh apply`

## Plan

* `./resources.sh  plan`

## Destroy

* `./resources.sh  destroy`