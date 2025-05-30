#!/bin/bash

# Aktualizacja listy pakietów
apt update

# Instalacja ipset i location bez potwierdzania
apt install -y ipset location

# Poprawka w skrypcie Pythonowym location (wyrażenie regularne)
sed -i 's/re.match("\^AS(\\d+)\$",/re.match(r"^AS(\\d+)$",/' /usr/bin/location

# Aktualizacja bazy danych z adresami IP
location update

# Pobranie IPv4 dla Polski i zapis do pliku pl
location list-networks-by-cc --family=ipv4 PL > pl

# Wyświetlenie 5 pierwszy linii pliku pl
head -5 pl