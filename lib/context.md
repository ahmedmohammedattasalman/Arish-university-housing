### **University Housing Mobile App**  

#### **Project Overview**  
A mobile app for university housing management, enabling students to request vacations/evictions, pay fees, and mark attendance via QR codes. Supervisors approve requests and generate QR codes, while admins manage users and permissions. Built with Expo and Supabase for real-time data.  

---  

### **Tech Stack**  
- **Framework**: flutter 
- **Language**: dart 
- **Backend/Auth**: Supabase (auth, storage, real-time)  

---  

### **Feature List**  

#### **1. Expo Setup**  
- Initialize flutter project with dart.  
- Configure Supabase for auth and real-time data.  
 

#### **2. Authentication Flow**  
- **Role-based login**: Students, Supervisors, Admins, Labor, and Restaurant Staff.  
- **Supabase Auth**: Email/password login with JWT sessions.  
- **Protected routes**: Redirect unauthorized users.  

#### **3. Student Features**  
- **Vacation/Eviction Requests**: Submit requests to Supervisors.  
- **Fee Payment**: In-app payment integration (via Supabase).  
- **QR Attendance**: Scan daily QR code to mark attendance.  
- **Meal Eligibility**: View meal access based on attendance.  

#### **4. Supervisor Features**  
- **Request Approval**: Approve/reject student requests.  
- **QR Generation**: Create daily attendance/meal QR codes.  
- **Attendance Logs**: View real-time attendance data.  

#### **5. Admin Features**  
- **User Management**: Register/edit users and assign roles.  
- **Permissions**: Configure access levels via Supabase RLS.
- **accessibility**: the user login only for his dashboard (for instant student with his login can only allowed you to access to his dashboard not other dashboard)  

#### **6. Labor Features**  
- **Cleaning Requests**: Submit requests for housing maintenance.  

#### **7. Restaurant Staff Features**  
- **Meal Verification**: Scan student QR codes to confirm eligibility.  
- **Attendance Sync**: Deny meals if no prior attendance.  

#### **8. Supabase Integration**  
- **Real-time DB**: Sync requests, attendance, and payments.  
- **Storage**: Store QR codes and user documents.  
- **Auth**: Secure role-based access control.  

#### **9. Offline Support**  
- Cache critical data (e.g., QR codes, requests) for offline use.  
- Sync pending actions when back online.  

---  

**Note**: Features prioritize mobile UX—gestures (swipe to refresh), push notifications for approvals, and QR scanning optimizations.