#!/usr/bin/ruby

require 'yaml'

class App
  VERSION = '0.0.1'

  @@vhost_hash_array = []
  @@file_path = "./vhost.yaml"

  def initialize(arguments, stdin)
  end

  def run
    puts "What file would you like to edit? [./vhost.yaml]"
    file_path = stdin_sanitize(gets)
    @@file_path = file_path unless file_path == ""
    if (!File.exist?(@@file_path))
      puts "The file #{@@file_path} does not exist, create it? yes/no"
      create_file = stdin_sanitize(gets)
      if (!create_file)
        notify_nothing_left_to_do
        return
      else
        f = File.new(@@file_path, File::CREAT|File::TRUNC|File::RDWR, 0644)
        f.close()
      end
    else
      @@vhost_hash_array = YAML::load(File.open(@@file_path))
      @@vhost_hash_array = [] unless @@vhost_hash_array
    end

    file_menu_choices
  end

  def file_menu_choices
    puts "What now? show/add/remove/exit"
    action = stdin_sanitize(gets)
    case action
      when "show"
        @@vhost_hash_array.each_with_index do |vhost, idx|
          puts "#{idx}) #{vhost["nickname"]}"
        end if @@vhost_hash_array
        file_menu_choices
      when "add"
        this_vhost = Hash.new
        puts "Provide vhost nickname"
        this_vhost["nickname"] = stdin_sanitize(gets)
        puts "Provide vhost FQDN"
        this_vhost["fqdn"] = stdin_sanitize(gets)
        puts "Provide administrators email address"
        this_vhost["admin_email"] = stdin_sanitize(gets) 

        puts "Does this vhost have aliases? I.E. *.domain.com or domain.com. yes/no"
        has_aliases = (stdin_sanitize(gets) == "yes")
        this_vhost["has_aliases"] = has_aliases
        if (has_aliases)
          aliases = []
          begin
            puts "Provide the alias"
            aliases += [stdin_sanitize(gets)]
            puts "Any more aliases? yes/no"
          end while stdin_sanitize(gets) == "yes"
          this_vhost["aliases"] = aliases
        end

        @@vhost_hash_array += [this_vhost]
        puts "Added #{this_vhost.inspect}..."
        file_menu_choices
      when "exit"
        File.open(@@file_path, "w") do |file|
          file.write(@@vhost_hash_array.to_yaml, File::CREAT|File::TRUNC|File::RDWR, 0644)
          file.close()
        end
    end
  end

  def stdin_sanitize(var)
    var.gsub(/\s+$/, "")
  end

  def notify_nothing_left_to_do
    puts "Welp, looks like there's nothing left to do.  Exitting..."
  end

end

app = App.new(ARGV, STDIN)
app.run