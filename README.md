# Threatinator
Threatinator is a ruby library for parsing threat data feeds. It is a component of [Cikl](https://github.com/cikl/cikl), a threat intelligence management system. 
## Source code repository

The repository is located at: https://github.com/cikl/threatinator

## Development

First, set up your dependencies.

```
bundle install
```

### Listing feeds

```
bundle exec bin/threatinator list
```

### Running a feed

```
bundle exec bin/threatinator run alienvault ip_reputation
```

### Getting help

All commands respond to '--help' to provide details on their usage. 

```
bundle exec bin/threatinator run --help
```

## Contributing and Issue Tracking

Before you file a bug or submit a pull request, please review our 
[contribution guidelines](https://github.com/cikl/cikl/wiki/Contributing).

All issues are managed within the primary repository: [cikl/cikl/issues](https://github.com/cikl/cikl/issues). Pull requests should be sent to their respective reposirotires, referencing some issue within the main project repository.

## License
Copyright (C) 2014 Michael Ryan (github.com/justfalter)

See the LICENSE file for license rights and limitations (LGPLv3).
