REV := 3cf192ff8106a78a942bc0ad8b4d5e9e30a4c0b3

.PHONY: package
package: ./lexbor-c/build/liblexbor_static.a

./lexbor-c:
	git clone https://github.com/lexbor/lexbor.git ./lexbor-c
	cd lexbor-c && git reset --hard $(REV)

./lexbor-c/build/liblexbor_static.a: ./lexbor-c
	cd ./lexbor-c && mkdir -p build && cd build && cmake .. -DCMAKE_BUILD_TYPE=Release && make lexbor_static -j

.PHONY: clean
clean:
	rm -rf ./lexbor-c
