module Token
  module Config
    def self.load
      p Rails.root
      p File.exists?("#{::Rails.root}/config/token.yml")
      config_options = {}
    
      File.open("#{::Rails.root}/config/token.yml") do |f|
        p f
        file_options = YAML::load(ERB.new(f.read).result).symbolize_keys
        file_options.each do |k, v|
          config_options[k] = v.symbolize_keys!
        end if file_options
      config_options
      end if File.exists?("#{::Rails.root}/config/token.yml")
    end
  
    def root
      Rails.root.join(config_folder)
    end

    def configuration_files
      app = Typus.root.join("*.yml")
      plugins = Rails.root.join("vendor", "plugins", "*", "config", "typus", "*.yml")
      Dir[app, plugins].reject { |f| f.match(/_roles.yml/) }.sort
    end
  end
end