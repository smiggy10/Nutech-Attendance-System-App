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

📁 Repository Structure
/lib - Contains the core Dart code, UI/UX components, and state management.

/n8n-integration-files - Workflows and configurations for backend automation.

/android, /ios, /linux, /macos, /windows - Platform-specific deployment files.
