#!/bin/bash

while true; do
  # Set interface rings to maximum
  while read interface; do
    interface_rings=`/usr/sbin/ethtool -g "$interface" 2>&1 | tr 'A-Z' 'a-z'`
    if [[ "$interface_rings" == *"operation not supported"* ]] || [[ "$interface" == "lo" ]]; then continue; fi
    interface_max_rx_ring=`/usr/sbin/ethtool -g "$interface" | tr 'A-Z' 'a-z' | grep "^rx:" | head -n1 | awk '{print $NF}'`
    interface_max_tx_ring=`/usr/sbin/ethtool -g "$interface" | tr 'A-Z' 'a-z' | grep "^tx:" | head -n1 | awk '{print $NF}'`
    interface_current_rx_ring=`/usr/sbin/ethtool -g "$interface" | tr 'A-Z' 'a-z' | grep "^rx:" | tail -n1 | awk '{print $NF}'`
    interface_current_tx_ring=`/usr/sbin/ethtool -g "$interface" | tr 'A-Z' 'a-z' | grep "^tx:" | tail -n1 | awk '{print $NF}'`
    if [[ "$interface_max_rx_ring" != "$interface_current_rx_ring" ]]; then /usr/sbin/ethtool -G "$interface" rx "$interface_max_rx_ring"; fi
    if [[ "$interface_max_tx_ring" != "$interface_current_tx_ring" ]]; then /usr/sbin/ethtool -G "$interface" tx "$interface_max_tx_ring"; fi
  done < <(ls /sys/class/net/)

  # Set interface mtu to maximum
  while read interface; do
    if ! [ -e /sys/class/net/$interface/mtu ] || [[ "$interface" == "lo" ]]; then continue; fi
    interface_max_mtu="9198"
    interface_current_mtu=`cat /sys/class/net/$interface/mtu`
    if [[ "$interface_current_mtu" -lt 9000 ]]; then
      /bin/ip link set dev "$interface" mtu "$interface_max_mtu"
      if [ $? -ne 0 ]; then
        max_mtu=$interface_max_mtu
        mtu_success="1"
        while [[ "$mtu_success" == "1" ]]; do
          max_mtu=$((max_mtu-2))
          /bin/ip link set dev "$interface" mtu "$max_mtu"
          if [ $? -eq 0 ]; then mtu_success="0"; fi
        done
      fi
    fi
  done < <(ls /sys/class/net/)
  sleep 60
done
