FROM alpine:latest
ARG url=https://gitlab.com/evlaV/srcpkg2git/-/raw/master
ARG workdir=/tmp/srcpkg2git
WORKDIR $workdir
RUN apk update

# dependencies
# srcpkg2git, git-remote, git-credential-bashelper + git-credential-shelper, git-commit (all)
RUN apk add bash
# srcpkg2git
RUN apk add git tar
# git-remote, git-credential-bashelper + git-credential-shelper, git-commit (git-*)
#RUN apk add git

# optional dependencies
# srcpkg2git, git-remote + git-commit
#RUN apk add coreutils openssl util-linux vim
RUN apk add coreutils
# srcpkg2git
RUN apk add curl findutils

# remote programs
RUN echo -e "downloading/using srcpkg2git\nurl: $url"
ADD --chmod=755 $url/srcpkg2git.sh /usr/bin/srcpkg2git
ADD --chmod=755 $url/lib/git-remote.sh /usr/bin/git-remote
ADD --chmod=755 $url/lib/git-credential-bashelper.sh /usr/bin/git-credential-bashelper
#ADD --chmod=755 $url/lib/git-credential-shelper.sh /usr/bin/git-credential-shelper
ADD --chmod=755 $url/lib/git-commit.sh /usr/bin/git-commit
# local configs
COPY --chmod=644 git-remote.conf /etc/
# remote configs (template)
#ADD --chmod=644 $url/config/git-remote.conf.template /etc/git-remote.conf

# copy/configure password file (pwdfile/passwdfile) - git-remote.conf
#ARG pwdfile=pwdfile
#ARG pwdfile=passwdfile
#RUN apk add sed
#COPY --chmod=644 $pwdfile .
#RUN sed -i '$d' /etc/git-remote.conf
#RUN echo "[[ -z \$git_remote_password_file ]] && git_remote_password_file=\"$workdir/${pwdfile##*/}\"" >> /etc/git-remote.conf

CMD ["srcpkg2git"]
