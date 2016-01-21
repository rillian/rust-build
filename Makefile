all: Dockerfile fetch_rust.sh build_rust.sh
	docker build -t rust-build .
