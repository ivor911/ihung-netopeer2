#!/bin/bash
PUBLICKEY="AAAAB3NzaC1yc2EAAAADAQABAAABAQC03+GFG6mHdoFkp3+0pkSC/5gR77guEjbve0Lb8YtHAdl3bRJBm/yQ/2lNpFdjusipfd6aQqWgo8rVQOk+EnN+N/wEXoKWBz83Q2lKS9TGfVVFTdNngKGoox26UcBHiB82CSBSu3VkTA799B2ou7w0hPORBQTh03E4JJWMSENC/uBJuQbx/h3MJKT4rKIcs/K37CWhGDvOPfbyR+nfySZzZs44hE6qykyHzrsnBqOaWVHHfdOmB92XS0FQ6cfM0TPmUobj10TRxv0upF7BbgqX+EXQ2+vGfG9Tms9+jbX+QSygKwt1cI8TVgG01/kgpes+si/sRWuEjgSNoEH5+isf"
#PUBLICKEY=`cat ~/.ssh/id_rsa.pub |  awk '{print $2}'`
USERNAME="rbbn"
ARBITRARA_KEY_NAME="id_rsa"
ALGORITHM="ssh-rsa"

OUTXML="load_auth_pubkey.xml"
TEMPXML="<system xmlns="urn:ietf:params:xml:ns:yang:ietf-system">
  <authentication>
    <user>
      <name>$USERNAME</name>
      <authorized-key>
        <name>$ARBITRARA_KEY_NAME</name>
        <algorithm>$ALGORITHM</algorithm>
        <key-data>$PUBLICKEY</key-data>
      </authorized-key>
    </user>
  </authentication>
</system>"
printf -- "$TEMPXML" > $OUTXML
