def cmd(cmd, args, chdir)
  puts "--- execute '#{cmd} #{args.join(" ")}' (in #{chdir})"

  Process.run(cmd, args: args, chdir: chdir.to_s) do |proc|
    puts proc.output.gets_to_end
    puts proc.error.gets_to_end
  end

  if $?.exit_status != 0
    puts "Failed with status #{$?.exit_status}"
    exit $?.exit_status
  end
end

current_path = Path[__FILE__]
current_dir = current_path.parent
lexbor_c_path = current_dir / "lexbor-c"

cmd("git", ["clone", "https://github.com/lexbor/lexbor.git", lexbor_c_path.to_s], current_dir) unless File.directory?(lexbor_c_path)

# Checkout to the specific SHA
cmd("git", ["reset", "--hard", File.read(current_dir / "revision")], lexbor_c_path)

# Make the build directory
lexbor_build_path = lexbor_c_path / "build"
Dir.mkdir(lexbor_build_path) unless File.directory?(lexbor_build_path)

cmake_args = [
  "..",
  "-DCMAKE_BUILD_TYPE=Release",
  "-DLEXBOR_BUILD_TESTS_CPP=OFF",
  "-DLEXBOR_INSTALL_HEADERS=OFF",
  "-DLEXBOR_BUILD_SHARED=OFF",
]

{% if flag?(:win32) %}
  cmake_args << "-DCMAKE_POLICY_DEFAULT_CMP0091=NEW"
  cmake_args << "-DCMAKE_MSVC_RUNTIME_LIBRARY=MultiThreaded"
{% end %}

cmd("cmake", cmake_args, lexbor_build_path)
cmd("cmake", ["--build", ".", "--config", "Release", "-j", {System.cpu_count, 4}.min.to_s], lexbor_build_path)
