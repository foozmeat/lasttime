# For more information about each property, visit the GitHub documentation: https://github.com/krausefx/deliver
# Everything next to a # is a comment and will be ignored

email 'hello@jmoore.me'
hide_transporter_output # remove the '#' in the beginning of the line, to hide the output while uploading

########################################
# App Metadata
########################################

# The app identifier is required
app_identifier "me.jmoore.LastTime"
apple_id "493863358"

# This folder has to include one folder for each language
# More information about automatic screenshot upload: 
screenshots_path "./deliver/screenshots/"

version '1.6.1' # you can pass this if you want to verify the version number with the ipa file

config_json_folder './deliver'

success do
  system("say 'Successfully deployed a new version.'")
end