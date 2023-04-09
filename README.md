# `rbenv-migrate`

Ruby will allow you to require gems installed on a different version managed by
`rbenv`, however when you go to uninstall that Ruby version you will need to
re-install all of your gems. This little script transfers them automatically;
just run it from the Ruby version that you want to migrate *to*, and pass in
the version you wish to migrate *from* as an argument. It will check to see
which of those gems you don't have installed in your current version, and
transfer them if compatible.
