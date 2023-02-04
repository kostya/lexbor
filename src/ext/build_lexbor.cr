REV = "b0dc514cf81bb830aa1db4e273739436dd6597c9"

def static_link_thread_windows(args : Array(String))
  args << "-DCMAKE_POLICY_DEFAULT_CMP0091=NEW"
  args << "-DCMAKE_MSVC_RUNTIME_LIBRARY=MultiThreaded"
end

def print_stdout_stderr(proc : Process)
  while (line = proc.output.gets) || (line = proc.error.gets)
    puts line
  end
end

current_path = Path[__FILE__]
lexbor_c_path = (current_path.parent) / "lexbor-c"
args = ["clone", "https://github.com/lexbor/lexbor.git", lexbor_c_path.to_s]

unless File.directory? lexbor_c_path
  # TODO: Check if the git clone fails.
  Process.run("git", args: args) { |p| print_stdout_stderr(p) }
end

# Checkout to the specific SHA
Process.run("git", args: ["reset", "--hard", REV], chdir: lexbor_c_path.to_s) { |p| print_stdout_stderr(p) }

# Make the build directory
lexbor_build_path = lexbor_c_path / "build"
unless File.directory? lexbor_build_path
  Dir.mkdir(lexbor_build_path)
end

cmake_args = [
  "..",
  "-DCMAKE_BUILD_TYPE=Release",
  "-DLEXBOR_BUILD_TESTS_CPP=OFF",
  "-DLEXBOR_INSTALL_HEADERS=OFF",
  "-DLEXBOR_BUILD_SHARED=OFF",
]

{% if flag?(:win32) %}
static_link_thread_windows(cmake_args)
{% end %}

Process.run("cmake", args: cmake_args, chdir: lexbor_build_path.to_s) { |p| print_stdout_stderr(p) }

# Build the library

Process.run("cmake", args: ["--build", ".", "--config", "Release", "-j", System.cpu_count.to_s], chdir: lexbor_build_path.to_s) { |p| print_stdout_stderr(p) }
