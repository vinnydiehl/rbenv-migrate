# `rbenv-migrate`

Ruby will allow you to require gems installed on a different version managed by
`rbenv`, however when you go to uninstall that Ruby version you will need to
re-install all of your gems. This little script transfers them automatically;
just run it from the Ruby version that you want to migrate *to*, and pass in
the version you wish to migrate *from* as an argument. It will check to see
which of those gems you don't have installed in your current version, and
transfer them if compatible.

## Usage

For example, to upgrade Ruby 3.1.0 to 3.2.1:

<!--- Yeah, it's Python syntax highlighting. The bash
    highlighting just highlights "local" and looks fugly. --->
```python
rbenv install 3.2.1
rbenv local 3.2.1    # set Ruby to target version
rbenv-migrate 3.1.0  # pass the old version as an argument
# all of your compatible gems from 3.1.0 will install to 3.2.1
rbenv uninstall 3.1.0 # now safe to uninstall
```
