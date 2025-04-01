FROM alpine:latest
ARG url=https://gitlab.com/evlaV/srcpkg2git/-/raw/master
ARG workdir=/tmp/srcpkg2git
WORKDIR $workdir
ENV SRCPKG_AUTO=1
RUN apk update

# dependencies
# srcpkg-dl, srcpkg2git, git-remote, git-credential-bashelper + git-credential-shelper, git-commit (all)
RUN apk add bash
# srcpkg-dl
RUN apk add curl grep libxml2-dev
# srcpkg2git
RUN apk add git tar
# git-remote, git-credential-bashelper + git-credential-shelper, git-commit (git-*)
#RUN apk add git

# optional dependencies
# srcpkg-dl, srcpkg2git, git-remote + git-commit
#RUN apk add coreutils openssl util-linux vim
RUN apk add coreutils
# srcpkg2git
#RUN apk add curl findutils
RUN apk add findutils

# remote programs
RUN echo -e "downloading/using srcpkg2git\nurl: $url"
ADD --chmod=755 $url/srcpkg-dl.sh /usr/bin/srcpkg-dl
ADD --chmod=755 $url/srcpkg2git.sh /usr/bin/srcpkg2git
ADD --chmod=755 $url/lib/git-remote.sh /usr/bin/git-remote
ADD --chmod=755 $url/lib/git-credential-bashelper.sh /usr/bin/git-credential-bashelper
#ADD --chmod=755 $url/lib/git-credential-shelper.sh /usr/bin/git-credential-shelper
ADD --chmod=755 $url/lib/git-commit.sh /usr/bin/git-commit
# local configs
COPY --chmod=644 srcpkg-dl.conf git-remote.conf /etc/
# remote configs (template)
#ADD --chmod=644 $url/config/srcpkg-dl.conf.template /etc/srcpkg-dl.conf
#ADD --chmod=644 $url/config/git-remote.conf.template /etc/git-remote.conf

# copy/configure password file (pwdfile/passwdfile) - git-remote.conf
#ARG pwdfile=pwdfile
#ARG pwdfile=passwdfile
#RUN apk add sed
#COPY --chmod=644 $pwdfile .
#RUN sed -i '$d' /etc/git-remote.conf
#RUN echo "[[ -z \$git_remote_password_file ]] && git_remote_password_file=\"$workdir/${pwdfile##*/}\"" >> /etc/git-remote.conf

CMD ["srcpkg-dl", "--auto"]
