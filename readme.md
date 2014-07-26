# Laravel Homestead + Hostmanager

The official Laravel local development environment slightly edited to allow vagrant-hostmanager to use site maps as aliases in `/etc/hosts`.

Official Homestead documentation [is located here](http://laravel.com/docs/homestead?version=4.2).

## Key differences

- Gave the machine a name of 'homestead' instead of 'default'
- Added hostmanager configuration to `scripts/homestead.rb`
- Added an array key `name` to sites in `Homestead.yaml`
- Edited `scripts/serve.sh` to accept the name parameter
- Site's `map` key now supports aliases instead of just a single domain
- `serve` command now accepts a third parameter. Usage: `serve site-name "domain(s)" path`

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
