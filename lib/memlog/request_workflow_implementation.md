# Request Creation and Approval Workflows Implementation

## Overview
This document outlines the implementation of request creation and approval workflows for the University Housing app. This feature allows students to create requests (e.g., vacation, eviction) that supervisors can review and approve/reject.

## Implementation Steps

1. **Create Request Models**
   - Implement `Request` and `RequestDetail` models
   - Define request types and status enums

2. **Update Services**
   - Extend SupabaseService with request-specific methods
   - Implement real-time updates for request status changes

3. **Student Features**
   - Create request submission forms
   - Implement request list and details views
   - Add request status tracking

4. **Supervisor Features**
   - Create request approval dashboard
   - Implement approval/rejection workflows
   - Add commenting and feedback functionality

5. **Notification System**
   - Add real-time notifications for request updates
   - Implement email notifications for important status changes

## Database Schema

The requests collection should contain the following fields:
- id (UUID, primary key)
- user_id (references profiles.id)
- type (string: vacation, eviction, etc.)
- status (string: pending, approved, rejected)
- details (JSON object with request-specific fields)
- created_at (timestamp)
- updated_at (timestamp)
- supervisor_id (optional, references profiles.id)
- notes (optional, text for supervisor comments)

## UI/UX Considerations

- Real-time status updates
- Clear visual indicators for request status
- Filtering and sorting options in list views
- Detailed history for each request
- Mobile-friendly forms with appropriate validation

## Implementation Progress

- [x] Models implementation
  - Created `Request` model with appropriate fields
  - Implemented `RequestType` and `RequestStatus` enums
  
- [x] Service extensions
  - Extended `RequestProvider` to handle request operations
  - Added real-time updates via Supabase subscriptions
  
- [x] Student UI components
  - Created `CreateRequestScreen` with dynamic forms based on request type
  - Implemented validation and submission logic
  
- [x] Supervisor approval UI
  - Created `RequestApprovalScreen` with filtering capabilities
  - Implemented `RequestDetailScreen` for reviewing request details
  - Added approval/rejection flows with comments
  
- [ ] Notification system
  - Still needs implementation 