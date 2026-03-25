# Offline Posts Manager

A modern Flutter application that allows users to manage posts offline using SQLite for local data storage. Perfect for a small media company's staff to create, read, update, and delete posts without requiring an internet connection.

## Features

✅ **Complete CRUD Operations**
- Create new posts with title and description
- Read and view all posts in a beautiful list layout
- Update existing posts with a seamless edit experience
- Delete posts with confirmation dialog

✅ **Offline Functionality**
- All data is stored locally using SQLite
- No internet connection required
- Perfect for offline workflow
- Instant synchronization across the app

✅ **Modern & Responsive UI**
- Beautiful color palette: red, yellow, white, and black
- Card-based layout with shadow effects
- Professional typography and spacing
- Clean and intuitive design

✅ **Multiple Screens**
- **Home Screen**: Browse all posts in a scrollable list
- **Post Details Screen**: View complete post information with timestamps
- **Add/Edit Post Screen**: Form with input validation and helpful hints
- **Delete Confirmation Dialog**: Prevents accidental deletions

✅ **Smooth Animations**
- Slide transitions between screens
- Fade animations on content load
- Scale animations for card interactions
- FAB animation with elastic effect
- Button press feedback animations

✅ **Advanced Features**
- Form validation (min 3 characters for title, min 10 for description)
- Real-time character counter for description
- Automatic timestamps (created and updated)
- Quick edit/delete actions on each post
- Visual feedback with snackbar notifications
- Responsive layout that works on all screen sizes

## Project Structure

```
lib/
├── main.dart                           # App entry point with theme configuration
├── models/
│   └── post.dart                       # Post data model
├── services/
│   └── database_service.dart           # SQLite database operations
└── screens/
    ├── home_screen.dart                # Home screen with post list
    ├── post_details_screen.dart        # Post details view
    └── add_edit_post_screen.dart       # Add/Edit post form
```

## Dependencies

- **sqflite**: ^2.3.0 - SQLite database for Flutter
- **path**: ^1.8.3 - File and directory path manipulation
- **intl**: ^0.19.0 - Date and time formatting

## Installation & Running

1. **Clone the project**
   ```bash
   cd postsmanager
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

## Database Schema

The app uses a single `posts` table with the following structure:

```sql
CREATE TABLE posts (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  createdAt TEXT,
  updatedAt TEXT
)
```

## Color Palette

- **Primary Red**: #D32F2F (rgb(211, 47, 47)) - Used for app bar, FAB, and accents
- **Accent Yellow**: #FBC02D (rgb(251, 192, 45)) - Used for timestamps and highlights
- **Background**: White - Main background color
- **Text**: Black - Primary text color
- **Secondary Gray**: Various shades for borders and secondary content

## Key Features Explained

### 1. Home Screen
- Displays all posts in a sorted list (newest first)
- Each post card shows:
  - Post title
  - Description preview (truncated to 2 lines)
  - Creation/update date
  - Quick edit and delete buttons
- Empty state with helpful message
- FAB for adding new posts

### 2. Post Details Screen
- Full post title in a highlighted container
- Complete description with proper formatting
- Timeline section showing creation and last update timestamps
- Edit button for quick access to edit functionality
- Smooth animations on screen entry

### 3. Add/Edit Post Screen
- Clean form layout with clear labels
- Title field (3-200 characters)
- Description field (10-2000 characters)
- Real-time character counter
- Input validation with error messages
- Processing state during submission
- Informational banner about offline storage

### 4. Animations & Transitions
- **Screen Transitions**: Slide and scale transitions
- **FAB Animation**: Elastic scale animation
- **Card Hover Effects**: Scale down on hover
- **Fade Animations**: Content fades in on load
- **Button Feedback**: Visual feedback on press

## User Flow

1. **Launch App** → Home Screen with all posts
2. **View Post** → Tap card → Details Screen → optionally Edit or go back
3. **Create Post** → Tap FAB → Form → Enter details → Submit → Back to Home
4. **Edit Post** → Tap edit icon → Form with pre-filled data → Submit → Back to Home
5. **Delete Post** → Tap delete icon → Confirmation dialog → Confirm → Post deleted

## Offline Capabilities

The app works 100% offline because:
- SQLite stores all data locally on the device
- No API calls or network requests are made
- All operations (CRUD) happen on the local database
- Perfect for offline teams or field workers

## Future Enhancements

Potential features for expansion:
- Post categories/tags
- Search and filter functionality
- Post export to PDF/Word
- Cloud sync when connection is available
- Image attachments for posts
- Post sharing capability
- Dark mode theme
- Multi-language support

## Notes

- Timestamps are stored in ISO 8601 format
- The app maintains application state using StatefulWidgets
- Database operations are asynchronous for smooth UI
- All form inputs are validated before submission
- Proper error handling with user-friendly messages

---

**Built with Flutter & Dart**  
Perfect for offline content management without complex infrastructure!
