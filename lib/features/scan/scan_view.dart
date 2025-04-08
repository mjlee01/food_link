import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:food_link/utils/constants/colors.dart';
import 'package:food_link/features/main_screen.dart';
import 'dart:collection';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  _ScanPageState createState() => _ScanPageState();
}

typedef GroceryTypeEntry = DropdownMenuEntry<GroceryType>;
typedef GroceryUnitEntry = DropdownMenuEntry<GroceryUnit>;

enum GroceryType {
  fruit('Fruit', FontAwesomeIcons.apple),
  vegetable('Vegetable', FontAwesomeIcons.carrot),
  dairy('Dairy', FontAwesomeIcons.cheese),
  meat('Meat', FontAwesomeIcons.drumstickBite),
  bakery('Bakery', FontAwesomeIcons.breadSlice),
  grain('Grain', FontAwesomeIcons.bowlRice),
  beverage('Beverage', FontAwesomeIcons.mugHot),
  snack('Snack', FontAwesomeIcons.cookie),
  frozen('Frozen', FontAwesomeIcons.iceCream),
  canned('Canned', Icons.kitchen),
  other('Other', FontAwesomeIcons.plus);

  const GroceryType(this.type, this.icon);
  final String type;
  final IconData icon;

  static final List<GroceryTypeEntry> entries =
      UnmodifiableListView<GroceryTypeEntry>(
        values.map<GroceryTypeEntry>(
          (GroceryType type) => GroceryTypeEntry(
            value: type,
            label: type.type,
            leadingIcon: Icon(type.icon),
          ),
        ),
      );
}

enum GroceryUnit {
  piece('Piece(s)', FontAwesomeIcons.percent),
  box('Box', FontAwesomeIcons.boxesStacked),
  bag('Bag', FontAwesomeIcons.bagShopping),
  bottle('Bottle', FontAwesomeIcons.bottleWater),
  can('Can', FontAwesomeIcons.prescriptionBottle),
  packet('Packet', FontAwesomeIcons.envelope),
  carton('Carton', Icons.takeout_dining),
  jar('Jar', FontAwesomeIcons.jar),
  slice('Slice', FontAwesomeIcons.pizzaSlice),
  cup('Cup', FontAwesomeIcons.mugSaucer),
  other('Other', FontAwesomeIcons.plus);

  const GroceryUnit(this.unit, this.icon);
  final String unit;
  final IconData icon;

  static final List<GroceryUnitEntry> entries =
      UnmodifiableListView<GroceryUnitEntry>(
        values.map<GroceryUnitEntry>(
          (GroceryUnit unit) => GroceryUnitEntry(
            value: unit,
            label: unit.unit,
            leadingIcon: Icon(unit.icon),
          ),
        ),
      );
}

class _ScanPageState extends State<ScanPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _tabs = [const Tab(text: "Camera"), const Tab(text: "Manual")];

  List<CameraDescription> _cameras = [];
  CameraController? _cameraController;
  bool isCameraInitialized = false;
  int _cameraIndex = 0;

  final TextEditingController groceryTypeController = TextEditingController();
  final TextEditingController groceryUnitController = TextEditingController();
  GroceryType? selectedGrocery;
  GroceryUnit? selectedUnit;

  final TextEditingController _dateController = TextEditingController();

  final FocusNode _dropdownFocusNode = FocusNode();
  bool buttonColor = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initializeCamera();
    _dropdownFocusNode.addListener(() {
      if (_dropdownFocusNode.hasFocus) {
        setState(() {
          buttonColor = false; // Reset button color when menu opens
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    if (cameras.isNotEmpty) {
      _cameras = cameras;
      _startCamera(_cameraIndex); // Back camera as default
    }
  }

  Future<void> _startCamera(int cameraIndex) async {
    if (_cameraController != null) {
      await _cameraController!.dispose(); // Dispose old controller
    }

    _cameraController = CameraController(
      _cameras[cameraIndex],
      ResolutionPreset.high,
      enableAudio: false,
    );

    try {
      await _cameraController!.initialize();
      setState(() {
        isCameraInitialized = true;
      });
    } catch (e) {
      debugPrint("Error initializing camera: $e");
    }
  }

  Future<void> _capturePhoto() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized)
      return;

    final XFile photo = await _cameraController!.takePicture();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Photo captured: ${photo.path}")));
  }

  void _flipCamera() {
    if (_cameras.length > 1) {
      setState(() {
        _cameraIndex = (_cameraIndex == 0) ? 1 : 0;
      });
      _startCamera(_cameraIndex);
    }
  }

  Future<void> _selectFromGallery() async {
    // Implement image selection from gallery
    // For example, using image_picker package
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Image selected: ${image.path}")));
    }
  }

  Future<void> _pickDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        _dateController.text = DateFormat(
          'dd/MM/yyyy',
        ).format(picked); // Auto-fill text field
      });
    }
  }

  /// Handles text input changes
  void _onTextChanged(String value) {
    try {
      DateTime parsedDate = DateFormat(
        'dd/MM/yyyy',
      ).parseStrict(value); // Ensure strict format
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Scan Grocery",
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: FLColors.white),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const MainScreen()),
              (route) => false, // Removes all previous routes
            );
          },
        ),
        backgroundColor: FLColors.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: TabBar(
                controller: _tabController,
                dividerColor: Colors.transparent,
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorPadding: const EdgeInsets.all(5),
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  color: FLColors.white,
                ),
                labelColor: FLColors.primary,
                labelStyle: TextStyle(fontWeight: FontWeight.normal),
                unselectedLabelColor: FLColors.black,
                tabs: _tabs,
              ),
            ),

            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [_buildCameraView(), _buildManualEntryView()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraView() {
    return SingleChildScrollView(
      child: Center(
        child: Column(
          children: [
            const SizedBox(height: 20),
            SizedBox(
              width: 350,
              height: 400,
              child: Stack(
                children: [
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(
                        10,
                      ), // Maintain rounded corners
                      child: OverflowBox(
                        alignment: Alignment.center,
                        minWidth: 0,
                        maxWidth: 350, // Fixed width
                        minHeight: 0,
                        maxHeight:
                            double.infinity, // Allow extra content to overflow
                        child: CameraPreview(_cameraController!),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 20.0,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: FLColors.white,
                              width: 1,
                              style: BorderStyle.solid,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          width: 300,
                          height: 300,
                          child: Icon(
                            FontAwesomeIcons.seedling,
                            color: FLColors.white.withValues(alpha: 0.4),
                            size: 50,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Position your grocery item within the frame and tap capture",
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(color: FLColors.textWhite),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Stack(
                      children: [
                        IconButton(
                          icon: Icon(FontAwesomeIcons.cameraRotate),
                          onPressed: _flipCamera,
                          style: ButtonStyle(
                            padding: WidgetStateProperty.all(
                              EdgeInsets.only(right: 3, bottom: 3),
                            ),
                            shape: WidgetStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            iconColor: WidgetStateProperty.all(FLColors.white),
                            iconSize: WidgetStateProperty.all(18),
                            backgroundColor: WidgetStateProperty.all(
                              FLColors.black.withValues(alpha: 0.7),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              spacing: 10,
              children: [
                ElevatedButton(
                  onPressed: _capturePhoto,
                  style: Theme.of(context).elevatedButtonTheme.style?.copyWith(
                    minimumSize: WidgetStateProperty.all(const Size(280, 40)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    spacing: 10,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(FontAwesomeIcons.camera, color: FLColors.white),
                      Text("Capture Photo"),
                    ],
                  ),
                ),
                OutlinedButton(
                  onPressed: _selectFromGallery,
                  style: Theme.of(context).outlinedButtonTheme.style?.copyWith(
                    minimumSize: WidgetStateProperty.all(const Size(50, 40)),
                  ),
                  child: Icon(FontAwesomeIcons.image, color: FLColors.primary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManualEntryView() {
    return SingleChildScrollView(
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 5, vertical: 20),
          child: Column(
            spacing: 0,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 5,
                children: [
                  Text(
                    "Grocery Name",
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: FLColors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextField(
                    maxLength: 60,
                    decoration: InputDecoration(
                      labelText: "  Enter Grocery Name",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: FLColors.primary),
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        buttonColor = false;
                      });
                    },
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 5,
                children: [
                  Text(
                    "Category",
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: FLColors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  DropdownMenu<GroceryType>(
                    menuHeight: 185,
                    controller: groceryTypeController,
                    enableFilter: true,
                    requestFocusOnTap: true,
                    width: 350,
                    leadingIcon: const Padding(
                      padding: EdgeInsets.only(left: 8.0), // Move right a bit
                      child: Icon(Icons.search),
                    ),
                    label: const Text('Select a Category'),
                    inputDecorationTheme: const InputDecorationTheme(
                      filled: true,
                      fillColor: Colors.transparent,
                      contentPadding: EdgeInsets.symmetric(vertical: 5.0),
                      iconColor: FLColors.white,
                    ),
                    menuStyle: MenuStyle(
                      backgroundColor: WidgetStateProperty.all(FLColors.white),
                    ),
                    onSelected: (GroceryType? icon) {
                      setState(() {
                        selectedGrocery = icon;
                        buttonColor = false;
                      });
                    },
                    dropdownMenuEntries: GroceryType.entries,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 5,
                children: [
                  Text(
                    "Expiry Date",
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: FLColors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  OutlinedButton(
                    onPressed: () {
                      _pickDate(context);
                      setState(() {
                        buttonColor = true;
                      });
                    },
                    style: Theme.of(
                      context,
                    ).outlinedButtonTheme.style?.copyWith(
                      minimumSize: WidgetStateProperty.all(const Size(50, 40)),
                      side: WidgetStateProperty.all(
                        BorderSide(
                          color:
                              buttonColor ? FLColors.black : Colors.grey[300]!,
                        ),
                      ),
                    ),
                    child: Row(
                      spacing: 15,
                      children: [
                        Icon(
                          FontAwesomeIcons.calendarDays,
                          color:
                              buttonColor ? FLColors.black : Colors.grey[300],
                        ),
                        Text(
                          _dateController.text.isNotEmpty
                              ? _dateController.text
                              : "Pick an Expiry Date",
                          style: TextStyle(fontWeight: FontWeight.normal),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 5,
                children: [
                  Text(
                    "Quantity",
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: FLColors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextField(
                    maxLength: 5,
                    decoration: InputDecoration(
                      labelText: "  Enter Grocery Quantity",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: FLColors.primary),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    onTap: () {
                      setState(() {
                        buttonColor = false;
                      });
                    },
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 5,
                children: [
                  Text(
                    "Unit",
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: FLColors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  DropdownMenu<GroceryUnit>(
                    menuHeight: 185,
                    controller: groceryUnitController,
                    enableFilter: true,
                    requestFocusOnTap: true,
                    width: 350,
                    leadingIcon: const Padding(
                      padding: EdgeInsets.only(left: 8.0), // Move right a bit
                      child: Icon(Icons.search),
                    ),
                    label: const Text('Select a Unit'),
                    inputDecorationTheme: const InputDecorationTheme(
                      filled: true,
                      fillColor: Colors.transparent,
                      contentPadding: EdgeInsets.symmetric(vertical: 5.0),
                      iconColor: FLColors.white,
                    ),
                    menuStyle: MenuStyle(
                      backgroundColor: WidgetStateProperty.all(FLColors.white),
                    ),
                    onSelected: (GroceryUnit? icon) {
                      setState(() {
                        selectedUnit = icon;
                        buttonColor = false;
                      });
                    },
                    dropdownMenuEntries: GroceryUnit.entries,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      _selectFromGallery();
                      setState(() {
                        buttonColor = false;
                      });
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      spacing: 10,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(FontAwesomeIcons.plus, color: FLColors.white),
                        Text("Add to Inventory"),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
