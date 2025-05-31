#!/bin/bash
set -e

# 1. Utworzenie katalogu na reguły (jeśli nie istnieje)
mkdir -p /etc/iptables

# 2. Zapisanie aktualnych reguł iptables (IPv4) do pliku rules.v4
iptables-save > /etc/iptables/rules.v4

# 3. Utworzenie skryptu boot_restore_ipset (przywracającego zestaw ipset)
cat > /usr/local/sbin/boot_restore_ipset.sh << EOF
#!/bin/bash
/sbin/ipset restore < /usr/local/sbin/blocked_ip_list
EOF

chmod 700 /usr/local/sbin/boot_restore_ipset.sh

# 4. Utworzenie skryptu boot_restore_iptables (przywracającego reguły iptables)
cat > /usr/local/sbin/boot_restore_iptables.sh << EOF
#!/bin/sh
/sbin/iptables-restore < /etc/iptables/rules.v4
EOF

chmod 700 /usr/local/sbin/boot_restore_iptables.sh

# 5. Utworzenie jednostki systemd do przywracania ipset przy starcie
cat > /etc/systemd/system/ipset-restore.service << EOF
[Unit]
Description=Przywracanie zbioru ipset
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
ExecStart=/usr/local/sbin/boot_restore_ipset.sh
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

# 6. Utworzenie jednostki systemd do przywracania iptables przy starcie
cat > /etc/systemd/system/iptables-restore.service << EOF
[Unit]
Description=Przywracanie reguł iptables
Requires=ipset-restore.service
After=ipset-restore.service
DefaultDependencies=no
Wants=network-pre.target
Before=network-pre.target
After=local-fs.target systemd-modules-load.service

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/usr/local/sbin/boot_restore_iptables.sh

[Install]
WantedBy=multi-user.target
EOF

# 7. Przeładowanie konfiguracji systemd i włączenie usług przy starcie
systemctl daemon-reload
systemctl start ipset-restore.service
systemctl start iptables-restore.service
systemctl enable ipset-restore.service
systemctl enable iptables-restore.service

echo "Skrypt zakończony pomyślnie. Jednostki zostały utworzone i włączone."
