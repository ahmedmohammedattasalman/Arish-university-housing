# University Housing Management App

A comprehensive Flutter application for managing university housing facilities, including student accommodations, requests, payments, and attendance tracking.

## Features

### Multi-Role System
The app supports multiple user roles, each with specific features and permissions:

- **Students**
  - Request vacation or eviction
  - View attendance records
  - Pay housing fees
  - Scan QR codes for attendance
  - Check meal eligibility

- **Supervisors**
  - Approve/reject student requests
  - Generate QR codes for attendance
  - View student attendance logs
  - Manage housing facilities

- **Administrators**
  - User management
  - System settings
  - Analytics and reports
  - Role-based permissions

- **Labor/Maintenance Staff**
  - Manage cleaning requests
  - Track maintenance tasks
  - Schedule facility upkeep

- **Restaurant Staff**
  - Verify student meal eligibility
  - Track meal attendance
  - Manage dining schedules

### Technical Features
- Role-based authentication with Supabase
- Real-time database for instant updates
- QR code generation and scanning for attendance
- Offline support for essential features
- Responsive UI adapting to different screen sizes
- Theming based on user role

## Getting Started

### Prerequisites
- Flutter SDK (3.5.0 or newer)
- Dart SDK (3.5.0 or newer)
- A Supabase account and project

### Installation

1. Clone the repository:
```
git clone https://github.com/yourusername/university-housing.git
```

2. Navigate to the project directory:
```
cd university-housing
```

3. Install dependencies:
```
flutter pub get
```

4. Update the Supabase configuration:
   - In `lib/core/config/constants.dart`, update the Supabase URL and anon key with your own values.

5. Run the application:
```
flutter run
```

## Project Structure

```
lib/
├── core/
│   ├── config/       # App configuration and constants
│   ├── services/     # Services like Supabase, network handling
│   ├── theme/        # App theming
│   ├── utils/        # Utility functions
│   └── widgets/      # Reusable widgets
├── features/
│   ├── admin/        # Admin-specific features
│   ├── auth/         # Authentication
│   ├── labor/        # Maintenance staff features
│   ├── restaurant/   # Restaurant staff features
│   ├── student/      # Student-specific features
│   └── supervisor/   # Supervisor-specific features
└── main.dart         # App entry point
```

## Database Schema

The application uses Supabase for backend services with the following main collections:

- `users`: User profiles and authentication
- `requests`: Student requests for vacation/eviction
- `attendance`: Attendance records
- `qr_codes`: Generated QR codes for attendance
- `payments`: Housing fee payments
- `cleaning_requests`: Maintenance requests

## Development Roadmap

- [x] Project setup and structure
- [x] Authentication system
- [x] Role-based dashboards
- [ ] Request creation and approval workflows
- [ ] QR code generation and scanning
- [ ] Payment integration
- [ ] Offline support
- [ ] Final testing and optimization

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgements

- Flutter Team for the amazing framework
- Supabase for the backend services
- All contributors who have helped with the project
