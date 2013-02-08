require 'singleton'
require 'strscan'
require 'ruote/reader'

module Ruote
  # A keeper of books^W processes
  #
  # === Usage
  #   lib = ProcessLibrary.new("/path/to/processes")
  #   pdef_radial = lib.fetch('process_name')
  #
  class ProcessLibrary
    class ProcessNotFound < RuntimeError; end

    # @param [String] root The path to the process library on disk.
    def initialize(root)
      @root = root
    end

    # Fetch a process definition from the library. Possible making it more
    # complete
    #
    # === Fetching referenced
    #
    # Imagine you have these files:
    #   > cat process_one.radial
    #   define process_one
    #     do_something
    #     subprocess ref: process_two
    #
    #   > cat process_two.radial
    #   define process_two
    #     do_something_spectacular
    #     subprocess 'funny/three'
    #
    #   > cat funny/three.radial
    #   define 'funny/three'
    #     be_funny
    #
    # When you do ProcessLibrary.fetch("process_one") you will receive:
    #
    #   define process_one
    #     do_something
    #     subprocess ref: process_two
    #
    #     define process_two
    #       do_something_spectacular
    #       subprocess funny/three
    #
    #     define funny/three
    #       be_funny
    #
    # In other words: fetch() loads any referenced subprocess that are not
    # defined in the original definition.
    #
    # === Including referenced
    #
    # Image you have thses files:
    #   > cat base.radial
    #   define base
    #     alpha
    #     bravo
    #     charly
    #
    #   > cat extended.radial
    #   define extended
    #     taste_soup
    #       concurrence
    #          lib_include base
    #
    # When you fetch extended, you will receive
    #
    #   define extended
    #      taste_soup
    #      concurrence
    #        alpha
    #        bravo
    #        charly
    #
    # === Notice the missing single-quotes?
    # Because the ProcessLibrary turns all files into Radial (even though it
    # already is a Radial) it performs some optimizing
    #
    # === Caveat
    # In order for this to work you must:
    #
    # * Name your files like your (sub)processes, including path from @root
    #
    # * Use the 'subprocess' expression
    #   (see: http://ruote.rubyforge.org/exp/subprocess.html)
    #   otherwise the library will not be able to tell the diference between a
    #   participant and a subprocess
    #
    # * You cannot have a participant called 'lib_include' if you want to use
    #   the inclusion mechanism
    #
    # === Note on inclusion
    # 'lib_include' was added as a way to keep the definitions tree simple, it
    # has no other sane use-case
    #
    # @param [String] name The name of the file to fetch
    # @return [String] radial process definition (regardless of what was in
    #   the file)
    def fetch(name, indent=0)
      # turn into a radial, with the given indent depth
      radial = ::Ruote::Reader.to_radial(
        ::Ruote::Reader.read(self.read(name)),
        indent
      )

      # check if the radial references any subprocesses not defined in this
      # definition and fetch-and-append them
      #
      if radial =~ /subprocess/
        # find the subs
        subs = radial.scan(/subprocess (.+)$/).flatten.map do |sub|
          sub.split(/, ?/).first.gsub(/[\'\"]/, '').gsub('ref: ', '')
        end

        # find the definitions
        defines = radial.scan(/define (.+)$/).flatten.map do |define|
          define.gsub(/[\'\"]/, '').gsub('name: ', '')
        end

        # substract the defs from the subs and load the remaining subs
        subs -= defines
        subs.each do |sub|
          radial += "\n" + fetch(sub, 1) + "\n"
        end
      end

      if radial =~ /lib_include/
        extras = radial.scan(/^(\s+)lib_include (.+)$/).map do |indent, process|
          sub_process = fetch(process, (indent.length / 2) - 1)
          replacement = sub_process.split("\n")[1..-1].join("\n")
          radial.gsub!("#{indent}lib_include #{process}", replacement)
        end
      end

      return radial
    end

    # Read a process definition from file
    #
    # @param [String] name The name of the process - should be the filename,
    #   the extension is optional and tried in the order .radial, .json and
    #   finaly .xml
    #
    # @return [String] The contents of the first found file
    #
    def read(name)
      path = File.join(@root, name)
      return File.read(path) if File.exists?(path)

      %w[radial json xml].each do |ext|
        ext_path = path + ".#{ext}"
        return File.read(ext_path) if File.exists?(ext_path)
      end

      raise ProcessNotFound,
        "Coud not find a process named: #{name}[.radial|.json|.xml] in #{@root}"
    end
  end
end
