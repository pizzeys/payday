# Load everything in the local folder
I18n.enforce_available_locales = false
I18n.load_path.concat(Dir[File.join(File.dirname(__FILE__), "locale", "*.yml")])
