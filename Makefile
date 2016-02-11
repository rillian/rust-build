all: Dockerfile fetch_rust.sh build_rust.sh upload_rust.sh
	docker build -t quay.io/rust/gecko-rust-build .
