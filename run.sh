#!/bin/bash

set -e

mkdir -p data/download data/output


DOWNLOAD_URL="https://receita.economia.gov.br/orientacao/tributaria/cadastros/cadastro-nacional-de-pessoas-juridicas-cnpj/dados-publicos-cnpj"
FILE_URLS=$(wget --quiet --no-check-certificate -O - "$DOWNLOAD_URL" \
	| grep --color=no DADOS_ABERTOS_CNPJ \
	| grep --color=no ".zip" \
	| sed 's/.*"http:/http:/; s/".*//' \
	| sort)

echo "" > urls.txt
echo "$FILE_URLS" | xargs -n 1 echo > urls.txt

TOTAL_FILES=$(($(echo $FILE_URLS |  tr -cd " " | wc -c) + 1))
CONNECTIONS=$((TOTAL_FILES / 4 ))
MAX_DOWNLOADS=$((TOTAL_FILES / 2))

aria2c  --auto-file-renaming=false -j $MAX_DOWNLOADS -c -s $CONNECTIONS -x $CONNECTIONS --dir=data/download -i urls.txt

time python extract_dump.py --no_censorship data/output/ data/download/DADOS_ABERTOS_CNPJ*.zip
time python extract_partner_companies.py data/output/socio.csv.gz data/output/empresa-socia.csv.gz
