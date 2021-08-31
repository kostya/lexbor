REV := fcff658c77199b81623178e5ab6be17d0d4e24c8

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
