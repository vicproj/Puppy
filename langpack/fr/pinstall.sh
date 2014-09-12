#!/bin/sh
#Barry Kauler, Feb. 2012. GPL3 (/usr/share/doc/legal)
#this is the post-install script for a langpack PET created by /usr/sbin/momanager.
#MoManager will replace the strings fr and Le Langpack français a été installé mais requiert de relancer le serveur graphique X pour être totalement opérationnel..
#120315 maybe have hunspell dictionaries in langpack.
#120830 improved symlinks to hunspell dictionaries.
#120924 DejaVu font no good for non-Latin languages. 120925 add korean.
#120926 translate Comment field in .desktop file. note: applications.in now handled in /usr/local/petget/installpkg.sh.
#120927 L18L requested if there is already a translation in .desktop, remove it, replace with one from langpack.
#121011 L18L requested call to extra hacks script.

echo "Post install script for fr language pack"

#if [ "$LANG" = "C" ];then #in case caller script did this.
 LANG="`grep '^LANG=' /etc/profile | cut -f 2 -d '=' | cut -f 1 -d ' '`"
 export LANG
#fi
LANG1="`echo -n $LANG | cut -f 1 -d '_'`"  #ex: de

if [ -d usr/share/applications.in ];then #refer: /usr/sbin/momanager
 for ADESKTOPFILE in `find usr/share/applications.in -mindepth 1 -maxdepth 1 -type f -name '*.desktop' | tr '\n' ' '`
 do
  ABASEDESKTOP="`basename $ADESKTOPFILE`"
  ADIRDESKTOP=''
  [ -f usr/share/applications/${ABASEDESKTOP} ] && ADIRDESKTOP='usr/share/applications'
  [ ! "$ADIRDESKTOP" ] && [ -f usr/local/share/applications/${ABASEDESKTOP} ] && ADIRDESKTOP='usr/local/share/applications'
  if [ "$ADIRDESKTOP" ];then
   if [ "`grep '^Name\[fr\]' usr/share/applications.in/${ABASEDESKTOP}`" != "" ];then
    if [ "`grep '^Name\[fr\]' ${ADIRDESKTOP}/${ABASEDESKTOP}`" != "" ];then
     #120927 L18L requested if there is already a translation, remove it, replace with one from langpack.
     grep -v '^Name\[fr\]' ${ADIRDESKTOP}/${ABASEDESKTOP} > /tmp/momanager-pinstall-sh-desktop
     mv -f /tmp/momanager-pinstall-sh-desktop ${ADIRDESKTOP}/${ABASEDESKTOP}
    fi
    #aaargh, these accursed back-slashes! ....
    INSERTALINE="`grep '^Name\[fr\]' usr/share/applications.in/${ABASEDESKTOP} | sed -e 's%\[%\\\\[%' -e 's%\]%\\\\]%'`"
    sed -i -e "s%^Name=%${INSERTALINE}\\nName=%" ${ADIRDESKTOP}/${ABASEDESKTOP}
   fi
   #120926 do same for Comment field...
   if [ "`grep '^Comment\[fr\]' usr/share/applications.in/${ABASEDESKTOP}`" != "" ];then
    if [ "`grep '^Comment\[fr\]' ${ADIRDESKTOP}/${ABASEDESKTOP}`" != "" ];then
     #120927 L18L requested if there is already a translation, remove it, replace with one from langpack.
     grep -v '^Comment\[fr\]' ${ADIRDESKTOP}/${ABASEDESKTOP} > /tmp/momanager-pinstall-sh-desktop
     mv -f /tmp/momanager-pinstall-sh-desktop ${ADIRDESKTOP}/${ABASEDESKTOP}
    fi
    #aaargh, these accursed back-slashes! ....
    INSERTALINE="`grep '^Comment\[fr\]' usr/share/applications.in/${ABASEDESKTOP} | sed -e 's%\[%\\\\[%' -e 's%\]%\\\\]%'`"
    sed -i -e "s%^Comment=%${INSERTALINE}\\nComment=%" ${ADIRDESKTOP}/${ABASEDESKTOP}
   fi
  fi
 done
 #rm -r -f usr/share/applications.in
 #...don't remove it. might be useful for ppm when install future packages.
 #...120926 yes, applications.in now handled in /usr/local/petget/installpkgs.sh.
fi

if [ -d usr/share/desktop-directories.in ];then
 for ADESKTOPFILE in `find usr/share/desktop-directories.in -mindepth 1 -maxdepth 1 -type f -name '*.directory' | tr '\n' ' '`
 do
  ABASEDESKTOP="`basename $ADESKTOPFILE`"
  if [ -f usr/share/desktop-directories/${ABASEDESKTOP} ];then
   if [ "`grep '^Name\[fr\]' usr/share/desktop-directories/${ABASEDESKTOP}`" = "" ];then
    if [ "`grep '^Name\[fr\]' usr/share/desktop-directories.in/${ABASEDESKTOP}`" != "" ];then
     #aaargh, these accursed back-slashes! ....
     INSERTALINE="`grep '^Name\[fr\]' usr/share/desktop-directories.in/${ABASEDESKTOP} | sed -e 's%\[%\\\\[%' -e 's%\]%\\\\]%'`"
     sed -i -e "s%^Name=%${INSERTALINE}\\nName=%" usr/share/desktop-directories/${ABASEDESKTOP}
    fi
   fi
  fi
 done
 rm -r -f usr/share/desktop-directories.in
fi

#120830 improved...
#120315 maybe have hunspell dictionaries in langpack (see also momanager)...
#note: same code also in woof 3builddistro.
#for ONEHUN in `find ./usr/share/hunspell -mindepth 1 -maxdepth 1 -type f -name '*.dic' -o -name '*.aff' | tr '\n' ' '`
#do
# HUNBASE="`basename $ONEHUN`"
# [ -e ./usr/lib/seamonkey ] && ln -snf ../../../share/hunspell/${HUNBASE} ./usr/lib/seamonkey/dictionaries/${HUNBASE}
# [ -e ./usr/lib/firefox ] && ln -snf ../../../share/hunspell/${HUNBASE} ./usr/lib/firefox/dictionaries/${HUNBASE}
#done
if [ -d ./usr/share/hunspell ];then
 for ONEHUN in `find ./usr/share/hunspell -mindepth 1 -maxdepth 1 -type f -name '*.dic' -o -name '*.aff' | tr '\n' ' '`
 do
  HUNBASE="`basename $ONEHUN`"
  DICTDIRS="`find ./usr/lib -mindepth 2 -maxdepth 2 -type d -name dictionaries | tr '\n' ' '`"
  for ONEDICTDIR in $DICTDIRS
  do
   [ ! -e ${ONEDICTDIR}/${HUNBASE} ] && ln -s ../../../share/hunspell/${HUNBASE} ${ONEDICTDIR}/${HUNBASE}
  done
 done
fi

#120924 DejaVu font no good for non-Latin languages...
#see also similar code in /usr/local/petget/hacks-postinstall.sh.
LANGPACKLANG=fr
case $LANGPACKLANG in
 zh*|ja*|ko*) #chinese, japanese, korean
  sed -i -e 's%DejaVu Sans%Sans%' ./etc/xdg/templates/_root_*
  if [ -d ./root/.jwm ];then
   sed -i -e 's%DejaVu Sans%Sans%' ./root/.jwm/themes/*-jwmrc
   sed -i -e 's%DejaVu Sans%Sans%' ./root/.jwm/jwmrc-theme
  fi
  [ -d ./etc/xdg/openbox ] && sed -i -e 's%DejaVu Sans%Sans%' ./etc/xdg/openbox/*.xml
  [ -d ./root/.config/openbox ] && sed -i -e 's%DejaVu Sans%Sans%' ./root/.config/openbox/*.xml
  GTKRCFILE="$(find ./usr/share/themes -type f -name gtkrc | tr '\n' ' ')"
  for ONEGTKRC in $GTKRCFILE
  do
   sed -i -e 's%DejaVu Sans%Sans%' $ONEGTKRC
  done
  if [ -d ./root/.mozilla ];then
   MOZFILE="$(find ./root/.mozilla -type f -name prefs.js -o -name '*.css' | tr '\n' ' ')"
   for ONEMOZ in $MOZFILE
   do
    sed -i -e 's%DejaVu Sans%Sans%' $ONEMOZ
   done
  fi
 ;;
esac

if [ "`pwd`" = "/" ];then #installing PET in a running puppy.
 if [ "$LANG1" != "en" ];then
  #need to update SSS translations...
  fixscripts
  fixdesk
  fixmenus
  [ -r /pinstall_hacks.sh ] && . /pinstall_hacks.sh #121011 L18L
  pupdialog --background green --backtitle "Language Pack" --msgbox "Le paquet en langue française a été installé. Maintenant vous devez relancer le serveur graphique X pour activer les changements." 0 0 &
 fi
fi
