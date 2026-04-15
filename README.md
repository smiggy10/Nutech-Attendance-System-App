# Nutech Attendance System 📱

An integrated mobile application designed for seamless attendance tracking and access control. By bridging hardware terminals with a mobile software interface, this system provides a streamlined user experience alongside robust backend logic to manage real-time event logging.

## ✨ Key Features

* **Seamless Check-ins:** Fast, reliable attendance logging for daily operations.
* **Access Control & Terminal Integration:** Communicates directly with hardware terminals for synchronized access control and data retrieval.
* **Real-time Event Logging:** Instant synchronization of attendance data across the system.
* **Intuitive UI/UX:** A clean, user-friendly mobile interface designed for accessibility, smooth navigation, and clear data presentation.
* **Automated Workflows:** Utilizes customized n8n integration files to handle automated data routing and backend processes.

## 🛠️ Tech Stack

* **Frontend:** Flutter, Dart
* **Backend Logic & Automation:** n8n, REST APIs 
* **Core/Native:** C++, CMake (for specific terminal/hardware communication)

## 🚀 Getting Started

### Prerequisites
* [Flutter SDK](https://docs.flutter.dev/get-started/install) (Latest stable version)
* Appropriate IDE (Android Studio, VS Code, etc.)
* n8n instance (for workflow integrations)

### Installation
1. Clone the repository:
   ```bash
   git clone [https://github.com/smiggy10/Nutech-Attendance-System-App.git](https://github.com/smiggy10/Nutech-Attendance-System-App.git)
   
2. Navigate to the project directory:
    ```bash
   cd Nutech-Attendance-System-App

3. Install dependencies:
    ```bash
   flutter pub get

4. Run the application:
    ```bash
   flutter run

## Office PC automated setup (required files)

The office PC that runs **n8n**, **ngrok**, and receives **Dahua** terminal webhooks must include these two files as part of the automated stack. **Source in this repo:**

| File | Location |
|------|----------|
| **`dahua-proxy.js`** | [`n8n-integration-files/office-pc/dahua-proxy.js`](n8n-integration-files/office-pc/dahua-proxy.js) |
| **`start-n8n-ngrok.vbs`** | [`n8n-integration-files/office-pc/start-n8n-ngrok.vbs`](n8n-integration-files/office-pc/start-n8n-ngrok.vbs) |

Copy **both** into the same folder on the office machine (for example `C:\NutechOffice\`). The VBS script runs `dahua-proxy.js` from **that same directory** so you do not need a hard-coded `C:\dahua-proxy.js` path. **Node.js** must be installed and `n8n` / **ngrok** available as in the script.

**`dahua-proxy.js`** — Node.js HTTP proxy (default port **5679**). Reads Dahua’s compressed webhook body (raw deflate and related encodings), decompresses with Node’s `zlib`, and forwards **plain text** to n8n on **5678**, avoiding incorrect deflate headers and similar issues in n8n.

**`start-n8n-ngrok.vbs`** — Run at **logon** via Task Scheduler. Waits for the network (e.g. ZeroTier), stops stray `node.exe` processes, starts **n8n** (with `WEBHOOK_URL` pointing at the proxy), starts **ngrok** from your config, starts the proxy with `node`, then opens the n8n workflow in Chrome. **Edit the VBS** for your site: `WEBHOOK_URL`, ZeroTier/host IP (`192.168.192.197`), **ngrok** exe and `ngrok.yml` paths, **Chrome** path, and the **workflow** URL.

Without both files, the automated office setup (Dahua → proxy → n8n, ngrok, scheduled startup) is incomplete.

📁 Repository Structure
/lib - Contains the core Dart code, UI/UX components, and state management.

/n8n-integration-files - Workflows and configurations for backend automation (includes `office-pc/` for Dahua proxy + Windows startup script).

/android, /ios, /linux, /macos, /windows - Platform-specific deployment files.
