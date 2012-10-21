# ruote-library

A process library for Ruote

## Usage

```ruby
require 'ruote-library'

library = Ruote::ProcessLibrary.new("/path/to/processes")
radial_pdef = library.fetch "some_process"

dashboard.launch(radial_pdef, workitem, vars)
```

## Contributing

Contributions are most welcome - please follow this convention:

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
