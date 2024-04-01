#!/bin/sh
# don't quote $appimage_zsync_arg
#appimage_zsync_arg=
#appimage_zsync_url=
# set to automatically set $appimage_zsync_arg and $appimage_zsync_url
#appimage_zsync_url_dir=
#appimagetool_file=
#appimagetool_url=
#arch=
cdir=$PWD
#clean=
#docker=
#epoch=
#flatpak_manifest
#gdir=
#gitdir=
#git_remote_url=
#git_update=
#image_bin=
#made_source_dir=
#odir=
#project=
#rm_git_remote_conf=
#rm_srcpkg_dl_conf=
#skip_appimage=
#skip_flatpak=
#skip_image=
#skip_srcpkg=
#skip_tar=
#skip_zip=
#tar_lzip=
#tar_zstd=
#update_appimagetool=
#ver=
#version=
echo

[ -z "$project" ] && project=srcpkg2git
[ -z "$version" ] && version=0.1

for args; do
  case $args in
    -c|--clean|clean)
      clean=1
      ;;
    -h|--help|help)
      [ "$0" = "${0#/*}" ] && bin_str=$0 || bin_str=${0##*/}
      echo "usage:"
      echo "  $bin_str [version] [-c] [-h] [-u]"
      echo
      echo " e.g.:"
      echo "  $bin_str ${version:-0.1} -c"
      echo
      echo "positional arguments:"
      echo "  version          version number (e.g., ${version:-0.1})"
      echo
      echo "options:"
      #echo "  -c, --clean      clean/remove (temporary) source dir (${project:=srcpkg2git}/) after make"
      echo "  -c, --clean      clean/remove (temporary) source dir (${project:-srcpkg2git-0.1}/) after make"
      echo "  -h, --help       show this help message and exit"
      echo "  -u, --update     sync/update git repository (git pull) before make"
      echo
      echo "  --skip-appimage  skip making AppImage releases"
      echo "  --skip-flatpak   skip making Flatpak releases"
      echo "  --skip-image     skip image/container releases"
      echo "  --skip-srcpkg    skip making srcpkg releases"
      echo "  --skip-tar       skip making tarball (tar.*) releases"
      echo "  --skip-zip       skip making zip release"
      echo
      echo "  --docker         use 'docker' instead of 'podman' to make image/container"
      echo "  --tar-lzip       use 'tar' instead of 'lzip' to make tar.lzip"
      echo "  --tar-zstd       use 'tar' instead of 'zstd' to make tar.zst"
      echo "  --update-ait     force update (remove/redownload) appimagetool.AppImage"
      exit 0
      ;;
    -u|--update|update|--git-update|git-update)
      git_update=1
      ;;
    --skip-appimage)
      skip_appimage=1
      ;;
    --skip-flatpak)
      skip_flatpak=1
      ;;
    --skip-image|--skip-container)
      skip_image=1
      ;;
    --skip-srcpkg)
      skip_srcpkg=1
      ;;
    --skip-tar)
      skip_tar=1
      ;;
    --skip-zip)
      skip_zip=1
      ;;
    --tar-lzip)
      tar_lzip=1
      ;;
    --tar-zstd)
      tar_zstd=1
      ;;
    --update-ait|--update-appimagetool|--force-update-ait|--force-update-appimagetool)
      update_appimagetool=1
      ;;
    *)
      echo "version: $args"
      version=$args
      #echo "version: $version"
      echo
      ;;
  esac
done

# 2022-04-01 12:00:00 -0700
#[ -z "$epoch" ] && epoch=1648839600
# 2023-04-01 12:00:00 -0700
#[ -z "$epoch" ] && epoch=1680375600
# 2024-04-01 12:00:00 -0700
#[ -z "$epoch" ] && epoch=1711998000
# 2025-04-01 12:00:00 -0700
#[ -z "$epoch" ] && epoch=1743534000
[ -z "$epoch" ] && epoch=0
[ -z "$git_remote_url" ] && git_remote_url=https://gitlab.com/evlaV/srcpkg2git.git
#[ -z "$version" ] && ver=-0.1 || ver=-$version
[ -n "$version" ] && ver=-$version || ver=

srcpkg_tgz_file=${project:=srcpkg2git}$ver.src.tar.gz
srcpkg_txz_file=${project:=srcpkg2git}$ver.src.tar.xz

tar_file=${project:=srcpkg2git}$ver.tar
#tbz2_file=${project:=srcpkg2git}$ver.tar.bz2
tbz2_file=$tar_file.bz2
#tgz_file=${project:=srcpkg2git}$ver.tar.gz
tgz_file=$tar_file.gz
#tlz_file=${project:=srcpkg2git}$ver.tar.lz
tlz_file=$tar_file.lz
#tlzma_file=${project:=srcpkg2git}$ver.tar.lzma
tlzma_file=$tar_file.lzma
#txz_file=${project:=srcpkg2git}$ver.tar.xz
txz_file=$tar_file.xz
#tzst_file=${project:=srcpkg2git}$ver.tar.zst
tzst_file=$tar_file.zst

zip_file=${project:=srcpkg2git}$ver.zip

make_source_dir() {
# remove source dir (clean)
rm -fr "${project:=srcpkg2git}$ver"/
# make source dir
mkdir -p "${project:=srcpkg2git}$ver"
# make source dir and srcpkg dir
#mkdir -p "${project:=srcpkg2git}$ver/${project:=srcpkg2git}"
#mkdir -p "${project:=srcpkg2git}$ver/${project:=srcpkg2git}/${project:=srcpkg2git}"
if [ -z "$skip_srcpkg" ] && [ -d ".git" ]; then
  # make srcpkg dir - requires remove srcpkg dir (clean) below
  cp -afr .git/ "${project:=srcpkg2git}$ver/${project:=srcpkg2git}"
  #cp -afr .git/ "${project:=srcpkg2git}$ver/${project:=srcpkg2git}/${project:=srcpkg2git}"
  # use existing srcpkg dir - requires make source dir and srcpkg dir above
  #cp -afr .git/* "${project:=srcpkg2git}$ver/${project:=srcpkg2git}"/
  #cp -afr .git/* "${project:=srcpkg2git}$ver/${project:=srcpkg2git}/${project:=srcpkg2git}"/
fi
# AppImage (symlink -> file)
cp -afLr appimage/ "${project:=srcpkg2git}$ver"/ || exit 1
# bash
#cp -afr alpm/ appstream/ config/ Containerfile cron/ Dockerfile git-commit.sh git-credential-bashelper.sh git-credential-shelper.sh git-remote.sh images/ io.gitlab.evlaV.{srcpkg2git,srcpkg-dl,srcpkg-dl-bot}.yaml lib/ LICENSE LICENSE.GPL LICENSE.MPL Makefile make-release.sh README.html README.md {srcpkg2git,srcpkg-dl,srcpkg-dl-bot}-{local,remote,remote-tag}.Containerfile {srcpkg2git,srcpkg-dl,srcpkg-dl-bot}{-local,-remote,}.yaml srcpkg2git.mk srcpkg2git.sh srcpkg-dl-bot.mk srcpkg-dl.mk srcpkg-dl.sh systemd/ tools/ xdg/ "${project:=srcpkg2git}$ver"/ || exit 2
# sh
cp -afr alpm/ appstream/ config/ Containerfile cron/ Dockerfile git-commit.sh git-credential-bashelper.sh git-credential-shelper.sh git-remote.sh images/ io.gitlab.evlaV.srcpkg2git.yaml io.gitlab.evlaV.srcpkg-dl-bot.yaml io.gitlab.evlaV.srcpkg-dl.yaml lib/ LICENSE LICENSE.GPL LICENSE.MPL Makefile make-release.sh README.html README.md srcpkg2git-local.Containerfile srcpkg2git-local.yaml srcpkg2git.mk srcpkg2git-remote.Containerfile srcpkg2git-remote.yaml srcpkg2git-remote-tag.Containerfile srcpkg2git.sh srcpkg2git.yaml srcpkg-dl-bot-local.Containerfile srcpkg-dl-bot-local.yaml srcpkg-dl-bot.mk srcpkg-dl-bot.yaml srcpkg-dl-bot-remote.Containerfile srcpkg-dl-bot-remote.yaml srcpkg-dl-bot-remote-tag.Containerfile srcpkg-dl-local.Containerfile srcpkg-dl-local.yaml srcpkg-dl.mk srcpkg-dl-remote.Containerfile srcpkg-dl-remote.yaml srcpkg-dl-remote-tag.Containerfile srcpkg-dl.sh srcpkg-dl.yaml systemd/ tools/ xdg/ "${project:=srcpkg2git}$ver"/ || exit 2
# timestamp source dir
if hash touch 2>/dev/null; then
  # bash 4.0+
  #for file in "${project:=srcpkg2git}$ver"/**/*; do
  # sh
  # '"${project:=srcpkg2git}$ver"/*/*/*/*/*/*' (and maybe '"${project:=srcpkg2git}$ver"/*/*/*/*/*/*/*') used for srcpkg dir (e.g., $project/logs/refs/remotes/origin/HEAD)
  for file in "${project:=srcpkg2git}$ver"/*/*/*/*/*/* "${project:=srcpkg2git}$ver"/*/*/*/*/* "${project:=srcpkg2git}$ver"/*/*/*/* "${project:=srcpkg2git}$ver"/*/*/* "${project:=srcpkg2git}$ver"/*/*/.* "${project:=srcpkg2git}$ver"/*/* "${project:=srcpkg2git}$ver"/* "${project:=srcpkg2git}$ver"; do
    if [ -e "$file" ]; then
      #touch -d @0 -h "$file"
      touch -d @"${epoch:=0}" -h "$file"
    fi
  done
fi
made_source_dir=1
}

if hash git 2>/dev/null; then
  gitdir=$(git rev-parse --show-toplevel 2>/dev/null)
fi
#if [ -d "$gitdir" ] && [ "$gitdir" != "$cdir" ]; then
if [ -d "$gitdir" ] && [ "$gitdir" != "$PWD" ]; then
  #echo "changed directory ($gitdir)"
  #echo "changed directory ($PWD -> $gitdir)"
  #echo "changed to ${project:=srcpkg2git} git root directory: $gitdir"
  cd "$gitdir" || exit 3
  #echo "changed directory ($PWD)"
  #echo "changed directory ($cdir -> $PWD)"
  echo "changed to ${project:=srcpkg2git} git root directory: $PWD"
  echo
  odir=$cdir
  #cdir=$gitdir
  cdir=$PWD
# tools/ -> .. or dir/ -> ..
#elif [ "${PWD##*/}" = "tools" ] || [ ! -e "srcpkg2git.sh" ] && [ -e "../srcpkg2git.sh" ]; then
elif [ "${PWD##*/}" = "tools" ] || [ ! -f "srcpkg2git.sh" ] && [ -f "../srcpkg2git.sh" ]; then
  cd ..
  #echo "changed directory ($PWD)"
  #echo "changed directory ($cdir -> $PWD)"
  echo "changed to ${project:=srcpkg2git} git root directory: $PWD"
  echo
  odir=$cdir
  cdir=$PWD
fi

# git update
if [ -n "$git_update" ]; then
  if hash git 2>/dev/null; then
    if [ -d ".git" ]; then
      git pull --rebase || exit 4
      # git clean (git gc)
      #git gc
      #git gc --prune=now
      git gc --aggressive --prune=now
    elif [ -d "${project:=srcpkg2git}/.git" ]; then
      cd "${project:=srcpkg2git}" || exit 5
      #echo "changed directory ($PWD)"
      #echo "changed directory ($cdir -> $PWD)"
      echo "changed to ${project:=srcpkg2git} (sub) git root directory: $PWD"
      echo
      #odir=$cdir
      #cdir=$PWD
      gdir=$PWD
      git pull --rebase || exit 4
      # git clean (git gc)
      #git gc
      #git gc --prune=now
      git gc --aggressive --prune=now
    #elif [ ! -d "${project:=srcpkg2git}" ]; then
    else
      rm -fr "${project:=srcpkg2git}"/
      git clone "${git_remote_url:=https://gitlab.com/evlaV/srcpkg2git.git}" "${project:=srcpkg2git}" || exit 6
      cd "${project:=srcpkg2git}" || exit 5
      #echo "changed directory ($PWD)"
      #echo "changed directory ($cdir -> $PWD)"
      echo "changed to ${project:=srcpkg2git} (sub) git root directory: $PWD"
      echo
      #odir=$cdir
      #cdir=$PWD
      gdir=$PWD
    fi
  else
    echo "error: git not found! install git to download/sync/update ${project:=srcpkg2git} source"
    echo
    exit 7
  fi
fi

# template -> config (.conf.template -> .conf)
[ ! -s "git-remote.conf" ] && [ -s "config/git-remote.conf.template" ] && cp -af config/git-remote.conf.template git-remote.conf && rm_git_remote_conf=1
[ ! -s "srcpkg-dl.conf" ] && [ -s "config/srcpkg-dl.conf.template" ] && cp -af config/srcpkg-dl.conf.template srcpkg-dl.conf && rm_srcpkg_dl_conf=1

if [ -z "$made_source_dir" ]; then
  make_source_dir
fi

# make tarball (tar.*) releases
if hash tar 2>/dev/null; then
  if [ -z "$skip_srcpkg" ]; then
    # make srcpkg releases
    if [ -d "${project:=srcpkg2git}$ver/${project:=srcpkg2git}" ]; then
      # make tar.gz srcpkg release
      #echo "making srcpkg: $srcpkg_tgz_file"
      echo "making srcpkg ($srcpkg_tgz_file)"
      echo
      GZIP=-9 tar -cpvzf "${srcpkg_tgz_file:?}" "${project:=srcpkg2git}$ver/${project:=srcpkg2git}"/
      echo
      # make tar.xz srcpkg release
      #echo "making srcpkg: $srcpkg_txz_file"
      echo "making srcpkg ($srcpkg_txz_file)"
      echo
      XZ_OPT=-9 tar -cJpvf "${srcpkg_txz_file:?}" "${project:=srcpkg2git}$ver/${project:=srcpkg2git}"/
      echo
      # remove srcpkg dir (clean)
      rm -fr "${project:=srcpkg2git}$ver/${project:=srcpkg2git}"/
    fi
  else
    echo "skipped making srcpkg releases"
    echo
  fi
  if [ -z "$skip_tar" ]; then
    # make tar release
    echo "making $tar_file"
    echo
    tar -cpvf "${tar_file:?}" "${project:=srcpkg2git}$ver"/
    echo
    # make tar.bz2 release
    echo "making $tbz2_file"
    echo
    BZIP2=-9 tar -cjpvf "${tbz2_file:?}" "${project:=srcpkg2git}$ver"/
    echo
    # make tar.gz release
    echo "making $tgz_file"
    echo
    GZIP=-9 tar -cpvzf "${tgz_file:?}" "${project:=srcpkg2git}$ver"/
    echo
    # make tar.lz release
    echo "making $tlz_file"
    echo
    if hash lzip 2>/dev/null && [ -z "$tar_lzip" ]; then
      tar -I 'lzip -9' -cpvf "${tlz_file:?}" "${project:=srcpkg2git}$ver"/
    else
      if [ -z "$tar_lzip" ]; then
        echo "warning: lzip not found! using 'tar --lzip' instead of 'lzip'"
        echo
      fi
      tar --lzip -cpvf "${tlz_file:?}" "${project:=srcpkg2git}$ver"/
    fi
    echo
    # make tar.lzma release
    echo "making $tlzma_file"
    echo
    #tar -I 'xz --format=lzma -9' -cpvf "${tlzma_file:?}" "${project:=srcpkg2git}$ver"/
    # 'xz --format=lzma' alias
    #tar -I 'lzma -9' -cpvf "${tlzma_file:?}" "${project:=srcpkg2git}$ver"/
    XZ_OPT=-9 tar --lzma -cpvf "${tlzma_file:?}" "${project:=srcpkg2git}$ver"/
    echo
    # make tar.xz release
    echo "making $txz_file"
    echo
    XZ_OPT=-9 tar -cJpvf "${txz_file:?}" "${project:=srcpkg2git}$ver"/
    echo
    # make tar.zst release
    echo "making $tzst_file"
    echo
    if hash zstd 2>/dev/null && [ -z "$tar_zstd" ]; then
      tar -I 'zstd -19' -cpvf "${tzst_file:?}" "${project:=srcpkg2git}$ver"/
    else
      if [ -z "$tar_zstd" ]; then
        echo "warning: zstd not found! using 'tar --zstd' instead of 'zstd'"
        echo
      fi
      ZSTD_CLEVEL=19 tar --zstd -cpvf "${tzst_file:?}" "${project:=srcpkg2git}$ver"/
    fi
    echo
  else
    echo "skipped making tarball (tar.*) releases"
    echo
  fi
else
  #echo "error: tar not found! install tar to make:"
  echo "warning: tar not found! install tar to make:"
  echo "$srcpkg_tgz_file"
  echo "$srcpkg_txz_file"
  echo
  echo "$tar_file"
  echo "$tbz2_file"
  echo "$tgz_file"
  echo "$tlz_file"
  echo "$tlzma_file"
  echo "$txz_file"
  echo "$tzst_file"
  echo
  #exit 8
fi

if [ -z "$skip_zip" ]; then
  # make zip release
  if hash zip 2>/dev/null; then
    echo "making $zip_file"
    echo
    zip -r "${zip_file:?}" "${project:=srcpkg2git}$ver"/
    echo
  else
    #echo "error: zip not found! install zip to make:"
    echo "warning: zip not found! install zip to make:"
    echo "$zip_file"
    echo
    #exit 9
  fi
else
  echo "skipped making zip release"
  echo
fi

# timestamp releases
if hash touch 2>/dev/null; then
  for file in $srcpkg_tgz_file $srcpkg_txz_file $tar_file $tbz2_file $tgz_file $tlz_file $tlzma_file $txz_file $tzst_file $zip_file; do
    #if [ -e "$file" ]; then
    if [ -f "$file" ]; then
      #touch -d @0 "$file"
      touch -d @"${epoch:=0}" "$file"
    fi
  done
fi

if [ -z "$skip_appimage" ]; then
  # make AppImage releases
  # set to automatically set $appimage_zsync_arg and $appimage_zsync_url
  [ -z "$appimage_zsync_url_dir" ] && appimage_zsync_url_dir=
  # detect architecture
  if [ -z "$arch" ]; then
    if hash uname 2>/dev/null; then
      arch=$(uname -m)
      # armv7* -> armhf
      case $arch in
        armv7*)
          [ "$arch" != "armhf" ] && echo "architecture: $arch -> armhf"
          arch=armhf
          ;;
      esac
    else
      #arch=aarch64
      arch=x86_64
      #echo "assuming (ASS-U-ME) architecture ($arch)"
      echo "assuming (ASS-U-ME) architecture: $arch"
      echo
    fi
  fi
  # download appimagetool
  [ -z "$appimagetool_file" ] && appimagetool_file=appimagetool-$arch.AppImage
  [ -z "$appimagetool_url" ] && appimagetool_url=https://github.com/AppImage/appimagetool/releases/download/continuous/$appimagetool_file
  [ -n "$update_appimagetool" ] && rm -f "${appimagetool_file:=appimagetool-x86_64.AppImage}"
  #if [ ! -s "$appimagetool_file" ]; then
  if [ ! -s "${appimagetool_file:=appimagetool-x86_64.AppImage}" ]; then
    #echo "downloading ($arch) appimagetool (${appimagetool_url:=https://github.com/AppImage/appimagetool/releases/download/continuous/$appimagetool_file})"
    echo "downloading ($arch) appimagetool: ${appimagetool_url:=https://github.com/AppImage/appimagetool/releases/download/continuous/$appimagetool_file}"
    echo
    if hash curl 2>/dev/null; then
      curl -Lo "$appimagetool_file" "${appimagetool_url:=https://github.com/AppImage/appimagetool/releases/download/continuous/$appimagetool_file}" || exit 10
    elif hash wget 2>/dev/null; then
      wget -O "$appimagetool_file" "${appimagetool_url:=https://github.com/AppImage/appimagetool/releases/download/continuous/$appimagetool_file}" || exit 11
    else
      echo "error: curl or wget not found! install curl or wget to download appimagetool"
      echo
      echo "or:"
      echo "1. manually download: ${appimagetool_url:=https://github.com/AppImage/appimagetool/releases/download/continuous/$appimagetool_file}"
      echo "2. save as: $PWD/$appimagetool_file"
      echo "3. set the executable mode bit: chmod +x \"$appimagetool_file\""
      echo
      echo "or:"
      echo "use option '--skip-appimage' to skip making AppImage releases"
      echo
      exit 12
    fi
    echo
    #if [ ! -x "$appimagetool_file" ]; then
    if [ ! -x "${appimagetool_file:=appimagetool-x86_64.AppImage}" ]; then
      if ! hash chmod 2>/dev/null || ! chmod +x "$appimagetool_file"; then
        echo "error: $appimagetool_file executable mode bit not set!"
        echo
        echo "set the executable mode bit: chmod +x \"$appimagetool_file\""
        echo
        exit 13
      fi
    fi
  fi
  #if [ -s "$appimagetool_file" ]; then
  if [ -s "${appimagetool_file:=appimagetool-x86_64.AppImage}" ]; then
    export ARCH
    for ARCH in aarch64 armhf i686 x86_64; do
      for VAR in srcpkg2git srcpkg-dl srcpkg-dl-bot; do
        [ -n "$appimage_zsync_url_dir" ] && appimage_zsync_url=$appimage_zsync_url_dir/$VAR$ver-$ARCH.AppImage.zsync || appimage_zsync_url=
        [ -n "$appimage_zsync_url" ] && appimage_zsync_arg="-u zsync|$appimage_zsync_url" || appimage_zsync_arg=
        #if [ -d "$project$ver/appimage/$VAR" ]; then
        if [ -d "${project:=srcpkg2git}$ver/appimage/$VAR" ]; then
          #echo "making $VAR ($ARCH) AppImage: $VAR$ver-$ARCH.AppImage (with ${project:=srcpkg2git}$ver/appimage/$VAR/)"
          echo "making $VAR ($ARCH) AppImage ($VAR$ver-$ARCH.AppImage) with ${project:=srcpkg2git}$ver/appimage/$VAR/"
          echo
          # $project$ver/appimage/$VAR/
          # make AppImage release ($VAR)
          #ARCH=$ARCH ./"$appimagetool_file" "${project:=srcpkg2git}$ver"/appimage/"$VAR" $appimage_zsync_arg
          #ARCH=$ARCH ./"$appimagetool_file" "${project:=srcpkg2git}$ver/appimage/$VAR" $appimage_zsync_arg
          #ARCH=$ARCH ./"$appimagetool_file" "${project:=srcpkg2git}$ver"/appimage/"$VAR" "$VAR$ver-$ARCH".AppImage $appimage_zsync_arg
          #ARCH=$ARCH ./"$appimagetool_file" "${project:=srcpkg2git}$ver/appimage/$VAR" "$VAR$ver-$ARCH".AppImage $appimage_zsync_arg
          # requires export ARCH above
          #./"$appimagetool_file" "${project:=srcpkg2git}$ver"/appimage/"$VAR" $appimage_zsync_arg
          #./"$appimagetool_file" "${project:=srcpkg2git}$ver/appimage/$VAR" $appimage_zsync_arg
          #./"$appimagetool_file" "${project:=srcpkg2git}$ver"/appimage/"$VAR" "$VAR$ver-$ARCH".AppImage $appimage_zsync_arg
          ./"$appimagetool_file" "${project:=srcpkg2git}$ver/appimage/$VAR" "$VAR$ver-$ARCH".AppImage $appimage_zsync_arg
        elif [ -d "appimage/$VAR" ]; then
          # symlink -> file ($VAR/ -> $VAR.AppDir/)
          # remove AppImage AppDir (clean)
          #rm -fr appimage/*.AppDir/
          rm -fr appimage/"$VAR".AppDir/
          # make AppImage AppDir ($VAR)
          #echo "making $VAR AppImage AppDir: appimage/$VAR.AppDir/"
          echo "making $VAR AppImage AppDir (appimage/$VAR.AppDir/)"
          echo
          #mkdir -p appimage/"$VAR".AppDir
          #cp -afLr appimage/"$VAR"/ appimage/"$VAR".AppDir/ || exit 14
          cp -afLr appimage/"$VAR"/ appimage/"$VAR".AppDir/ || continue
          if hash touch 2>/dev/null; then
            # bash 4.0+
            #for file in appimage/"$VAR"/**/*; do
            #for file in appimage/"$VAR".AppDir/**/*; do
            # sh
            #for file in appimage/"$VAR"/*/*/*/* appimage/"$VAR"/*/*/* appimage/"$VAR"/*/* appimage/"$VAR"/* appimage/"$VAR"; do
            for file in appimage/"$VAR".AppDir/*/*/*/* appimage/"$VAR".AppDir/*/*/* appimage/"$VAR".AppDir/*/* appimage/"$VAR".AppDir/*/.* appimage/"$VAR".AppDir/* appimage/"$VAR".AppDir; do
              if [ -e "$file" ]; then
                #touch -d @0 -h "$file"
                touch -d @"${epoch:=0}" -h "$file"
              fi
            done
          fi
          #echo "making $VAR ($ARCH) AppImage: $VAR$ver-$ARCH.AppImage (with appimage/$VAR.AppDir/)"
          echo "making $VAR ($ARCH) AppImage ($VAR$ver-$ARCH.AppImage) with appimage/$VAR.AppDir/"
          echo
          # make AppImage release ($VAR)
          #ARCH=$ARCH ./"$appimagetool_file" appimage/"$VAR" $appimage_zsync_arg
          #ARCH=$ARCH ./"$appimagetool_file" appimage/"$VAR" "$VAR$ver-$ARCH".AppImage $appimage_zsync_arg
          # requires export ARCH above
          #./"$appimagetool_file" appimage/"$VAR" $appimage_zsync_arg
          #./"$appimagetool_file" appimage/"$VAR" "$VAR$ver-$ARCH".AppImage $appimage_zsync_arg
          # make AppImage release ($VAR.AppDir)
          #ARCH=$ARCH ./"$appimagetool_file" appimage/"$VAR".AppDir $appimage_zsync_arg
          #ARCH=$ARCH ./"$appimagetool_file" appimage/"$VAR".AppDir "$VAR$ver-$ARCH".AppImage $appimage_zsync_arg
          # requires export ARCH above
          #./"$appimagetool_file" appimage/"$VAR".AppDir $appimage_zsync_arg
          ./"$appimagetool_file" appimage/"$VAR".AppDir "$VAR$ver-$ARCH".AppImage $appimage_zsync_arg
        fi
        echo
      done
    done
  fi
else
  echo "skipped making AppImage releases"
  echo
fi

if [ -z "$skip_flatpak" ]; then
  # make Flatpak releases
  if hash flatpak 2>/dev/null && hash flatpak-builder 2>/dev/null; then
    flatpak remote-add --if-not-exists --user flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    #for ARCH in aarch64 armhf i686 x86_64; do
    for ARCH in $(flatpak --supported-arches); do
      for VAR in srcpkg2git srcpkg-dl srcpkg-dl-bot; do
        # $VAR-local.yaml -> $VAR.yaml -> $VAR-remote.yaml
        #for flatpak_manifest in $VAR-local.yaml $VAR.yaml $VAR-remote.yaml; do
        for VAR2 in $VAR-local.yaml $VAR.yaml $VAR-remote.yaml; do
          if [ -s "$VAR2" ]; then
            flatpak_manifest=$VAR2
            break
          else
            flatpak_manifest=
          fi
        done
        if [ -s "$flatpak_manifest" ]; then
          # TODO maybe add argument/option to toggle (disable/skip) flatpak-builder (pre) clean (defaults to enabled; clean)
          # flatpak-builder (pre) clean
          rm -fr .flatpak-builder/ flatpak-build-dir/ flatpak-repo/
          #echo "making $VAR ($ARCH) Flatpak: $VAR-$ARCH.flatpak (with $flatpak_manifest)"
          #echo "making $VAR ($ARCH) Flatpak ($VAR-$ARCH.flatpak) with $flatpak_manifest"
          #echo "making $VAR ($ARCH) Flatpak: $VAR$ver-$ARCH.flatpak (with $flatpak_manifest)"
          echo "making $VAR ($ARCH) Flatpak ($VAR$ver-$ARCH.flatpak) with $flatpak_manifest"
          echo
          # TODO maybe add argument/option to toggle (enable) Flatpak install (defaults to disabled; build only / no install)
          # build and install
          #flatpak-builder --force-clean --user --install-deps-from=flathub --repo=flatpak-repo --install flatpak-build-dir "$flatpak_manifest"
          #flatpak-builder --arch="$ARCH" --force-clean --user --install-deps-from=flathub --repo=flatpak-repo --install flatpak-build-dir "$flatpak_manifest"
          # build (no install)
          #flatpak-builder --force-clean --user --install-deps-from=flathub --repo=flatpak-repo flatpak-build-dir "$flatpak_manifest"
          flatpak-builder --arch="$ARCH" --force-clean --user --install-deps-from=flathub --repo=flatpak-repo flatpak-build-dir "$flatpak_manifest"
          # make $VAR-$ARCH.flatpak - don't specify branch (defaults to branch 'master')
          #flatpak build-bundle flatpak-repo "$VAR-$ARCH.flatpak" io.gitlab.evlaV."$VAR" --runtime-repo=https://flathub.org/repo/flathub.flatpakrepo
          #if hash cut 2>/dev/null; then
            # make $VAR$version-$ARCH.flatpak - specify (dynamic) branch using $version and "$(echo "$version" | cut -b 2-)" instead of string ('0.1')
            #flatpak build-bundle flatpak-repo "$VAR$version-$ARCH.flatpak" io.gitlab.evlaV."$VAR" "$(echo "$version" | cut -b 2-)" --runtime-repo=https://flathub.org/repo/flathub.flatpakrepo
          #else
            # make $VAR-0.1-$ARCH.flatpak - specify (static) branch using string ('0.1')
            #flatpak build-bundle flatpak-repo "$VAR-0.1-$ARCH.flatpak" io.gitlab.evlaV."$VAR" '0.1' --runtime-repo=https://flathub.org/repo/flathub.flatpakrepo
          #fi
          # make $VAR$ver-$ARCH.flatpak - specify (dynamic) branch using $ver and $version
          flatpak build-bundle --arch="$ARCH" flatpak-repo "$VAR$ver-$ARCH.flatpak" io.gitlab.evlaV."$VAR" "$version" --runtime-repo=https://flathub.org/repo/flathub.flatpakrepo
          echo
        fi
      done
    done
    # TODO maybe add argument/option to toggle (disable/skip) flatpak-builder (post) clean (defaults to enabled; clean)
    # flatpak-builder (post) clean
    rm -fr .flatpak-builder/ flatpak-build-dir/ flatpak-repo/
  else
    #echo "error: flatpak(-builder) not found! install flatpak(-builder) to make Flatpak"
    echo "warning: flatpak(-builder) not found! install flatpak(-builder) to make Flatpak"
    echo
    #exit 15
  fi
else
  echo "skipped making Flatpak releases"
  echo
fi

if [ -z "$skip_image" ]; then
  # make image/container releases (podman -> docker)
  if hash podman 2>/dev/null; then
    image_bin=podman
    if [ -n "$docker" ] && hash docker 2>/dev/null; then
      image_bin=docker
    fi
  elif hash docker 2>/dev/null; then
    image_bin=docker
  else
    image_bin=
    echo "error: podman or docker not found! install podman or docker to make image/container"
    echo
    #exit 16
  fi
  if hash "$image_bin" 2>/dev/null; then
    for VAR in srcpkg2git srcpkg-dl srcpkg-dl-bot; do
      if [ -s "$VAR-local.Containerfile" ]; then
        #echo "making $VAR image/container ($VAR.tar[.gz]) with $VAR-local.Containerfile (and $image_bin)"
        echo "making $VAR image/container ($VAR$ver.tar[.gz]) with $VAR-local.Containerfile (and $image_bin)"
        echo
        # build image (immutable)
        "$image_bin" build -f ./"$VAR"-local.Containerfile -t "$VAR"
        # save image to archive (tar.gz + tar -> tar)
        if hash gzip 2>/dev/null; then
          # tar.gz
          #"$image_bin" save "$VAR" | gzip > "$VAR".tar.gz
          "$image_bin" save "$VAR" | gzip > "$VAR$ver".tar.gz
          # tar
          #"$image_bin" save "$VAR" > "$VAR".tar
          "$image_bin" save "$VAR" > "$VAR$ver".tar
        else
          # tar
          #"$image_bin" save "$VAR" > "$VAR".tar
          "$image_bin" save "$VAR" > "$VAR$ver".tar
        fi
        echo
        # create container (mutable) from image (immutable)
        #"$image_bin" container create --name "$VAR" "$VAR"
        #echo
        # remove image - (post) clean
        "$image_bin" rmi -f "$VAR"
        # load image (tar.gz -> tar)
        ##if [ -s "$VAR.tar.gz" ]; then
        #if [ -s "$VAR$ver.tar.gz" ]; then
          # tar.gz
          ##"$image_bin" load < "$VAR".tar.gz
          #"$image_bin" load < "$VAR$ver".tar.gz
        ##elif [ -s "$VAR.tar" ]; then
        #elif [ -s "$VAR$ver.tar" ]; then
          # tar
          ##"$image_bin" load < "$VAR".tar
          #"$image_bin" load < "$VAR$ver".tar
        #fi
        echo
      fi
    done
  fi
else
  echo "skipped making image/container releases"
  echo
fi

# timestamp AppImage releases
if hash touch 2>/dev/null; then
  for file in *.AppImage *.zsync; do
    #if [ -e "$file" ]; then
    if [ -f "$file" ]; then
      #touch -d @0 "$file"
      touch -d @"${epoch:=0}" "$file"
    fi
  done
fi

# remove source dir (clean)
if [ -n "$clean" ]; then
  rm -fr "${project:=srcpkg2git}$ver"/
  rm -fr appimage/*.AppDir/
  made_source_dir=
fi

# remove (template) config (clean)
[ -n "$rm_git_remote_conf" ] && rm -f git-remote.conf
[ -n "$rm_srcpkg_dl_conf" ] && rm -f srcpkg-dl.conf
