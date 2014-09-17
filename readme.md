# Laravel Homestead + Hostmanager

This is slightly modified version of the official Laravel vagrant box. It allows for simple, on-the-fly hostname management by taking the aliases defined in `Homestead.yaml` and applying them to your local hosts file. No longer do you have to manually edit your hosts file, just change the aliases in `Homestead.yaml` and run `vagrant reload --provision`, that's it!

Official Homestead documentation [is located here](http://laravel.com/docs/homestead?version=4.2).

## Changes from official version

- Gave the machine a name of 'homestead' instead of 'default'
- Added hostmanager configuration to `scripts/homestead.rb`
- Added an array key `name` to sites in `Homestead.yaml`
- Edited `scripts/serve.sh` to accept the name parameter
- Site's `map` key now supports multiple aliases instead of just one
- `serve` command now accepts a third parameter. Usage: `serve [site-name] ["space delimited alias list"] [path/to/web/root]`

## Usage

The official Laravel Homestead [documentation](http://laravel.com/docs/homestead?version=4.2) should be able to answer most of your questions.

To add sites and aliases for hostmanager in Homestead.yaml, just use the following format:

```
sites:
  - name: laravel-app
    map: laravel.app alias.laravel.app alias2.laravel.app
    to: /path/to/laravelapp/public
    
  - name: homestead-app
    map: homestead.app alias.homestead.app other-alias.homestead.app
    to: /path/to/homesteadapp/public
```

`map` is used as the server name in the nginx site config and is also passed to hostmanager as the aliases to homestead's IP on your host machine.
