require "crystal/system/win32/visual_studio"

module VS_ENV
  UNDEF = "____@@@@@@UNDEF****211_____"

  def self.with_env(&)
    helper = Helper.new
    helper.run_vcvars_batch do
      yield
    end
  end

  class Helper
    PATH_LIKE_VARIABLES = ["PATH", "INCLUDE", "LIB", "LIBPATH"]

    # Define a helper method to split environment variable strings into a dictionary.
    def parse_environment_vars(env_string : String) : Hash(String, String)
      h = Hash(String, String).new
      env_string.each_line do |line|
        next unless line.includes? "="
        ar = line.split("=")
        h[ar[0].strip] = ar[1].strip unless ar.empty?
      end
      h
    end

    def find_vcvars64_bat_file
      latest_path = Crystal::System::VisualStudio.find_latest_msvc_path
      vc_dir = latest_path.try &.each_parent do |p|
        break p if p.basename == "VC"
      end
      bat = vc_dir.try &.join "Auxiliary/Build/vcvars64.bat"
      return bat if bat && File.file? bat
    end

    def run_vcvars_batch(&)
      vc_batch_file = find_vcvars64_bat_file
      if vc_batch_file
        _, new_env = run_vc_batch_file(vc_batch_file)
        with_env(new_env) do
          yield
        end
      end
    end

    def run_vc_batch_file(cmd)
      # Run the VC++ configuration batch file and capture the environment output.
      io_output = IO::Memory.new
      io_error = IO::Memory.new
      vsvars_cmd = %(cmd /C set && cls && "#{cmd}" && cls && set)

      temporary_batch_file = File.tempfile(suffix: ".bat") do |f|
        f.puts vsvars_cmd
      end

      puts "running cmd\n#{vsvars_cmd}"
      status = Process.run(command: "cmd", args: ["/C", temporary_batch_file.path], output: io_output, error: io_error)
      cmd_output = io_output.to_s
      error_output = io_error.to_s

      unless status.success?
        puts "Error #################\n\n"
        puts error_output
      end

      # Split the output into parts.
      cmd_output_parts = cmd_output.split("\f").to_a

      # Ensure there are three parts.
      if cmd_output_parts.size != 3
        raise "Couldn't split the output into pages: #{cmd_output_parts[2]}"
      end

      # Convert the parts to UTF-8 strings.
      old_environment = parse_environment_vars(cmd_output_parts[0])
      vcvars_output = cmd_output_parts[1]
      new_environment = parse_environment_vars(cmd_output_parts[2])

      # Check for error messages in vcvars_output.
      error_messages = vcvars_output.lines.select { |line| line.includes?("[ERROR") && !line.includes?("Error in script usage. the correct usage is:") }
      unless error_messages.empty?
        raise "Invalid parameters\n#{error_messages.join("\n")}"
      end

      {old_environment, new_environment}
    end

    # For env paths that are a collection, normalize values so they only appear once
    def filter_path_value(path : String) : String
      h = Hash(String, String).new
      path.split(";").each_with_object(h) do |p|
        next if h.has_key? p
        h[p] = p
      end
      h.keys.join(";")
    end

    def with_env(env : Hash(String, String), &)
      old_env = Hash(String, String).new
      begin
        env.each do |name, new_value|
          old_value = ENV[name]?
          if old_value.nil? || !(old_value.downcase == new_value.downcase)
            old_env[name] = old_value ? old_value : UNDEF
            if name.in?(PATH_LIKE_VARIABLES)
              effective_value = filter_path_value(new_value)
              ENV[name] = effective_value
            else
              ENV[name] = new_value
            end
          end
        end
        yield
      ensure
        old_env.each do |name, value|
          if value == UNDEF
            ENV.delete(name)
          else
            ENV[name] = value
          end
        end
      end
    end

    # Update environment variables with new values.
    def update_env(old_env, new_env)
      new_env.each do |name, new_value|
        old_value = old_env[name]?
        # Only update if it's a new variable or the value has changed.
        if old_value.nil? || !(old_value.downcase == new_value.downcase)
          if name.in?(PATH_LIKE_VARIABLES)
            effective_value = filter_path_value(new_value)
            ENV[name] = effective_value
          else
            ENV[name] = new_value
          end
        end
      end

      puts "Configured Developer Command Prompt"

      nil
    end
  end
end
