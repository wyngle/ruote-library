require 'ruby_parser'
require 'sexp_processor'
require 'ruby2ruby'

require 'ruote-library'

require 'rufus-json/automatic'
require 'ruote'
require 'ruote/storage/fs_storage'

require 'singleton'

Dir[File.expand_path( "../support/**/*.rb", __FILE__)].sort.each { |f| require f }

RSpec.configure do |config|
  config.tty = true
  config.mock_with :mocha

  config.before(:all) do
    @dash = Ruote::Dashboard.new(
      Ruote::Worker.new(
        Ruote::FsStorage.new('ruote_work')))
  end
end
