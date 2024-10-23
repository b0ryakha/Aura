SRC_DIR = "./sources"
EXM_DIR = "./examples"
BUILD_DIR = "./build"
.ONESHELL:

build:
	tl check ${SRC_DIR}/*.tl &&
	tl gen ${SRC_DIR}/*.tl &&
	tl check ${SRC_DIR}/widgets/*.tl &&
	tl gen ${SRC_DIR}/widgets/*.tl &&
	rm -rf ${BUILD_DIR} &&
	mkdir ${BUILD_DIR} &&
	mv ${SRC_DIR}/*.lua ${BUILD_DIR} &&
	mv ${SRC_DIR}/widgets/*.lua ${BUILD_DIR}

build_examples: build
	tl check ${EXM_DIR}/*.tl &&
	tl gen ${EXM_DIR}/*.tl &&
	mkdir ${BUILD_DIR}/${EXM_DIR} &&
	mv ${EXM_DIR}/*.lua ${BUILD_DIR}/${EXM_DIR} &&
	cp -r ${EXM_DIR}/assets ${BUILD_DIR}/${EXM_DIR}

test: build_examples
	@if [ -z "$(example)" ]; then
		echo -e "\e[31musing: test example=<name>\e[0m";
		exit 0;
	fi
	./externals/moonshine/Moonshine.exe ${BUILD_DIR}/${EXM_DIR}/${example}.lua || true