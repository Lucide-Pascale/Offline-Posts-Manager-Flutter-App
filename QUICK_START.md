# Quick Start Guide - Offline Posts Manager

## What You've Built

A fully functional Flutter app that manages posts locally using SQLite. Your team can create, view, edit, and delete posts without any internet connection!

## How to Run the App

### Prerequisites
- Flutter SDK installed
- An emulator running or a physical device connected

### Steps

```bash
# Navigate to the project directory
cd postsmanager

# Install dependencies (if not done yet)
flutter pub get

# Run the app
flutter run
```

## Testing the App

### 1. **Create a Post**
   - Tap the red "+" (FAB) button at the bottom right
   - Enter a title (minimum 3 characters)
   - Enter a description (minimum 10 characters)
   - Tap "Create Post"
   - You'll see it appear in the list immediately

### 2. **View Post Details**
   - Tap on any post card
   - See the full content with timestamps
   - Tap the edit icon to modify it

### 3. **Edit a Post**
   - Tap the orange edit icon (pencil) on a post card
   - Or tap "Edit Post" from the details screen
   - Modify the content
   - Tap "Update Post"

### 4. **Delete a Post**
   - Tap the red delete icon (trash) on a post card
   - Confirm the deletion in the dialog
   - Post is immediately removed

### 5. **Test Offline Mode**
   - Turn off your device's internet/WiFi
   - The app continues to work perfectly!
   - All CRUD operations work without internet

## File Structure

```
lib/
├── main.dart                    # App theme & entry point
├── models/post.dart             # Post data structure
├── services/database_service.dart  # SQLite operations
└── screens/
    ├── home_screen.dart         # Main list view
    ├── post_details_screen.dart # View single post
    └── add_edit_post_screen.dart # Create/edit form
```

## Color Theme

- **Red (#D32F2F)**: Primary color for buttons and accents
- **Yellow (#FBC02D)**: Accent for timestamps
- **White**: Background
- **Black**: Text

## Key Features Working

✅ Create posts with validation  
✅ List all posts with timestamps  
✅ Edit posts with pre-filled forms  
✅ Delete with confirmation  
✅ Smooth animations between screens  
✅ Real-time database updates  
✅ No internet required  
✅ Form validation  

## Development Notes

### Adding More Features

The app is structured to be easily expandable:

1. **New database fields**: Edit `Post` model → Update database schema
2. **New screens**: Create in `lib/screens/` → navigate using `Navigator.push()`
3. **New operations**: Add methods to `DatabaseService`

### Database

SQLite database stores posts with:
- ID (auto-increment)
- Title (required)
- Description (required)
- Created timestamp
- Updated timestamp

## Troubleshooting

### App won't run?
```bash
flutter clean
flutter pub get
flutter run
```

### Database issues?
The database is stored locally. Reinstalling the app will create a fresh database.

### Animations lag?
- Run in release mode: `flutter run --release`
- Use a physical device instead of emulator

## Building for Release

### Android
```bash
flutter build apk
```

### iOS
```bash
flutter build ios
```

### Web
```bash
flutter build web
```

## Production Notes

Before deploying:
1. Update app name and bundle ID in `pubspec.yaml`
2. Add app icon and splash screen
3. Test on physical devices
4. Handle database migrations for future versions
5. Consider adding user authentication if needed

---

**Your offline-first posts manager is ready to deploy!** 🚀
