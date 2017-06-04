#
PROFILE?= onepiece2money

#
.PHONY: build

#
build:
	@echo 'Use "make <something>" to build AMIs.'

reverse-proxy:
	AWS_PROFILE=${PROFILE} packer build packer-reverse-proxy.json

php70:
	AWS_PROFILE=${PROFILE} packer build packer-template-php70.json

php71:
	AWS_PROFILE=${PROFILE} packer build packer-template-php71.json
