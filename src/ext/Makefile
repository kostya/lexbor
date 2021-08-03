REV := 5ffe6e63270aa3ff79e5f53506a0ba63a945a3b2

.PHONY: package
package: ./lexbor-c/build/liblexbor_static.a

./lexbor-c:
	git clone https://github.com/lexbor/lexbor.git ./lexbor-c
	cd lexbor-c && git reset --hard $(REV)

./lexbor-c/build/liblexbor_static.a: ./lexbor-c
	cd ./lexbor-c && mkdir -p build && sed '/GNUInstallDirs/d' ./CMakeLists.txt > ./CMakeLists.tmp.txt && mv ./CMakeLists.tmp.txt ./CMakeLists.txt && cd build && cmake .. -DCMAKE_BUILD_TYPE=Release && make lexbor_static -j 4

.PHONY: clean
clean:
	rm -rf ./lexbor-c
