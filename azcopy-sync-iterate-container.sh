#!/bin/sh
set -e

storage_account_name=utxxcvdev
storage_account_key="DqWwUP2sefwe99TgvJxxxxxxxxxxxx0bv2zZBlWk/zCx/2vx6ix16duA=="
storage_account_sas="xxxxxxxxxxxxxco&sp=x2:29:48Z&spr=https&sig=890B8OIxOgxDethf8ZsNGMMeTA%3D"

if test -f "nim.list"; then
    rm nim.list
fi

az storage container list --account-name $storage_account_name --query "[].{name:name}" -o TSV --account-key $storage_account_key >> nim.list

for nim in $(cat nim.list)
do
    # ganti dengan 1st char dari nim
    if [ "$(echo "$nim" | cut -c1)" = 8 ]; then
        echo "Processing \033[1;32m$nim\033[0m directory...";
        if test -d "mirrordatathe/$nim"; then
            echo "Directory \033[1;32m$nim\033[0m sudah ada"
        else
            echo "Create directory \033[1;32m$nim\033[0m"
            mkdir mirrordatathe/$nim
        fi

        sudo azcopy sync "https://$storage_account_name.blob.core.windows.net/$nim$storage_account_sas" mirrordatathe/$nim --recursive
    fi
done