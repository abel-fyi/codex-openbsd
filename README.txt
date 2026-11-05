CODEX

Codex 0.166.0 for OpenBSD 8.0/amd64.
A terminal coding agent from OpenAI.


BUILD

  ./build.sh builds the package.
  The first build downloads sources and dependencies.
  Builds can take hours. Output is saved to build.log.

Needs OpenBSD 8.0/amd64, doas, an internet connection,
and an 8 GB data-size limit. The port uses one build
job to fit available memory.


INSTALL

  ./install.sh
  ./install.sh /path/to/codex-0.166.0.tgz

The first command installs the package built by build.sh.
The second installs the package at the path you give.
The package is unsigned; install.sh allows unsigned packages.


USE

Run Codex from the project directory you want to work in:

  codex

Codex includes a code-mode host at
/usr/local/bin/codex-code-mode-host.


FILES

  port/codex/   OpenBSD build recipe and patches
  package/      Local package, checksum, and public key
  .work/        Downloads, build cache, and object files
  build.sh      Build the package
  install.sh    Install the package
  test.sh       Check the installed version and host

Keep .work/ to reuse build files on the next build.
