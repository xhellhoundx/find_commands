#!/usr/bin/env bash

# Autor: PFPE20
#
# Script para buscar comando en index.yaml


# Path & Global variables
THIS_PATH=$( dirname $( realpath "$0" ) )
IDX_FILE="$THIS_PATH/index.yaml"

LIST_TOOLS=$(yq '.[].tool' $IDX_FILE | uniq) # Pckg index
declare -i TTY_SIZE=$(stty size | cut -d ' ' -f1) # Filas de la terminal para usar "less" o no

# Busca si el paquete existe en el IDX y lo muestra
function search_pkg() {
  local PKG="${1,,}"
  if [[ -z "$PKG" ]]; then
    echo -e "\n\t\e[1;33m[!]\e[0m paquete/servicio/protocolo no encontrado\n"; exit 1
  fi

  FIND_PKG=$(PKG="$PKG" yq -r '.[] | select(.tool == env(PKG)) | "\t\(.description)\n  \(.command)\n"' "$IDX_FILE")

  if ! echo "$LIST_TOOLS" | grep -qi "$PKG"; then
    echo -e "\n\t\e[1;33m[!]\e[0m paquete/servicio/protocolo no encontrado\n"
  fi

  if (( $(echo "$FIND_PKG" | wc -l) > "$TTY_SIZE" )); then
    echo "$FIND_PKG" | less; exit
  fi

  echo "$FIND_PKG"
  exit
}

# Busca coincidencias de una palabra clave en todo el documento
function search_cmd() {
  local KEYWORD="${1,,}"
  if [[ -z "$KEYWORD" ]]; then
    echo -e "\n\t\e[1;33m[!]\e[0m Palabra clave no encontrada\n"; exit 1
  fi

  FIND_KW=$(KW="$KEYWORD" yq -r '.[] | select(.tool == env(KW) or (.description | test(env(KW))) or (.command | test(env(KW)))) | "\tHerramienta: \(.tool)\tCategoría: \(.category)\tEtiquetas: \(.tags)\n\(.description)\n\(.command)\n"' "$IDX_FILE")

  if ! echo "$FIND_KW" | grep -qi "$KEYWORD" ; then
    echo -e "\n\t\e[1;33m[!]\e[0m Palabra clave no encontrada\n"; exit 1
  fi

  if (( $(echo "$FIND_KW" | wc -l) > "$TTY_SIZE" )); then
    echo "$FIND_KW" | less; exit
  fi

  echo "$FIND_KW"
  exit
}

# Busca paquetes/servicios por CATEGORÍA
CATS=("info" "web" "wrapper" "url" "encoding" "crypto" "forensic" "exploitation" "network" "system" "scripting" "utility" "database")
function find_by_label() {
  local KEYWORD="$1"
  if [[ -z "$KEYWORD" ]]; then
    echo -e "\n\t\e[1;33m[!]\e[0m Palabra clave no encontrada\n"; exit 1
  fi

  FIND_CAT=$(KW="$KEYWORD" yq -r '.[] | select(.category == env(KW)) | "Herramienta: \(.tool)\t\tCategoría: \(.category)"' "$IDX_FILE" | uniq)

  if ! echo "$FIND_CAT" | grep -qi "$KEYWORD"; then
    echo -e "\n\t\e[1;33m[!]\e[0m Categoría no encontrada\n"; exit 1
  fi

  if (( $(echo "$FIND_CAT" | wc -l) > "$TTY_SIZE" )); then
    echo "$FIND_CAT" | sort | less; exit
  fi

  echo "$FIND_CAT"
  exit
}


function usage() {
	
	echo -e "\n  Uso:\n  \e[1m./findcommands [FLAGS] <KEYWORD>\e[0m\n"
  echo -e "  \e[1;37m-h\e[0m\t\t\tMuestra esta ayuda"
	echo -e "  \e[1;37m-l\e[0m\t\t\tLista todos los paquetes y servicios"
	echo -e "  \e[1;37m-c\e[0m \e[3m<command>\e[0m\t\tEncuentra las apariciones en el documento"
	echo -e "  \e[1;37m-k\e[0m \e[3m<command>\e[0m\t\tBusca paquetes/programas por su título"
  echo -e "  \e[1;37m-a\e[0m \e[3m<label>\e[0m\t\tBusca paquetes/programas por categorías\n"
  echo -ne "\n\tCategorías disponibles:\t"
  for tag in ${CATS[@]}; do
    echo -ne "\e[1m$tag\e[0m "
  done
	exit
}

if [[ -z "$1" ]]; then
	usage; exit 1
fi

while getopts ":k:c:a:lh" opt; do
	case $opt in
		k)
      search_pkg "$OPTARG";;
		c)
      search_cmd "$OPTARG";;
    a)
      find_by_label "$OPTARG";;
		l)
      echo "$LIST_TOOLS" | less; exit;;
    h)
      usage; exit;;
		?) usage; exit;;
	esac
done



