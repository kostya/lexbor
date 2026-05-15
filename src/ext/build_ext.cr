require "http/client"
require "digest/sha256"

VERSION = "v3.0.0"
URL     = "https://lexbor.com/api/amalgamation?version=#{VERSION}&modules=core%2Ccss%2Cencoding%2Chtml%2Cselectors&ext=c"
SHA256  = "09953402ef7f162de0d22c654603bb435b18f119813df985469f5be11471d6d0"

def cmd(cmd, args, chdir)
  puts "--- '#{cmd} #{args.join(" ")}' (in #{chdir}) ---"

  Process.run(cmd, args: args, chdir: chdir.to_s, input: Process::Redirect::Inherit, output: Process::Redirect::Inherit, error: Process::Redirect::Inherit)

  if $?.exit_code != 0
    puts "Failed with status #{$?.exit_code}"
    exit $?.exit_code
  end
end

def download_file(url : String, expected_sha256 : String, save_to output_path)
  puts "--- Downloading #{url} to #{output_path} ---"

  response = HTTP::Client.get(url)
  unless response.success?
    abort "Download failed: #{response.status_code} #{response.status_message}"
  end

  actual = Digest::SHA256.hexdigest(response.body)
  if actual != expected_sha256
    abort "SHA-256 mismatch for #{url}: expected #{expected_sha256}, got #{actual}"
  end

  File.write(output_path, response.body)
  puts "--- SHA-256 OK: #{actual} ---"
end

def compile_windows(source_path, output_path)
  compile_cmd = ENV["CC"]? || "cl"
  compile_args = [
    "/nologo",
    "/O2",
    "/c",
    source_path.to_s,
    "/Fo#{output_path}/lxb.obj",
  ]

  if env_flags = ENV["CFLAGS"]?
    compile_args += env_flags.split
  end

  cmd(compile_cmd, compile_args, Dir.current)

  lib_cmd = "lib"
  lib_args = [
    "/nologo",
    "/out:#{output_path}/lexbor_static.lib",
    "#{output_path}/lxb.obj",
  ]

  cmd(lib_cmd, lib_args, Dir.current)

  link_cmd = "link"
  dll_args = [
    "/nologo",
    "/DLL",
    "/out:#{output_path}/lxb.dll",
    "#{output_path}/lxb.obj",
  ]

  cmd(link_cmd, dll_args, Dir.current)

  puts "--- Removing temporary files ---"
  File.delete("#{output_path}/lxb.obj") if File.exists?("#{output_path}/lxb.obj")

  puts "--- Static library created: #{output_path}/lexbor_static.lib ---"
  puts "--- Dynamic library created: #{output_path}/lxb.dll ---"
end

def compile_unix(source_path, output_path)
  compile_cmd = ENV["CC"]? || "cc"
  compile_args = [
    "-O3",
    "-c",
    source_path.to_s,
    "-o", "#{output_path}/lxb.o",
    "-fPIC",
  ]

  if env_flags = ENV["CFLAGS"]?
    compile_args += env_flags.split
  end

  cmd(compile_cmd, compile_args, Dir.current)

  ar_cmd = ENV["AR"]? || "ar"
  ar_args = [
    "rcs",
    "#{output_path}/liblxb.a",
    "#{output_path}/lxb.o",
  ]

  if env_arflags = ENV["ARFLAGS"]?
    ar_args += env_arflags.split
  end

  cmd(ar_cmd, ar_args, Dir.current)

  ld_cmd = ENV["LD"]? || compile_cmd
  so_args = [
    "-shared",
    "-o", "#{output_path}/liblxb.so",
    "#{output_path}/lxb.o",
  ]

  {% if flag?(:darwin) %}
    so_args = [
      "-shared",
      "-o", "#{output_path}/liblxb.dylib",
      "#{output_path}/lxb.o",
    ]
  {% end %}

  if env_lflags = ENV["LDFLAGS"]?
    so_args += env_lflags.split
  end

  cmd(ld_cmd, so_args, Dir.current)

  puts "--- Removing temporary files ---"
  File.delete("#{output_path}/lxb.o") if File.exists?("#{output_path}/lxb.o")

  puts "--- Static library created: #{output_path}/liblxb.a ---"
  {% if flag?(:darwin) %}
    puts "--- Dynamic library created: #{output_path}/liblxb.dylib ---"
  {% else %}
    puts "--- Dynamic library created: #{output_path}/liblxb.so ---"
  {% end %}
end

current_dir = Path[__FILE__].parent
ext_dir = current_dir / "lxb"

Dir.mkdir(ext_dir) unless File.directory?(ext_dir)

amalgamation_file = current_dir / "lexbor.c"
unless File.exists?(amalgamation_file)
  download_file(URL, SHA256, save_to: amalgamation_file)
end

{% if flag?(:win32) %}
  compile_windows(amalgamation_file, ext_dir)
{% else %}
  compile_unix(amalgamation_file, ext_dir)
{% end %}

puts "--- Build completed successfully ---"
