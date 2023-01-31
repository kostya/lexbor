REV = "fcff658c77199b81623178e5ab6be17d0d4e24c8"

def print_stdout_stderr(proc : Process)
  while (line = proc.output.gets) || (line = proc.error.gets)
    puts line
  end
end

current_path = Path[__FILE__]
lexbor_c_path = (current_path.parent) / "lexbor-c"
args = ["clone", "https://github.com/lexbor/lexbor.git", lexbor_c_path.to_s]

# TODO: Check if the git clone fails.
Process.run("git", args: args) { |p| print_stdout_stderr(p) }

# Checkout to the specific SHA
Process.run("git", args: ["reset", "--hard", REV], chdir: lexbor_c_path.to_s) { |p| print_stdout_stderr(p) }

# Make the build directory
lexbor_build_path = lexbor_c_path / "build"
Dir.mkdir(lexbor_build_path)

cmake_args = ["..", "-DCMAKE_BUILD_TYPE=Release", "-DLEXBOR_BUILD_TESTS_CPP=OFF", "-DLEXBOR_INSTALL_HEADERS=OFF", "-DLEXBOR_BUILD_SHARED=OFF"]
Process.run("cmake", args: cmake_args, chdir: lexbor_build_path.to_s) { |p| print_stdout_stderr(p) }

# Build the library

Process.run("cmake", args: ["--build", "."], chdir: lexbor_build_path.to_s) { |p| print_stdout_stderr(p) }
