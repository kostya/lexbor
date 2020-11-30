REV := 5ffe6e63270aa3ff79e5f53506a0ba63a945a3b2

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
