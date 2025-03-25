namespace :version do
  task :bump, [:type] do |t, args|
    args.with_defaults(type: "patch")
    version_file = "lib/bscf/core/version.rb"
    content = File.read(version_file)
    current = content.match(/VERSION = "(.*)"/)[1].split(".").map(&:to_i)

    case args[:type]
    when "major" then current = [ current[0] + 1, 0, 0 ]
    when "minor" then current = [ current[0], current[1] + 1, 0 ]
    when "patch" then current = [ current[0], current[1], current[2] + 1 ]
    end

    new_version = current.join(".")
    new_content = content.gsub(/VERSION = ".*"/, "VERSION = \"#{new_version}\"")
    File.write(version_file, new_content)

    puts "Bumped to version #{new_version}"
  end
end