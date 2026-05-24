env_file = Rails.root.join(".env")

if env_file.exist?
  env_file.each_line do |line|
    stripped = line.strip
    next if stripped.blank? || stripped.start_with?("#") || !stripped.include?("=")

    key, value = stripped.split("=", 2)
    ENV[key] ||= value.to_s
  end
end
