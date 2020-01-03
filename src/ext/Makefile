REV := a4227646259d90c9787c05b9fd5d3283069710ec

.PHONY: package
package: ./lexbor-c/build/liblexbor_static.a

./lexbor-c:
	git clone https://github.com/lexbor/lexbor.git ./lexbor-c
	cd lexbor-c && git reset --hard $(REV)

./lexbor-c/build/liblexbor_static.a: ./lexbor-c
	cd ./lexbor-c && mkdir build && cd build && cmake .. -DCMAKE_BUILD_TYPE=Release && make lexbor_static -j2

.PHONY: clean
clean:
	rm -rf ./lexbor-c
