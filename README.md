# Ultimate Network & Proxy Deep Reset Utility

A robust, self-elevating Windows Batch automation script designed to resolve stubborn network connectivity issues, wipe custom proxy configurations, and deep-cycle physical PCIe Ethernet adapters without disrupting Wi-Fi connections.

---

## 🚀 Features

* **Automatic UAC Elevation:** No need to right-click—simply double-click to run with Administrative privileges.
* **Windows Security Integration:** Automatically whitelists itself in Windows Defender upon execution to prevent heuristic false positives.
* **Proxy Stripping:** Forcefully clears manual proxy toggles, resets corrupted proxy server paths, and re-enables native Windows "Automatically detect settings".
* **Targeted Hardware Cycle:** Isolates physical PCIe Ethernet cards (Intel, Realtek, Killer, etc.), uninstalls them at the kernel level via `pnputil`, and triggers an immediate hardware scan to cleanly re-initialize the device stack.
* **Wi-Fi Safety Guard:** Explicitly bypasses all wireless network adapters and virtual VPN switches, ensuring ongoing wireless connections remain active.

---

## 🛠️ Prerequisites

* **Operating System:** Windows 10 or Windows 11.
* **Hardware Required:** Built-in or expansion card PCIe Wired Ethernet Adapter (the script functions seamlessly whether an Ethernet cable is currently plugged in or not).

---

## 📖 How to Use

1. **Download / Copy** the script file (`NetworkReset.bat`) onto your local machine.
2. **Double-click** the `NetworkReset.bat` file directly.
3. When the Windows User Account Control (UAC) prompt appears asking for administrative control, click **Yes**.
4. Allow the script to run through its 3 core phases.
5. Once the `SUCCESS` screen appears, press any key on your keyboard to close the window.

---

## 🔍 What to Expect (Phases of Execution)

When executed, the utility moves through the following stages:

| Phase | Title | Action | Expected Behavior |
| :--- | :--- | :--- | :--- |
| **[1/3]** | **Proxy Reset** | Wipes registry keys tracking manual network proxy servers. | Silent execution. |
| **[2/3]** | **Uninstall Adapter** | Queries hardware hooks for an `802.3` wired card and forcefully removes it. | Your system tray wired icon may briefly display a disconnected/globe icon. |
| **[3/3]** | **Hardware Rescan** | Forces Device Manager to scan the motherboard PCIe bus. | The Ethernet card is rediscovered, clean native drivers bind back to it, and your IP stack resets. |

> 💡 **Note on Wi-Fi:** Your wireless card will not drop its connection during this sequence. Only hardwired PCIe interfaces are recycled.

---

## 🔬 Under the Hood: Technical Architecture

Most automated network fixes rely on simple, high-level commands like `ipconfig /renew` or standard Windows Network Troubleshooting wizards. While these methods flush basic software caches, they frequently fail when dealing with corrupted registry settings, malicious/malfunctioning local proxy hooks, or a hardware driver that has entered an unrecoverable kernel panic state.

This utility takes an aggressive, multi-layered approach by executing system-level operations across three distinct subsystems: the **Windows Registry**, the **Kernel Plug-and-Play (PnP) Architecture**, and **Windows Security Preferences**.

### Phase 1: Silent Administrative Elevation & Session Wrapping
Because hardware uninstallation commands operate at the kernel layer, Windows strictly blocks execution from standard user contexts. 
* To eliminate user friction (manually right-clicking), the script creates a temporary Visual Basic Script (`.vbs`) on-the-fly in the system `%temp%` directory.
* This script invokes the Windows Shell Application `runas` verb, spawning a high-integrity `cmd.exe` process instance.
* Once elevated, the script uses a `pushd` wrapper to instantly correct the working directory context back to the file's original launch origin.

### Phase 2: Windows Defender Automation
Security software frequently flags scripts that manipulate drivers or the registry as potential threats (Heuristic false-positives). 
* The script leverages a native PowerShell command (`Add-MpPreference`) to dynamically query its own exact, absolute path via the `%~f0` string token.
* It places a permanent exclusion on itself *instantly* upon launch. This guarantees that real-time behavioral scans will not abruptly kill the script mid-execution while it is interacting with the hardware layer.

### Phase 3: Total Proxy Registry Sanitization
Malware, faulty corporate VPNs, or improper software uninstalls regularly leave ghost proxy settings behind inside the user hives. This results in the classic "Connected to internet, but browsers won't load pages" symptom. The script targets three critical registry values under `HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings`:
* **`ProxyEnable = 0`**: Explicitly disables the global manual proxy server switch.
* **`ProxyServer (Delete)`**: Completely eradicates any hardcoded IP addresses or domain loops left in the registry.
* **`AutoDetect = 1`**: Restores the default Windows configuration to look directly to the local DHCP server for Web Proxy Auto-Discovery (WPAD) protocols.

### Phase 4: Targeted PnP Hardware Takedown & Bus Re-Scan
Instead of simply disabling the network interface (which leaves faulty driver code loaded in system memory), this script completely severs the hardware hook.
1. **Isolation:** It filters system adapters using `Get-NetAdapter -Physical` and narrows down the selection strictly to media type `802.3` (IEEE wired Ethernet). This ensures virtual network adapters and Wi-Fi modules are entirely ignored.
2. **Identification:** It safely extracts the device's persistent, underlying `PnPDeviceID` string rather than relying on mutable text-based names.
3. **Execution:** It hands the unique ID string directly over to `pnputil.exe` (the Windows native Plug and Play Utility) using a secure string parameter buffer, forcefully removing the device stack from memory.
4. **Restoration:** After a 2-second stabilization delay, `pnputil /scan-devices` forces the motherboard's PCIe bus root enumerator to re-query its lanes. The hardware chip is rediscovered as a "new" device, a clean driver instance binds to it natively, and the network stack reinitializes from scratch.

---

## 🔒 Safety and Side-Effects

* **Is it safe?** Yes. The script utilizes native, Microsoft-vetted binaries (`pnputil.exe`, `reg.exe`, `powershell.exe`). It does not rely on sketchy third-party files or unverified executables.
* **Will it break my Wi-Fi?** No. The strict `802.3` hardware filter safely shields all `802.11` (Wireless) physical media architectures.
* **Do I need an active internet connection to run it?** No. Because it utilizes the computer's existing, local driver store cache during the hardware re-scan phase, it functions completely offline.

---

## 🛑 Troubleshooting / Error Handling

* **"[-] No physical PCIe Ethernet adapters found to reset."**
    * *Meaning:* The script executed perfectly, but your system is either entirely on Wi-Fi or your Ethernet adapter is external (like a USB-C dongle) rather than a fixed PCIe card slot.
* **Windows SmartScreen Block:**
    * *Meaning:* Because the script manipulates hardware drivers directly via command lines, Windows SmartScreen may flag it on its very first run. Click **More Info** -> **Run Anyway**. The script will automatically add its permanent Defender exclusion to prevent this warning from repeating.

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
