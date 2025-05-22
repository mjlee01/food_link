# Food Link App

Food Link is a mobile application designed to help users manage their groceries, reduce food waste, and connect with their community for food sharing.

## Core Features

### 1. Home
- Displays a personalized welcome message.
- Shows a list of grocery items that are expiring soon, helping users prioritize their usage.
- Provides quick access to the user's saved recipes.

### 2. Scan & Add Groceries
- **Camera Scanning:** Allows users to scan barcodes or use image recognition (e.g., for fruits/vegetables) to quickly add items to their inventory. The app can estimate ripeness and suggest expiry dates for certain items.
- **Manual Entry:** Provides an interface for users to manually input grocery details, including name, category, quantity, unit, and expiry date.
- **Image Upload:** Users can attach images to their grocery items for easy identification.

### 3. Inventory Management
- **Categorized View:** Lists all grocery items, grouped by category (e.g., Fruit, Vegetable, Dairy).
- **Expiry Tracking:** Clearly displays expiry dates and uses color indicators (e.g., red for expired, yellow for expiring soon) to highlight item status.
- **Search & Filter:** Users can search for specific items and filter their inventory by date range to easily find what they need.
- **Item Details:** Tapping on an item shows more details, including its image, category, quantity, expiry date, and any notes. Options to generate recipes or delete items are also available.

### 4. Recipe Management
- **View Recipes:** Users can browse their collection of saved recipes.
- **Create Recipes:** Allows users to create new recipes, potentially by selecting ingredients from their current inventory.
- **Recipe Display:** Shows recipe details, including ingredients and instructions.

### 5. Food Hub (Community Sharing)
- **Map View:** Displays available food items shared by other users on a map, relative to the user's current location.
- **Item Listings:** Shows a list of shared food items, which can be filtered by:
    - **Nearby:** Based on a selectable distance radius.
    - **Price:** Free, For Sale, Trade.
- **Share Food:** Users can share their surplus food items by providing details like name, description, price/sharing terms, and location.
- **Chat Functionality:** Enables users to communicate with each other to arrange pickups or trades for shared items. Users can also see a list of their ongoing chats.
- **My Shared Items:** A dedicated view for users to manage the items they have shared.

## Quickstart

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/mjlee01/food_link.git
    ```
2.  **Navigate to the project directory:**
    ```bash
    cd food_link
    ```
3.  **Install dependencies:**
    ```bash
    flutter pub get
    ```
4.  **Run the app:**
    ```bash
    flutter run
    ```
