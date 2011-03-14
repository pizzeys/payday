# Load everything in the local folder
I18n.load_path.concat(Dir[File.join(File.dirname(__FILE__), "payday", "locale", "*.yml")])