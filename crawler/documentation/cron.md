# Cron usage

If any of the perl requirements are not installed globally or with the system package manager,
make sure to export the custom lib path.

Example:

```
#!/bin/bash

PATH="/home/user/perl5/bin${PATH:+:${PATH}}"; export PATH;
PERL5LIB="/home/user/perl5/lib/perl5${PERL5LIB:+:${PERL5LIB}}"; export PERL5LIB;

cd /home/user/aranea/crawler
./aranea-runner

```

The `PERL5LIB` can be found in the user `.bashrc` if cpan is used.
