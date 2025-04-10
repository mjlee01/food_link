import 'dart:io';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:food_link/utils/cloudinary/images_upload.dart';
import 'package:image_picker/image_picker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:food_link/utils/constants/colors.dart';
import 'package:food_link/features/main_screen.dart';
import 'dart:collection';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:food_link/features/inventory/inventory_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'dart:typed_data';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
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

final Map<int, String> classNameMap = {
  0: 'Banana - Green',
  1: 'Banana - Semiripe',
  2: 'Banana - Ripe',
  3: 'Banana - Overripe',
  4: 'Avocado - Underripe',
  5: 'Avocado - Breaking',
  6: 'Avocado - Ripe_1',
  7: 'Avocado - Ripe_2',
  8: 'Avocado - Overripe',
};

DateTime getEstimatedExpiryDate(int? classIndex) {
  Map<int, int> expiryDaysMap = {
    0: 7, // Banana - Green
    1: 5, // Banana - Semiripe
    2: 3, // Banana - Ripe
    3: 2, // Banana - Overripe
    4: 10, // Avocado - Underripe
    5: 8, // Avocado - Breaking
    6: 6, // Avocado - Ripe_1
    7: 4, // Avocado - Ripe_2
    8: 2, // Avocado - Overripe
  };

  // Default expiry is 7 days
  return DateTime.now().add(Duration(days: expiryDaysMap[classIndex] ?? 7));
}

class _ScanPageState extends State<ScanPage>
    with SingleTickerProviderStateMixin {
  int? _predictionLabel;
  double? _predictionConfidence;
  late Interpreter _interpreter;

  late TabController _tabController;
  final _tabs = [const Tab(text: "Camera"), const Tab(text: "Manual")];

  List<CameraDescription> _cameras = [];
  CameraController? _cameraController;
  bool isCameraInitialized = false;
  int _cameraIndex = 0;
  XFile? _capturedImage;

  final TextEditingController groceryTypeController = TextEditingController();
  final TextEditingController groceryUnitController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  GroceryType? selectedGrocery;
  GroceryUnit? selectedUnit;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();

  final FocusNode _dropdownFocusNode = FocusNode();
  bool buttonColor = false;
  bool _isCapturing = false; // Add this state variable

  bool isLoading = false;

  String userId = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    _loadModel();
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
    _interpreter.close();
  }

  Float32List imageToTensor(img.Image image) {
    final Float32List tensor = Float32List(1 * 224 * 224 * 3);
    int index = 0;

    for (int y = 0; y < 224; y++) {
      for (int x = 0; x < 224; x++) {
        final pixel = image.getPixel(x, y);
        tensor[index++] = img.getRed(pixel) / 255.0;
        tensor[index++] = img.getGreen(pixel) / 255.0;
        tensor[index++] = img.getBlue(pixel) / 255.0;
      }
    }

    return tensor;
  }

  Future<void> _loadModel() async {
    try {
      // Load the model from the assets
      _interpreter = await Interpreter.fromAsset('assets/model.tflite');

      debugPrint("Model loaded successfully!");
    } catch (e) {
      debugPrint("Error loading model: $e");
    }
  }

  Future<void> _predictImage(File image) async {
    try {
      // Read image
      final imageBytes = await image.readAsBytes();
      final img.Image? imageTemp = img.decodeImage(imageBytes);

      if (imageTemp == null) {
        debugPrint("Error decoding image");
        return;
      }

      // Resize
      final img.Image resizedImage = img.copyResize(
        imageTemp,
        width: 224,
        height: 224,
      );

      // Convert to tensor
      final input = imageToTensor(resizedImage);

      // Prepare output buffer (adjust size based on model)
      final output = List.filled(
        1 * 9,
        0.0,
      ).reshape([1, 9]); // Example for classification

      // Run inference
      _interpreter.run(input.buffer.asUint8List(), output);

      // Process output
      final confidences = output[0] as List<double>;
      final maxIndex = confidences.indexWhere(
        (v) => v == confidences.reduce((a, b) => a > b ? a : b),
      );

      setState(() {
        _predictionLabel = maxIndex;
        _predictionConfidence = confidences[maxIndex];
      });
    } catch (e) {
      debugPrint("Error during image prediction: $e");
    }
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
    try {
      if (_cameraController == null ||
          !_cameraController!.value.isInitialized) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Camera is not initialized")),
        );
        return;
      }

      // Show loading indicator
      setState(() {
        _isCapturing = true; // Add this state variable
      });

      final XFile photo = await _cameraController!.takePicture();
      setState(() {
        _capturedImage = photo;
        _isCapturing = false;
      });
      final imageFile = File(photo.path);

      // Process the image
      await _predictImage(imageFile);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Photo captured successfully"),
          elevation: 10,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error capturing photo: $e")));
    } finally {
      if (mounted) {
        setState(() {
          _isCapturing = false;
        });
      }
    }
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
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _capturedImage = image;
      _isCapturing = false;
    });
    final imageFile = File(image!.path);

    if (!mounted) return;

    // ScaffoldMessenger.of(
    //   context,
    // ).showSnackBar(SnackBar(content: Text("Image selected: ${image.path}")));
    await _predictImage(imageFile);
  }

  Future<void> _selectManualFromGallery() async {
    // Implement image selection from gallery
    // For example, using image_picker package
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _capturedImage = image;
      _isCapturing = false;
    });
    final imageFile = File(image!.path);

    if (!mounted) return;

    // ScaffoldMessenger.of(
    //   context,
    // ).showSnackBar(SnackBar(content: Text("Image selected: ${image.path}")));
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

  Future<void> _addToInventory(InventoryItem item) async {
    final collection = FirebaseFirestore.instance.collection('groceries');
    await collection.add(item.toMap());
  }

  void _showPredictionModal(BuildContext context) {
    GroceryType defaultType = GroceryType.values.firstWhere(
      (e) => e.type == 'Fruit',
      orElse: () => GroceryType.other,
    );
    GroceryType selectedType = defaultType;

    GroceryUnit defaultUnit = GroceryUnit.values.firstWhere(
      (e) => e.unit == 'Piece(s)',
      orElse: () => GroceryUnit.other,
    );

    final nameController = TextEditingController(
      text: classNameMap[_predictionLabel] ?? 'Unknown',
    );
    final quantityController = TextEditingController(text: '1');
    final unitController = TextEditingController(text: defaultUnit.unit);
    DateTime selectedExpiryDate = getEstimatedExpiryDate(_predictionLabel);
    final expiryDateController = TextEditingController(
      text: selectedExpiryDate.toLocal().toString().split(' ')[0],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          elevation: 5,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Confirm Grocery Details'),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(
                  FontAwesomeIcons.xmark,
                  color: FLColors.dark,
                  size: 16,
                ),
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(
                    Colors.black.withValues(alpha: 0.03),
                  ),
                  padding: WidgetStateProperty.all(EdgeInsets.zero),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 10,
              children: [
                if (_capturedImage != null)
                  Center(
                    child: Column(
                      children: [
                        Image.file(
                          File(_capturedImage!.path),
                          width: 200,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                        Container(
                          width: 200,
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color.fromARGB(129, 0, 162, 255),
                                Color.fromARGB(122, 0, 255, 145),
                              ],
                            ),
                          ),
                          child: Text(
                            'CONFIDENCE: ${(_predictionConfidence! * 100).toStringAsFixed(2)}%',
                            style: TextStyle(
                              color: FLColors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                TextField(
                  maxLength: 60,
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: "  Enter Grocery Name",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: FLColors.primary),
                    ),
                  ),
                ),
                OutlinedButton(
                  onPressed: () {
                    _pickDate(context);
                    setState(() {
                      buttonColor = true;
                    });
                  },
                  style: Theme.of(context).outlinedButtonTheme.style?.copyWith(
                    minimumSize: WidgetStateProperty.all(const Size(50, 40)),
                    side: WidgetStateProperty.all(
                      BorderSide(
                        color: buttonColor ? FLColors.black : Colors.grey[300]!,
                      ),
                    ),
                  ),
                  child: Row(
                    spacing: 15,
                    children: [
                      Icon(
                        FontAwesomeIcons.calendarDays,
                        color: Colors.grey[600],
                      ),

                      Text(
                        expiryDateController.text.isNotEmpty
                            ? expiryDateController.text
                            : "Pick an Expiry Date",
                        style: TextStyle(fontWeight: FontWeight.normal),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 5),
                DropdownMenu<GroceryType>(
                  initialSelection: selectedType,
                  menuHeight: 185,
                  enableFilter: true,
                  requestFocusOnTap: true,
                  width: 260,
                  leadingIcon: const Padding(
                    padding: EdgeInsets.only(left: 8.0),
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
                    backgroundColor: WidgetStatePropertyAll(FLColors.white),
                  ),
                  onSelected: (GroceryType? newType) {
                    if (newType != null) {
                      setState(() => selectedType = newType);
                    }
                  },
                  dropdownMenuEntries: GroceryType.entries,
                ),
                SizedBox(height: 5),
                TextField(
                  controller: quantityController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Select a Quantity',
                  ),
                ),
                SizedBox(height: 5),
                DropdownMenu<GroceryUnit>(
                  initialSelection: selectedUnit,
                  menuHeight: 185,
                  enableFilter: true,
                  requestFocusOnTap: true,
                  width: 260,
                  leadingIcon: const Padding(
                    padding: EdgeInsets.only(left: 8.0),
                    child: Icon(Icons.search),
                  ),
                  label: const Text('Select a Unit'),
                  controller: unitController,
                  inputDecorationTheme: const InputDecorationTheme(
                    filled: true,
                    fillColor: Colors.transparent,
                    contentPadding: EdgeInsets.symmetric(vertical: 5.0),
                    iconColor: FLColors.white,
                  ),
                  menuStyle: MenuStyle(
                    backgroundColor: WidgetStatePropertyAll(FLColors.white),
                  ),
                  onSelected: (GroceryUnit? icon) {
                    setState(() {
                      selectedUnit = icon;
                      buttonColor = false;
                    });
                  },
                  dropdownMenuEntries: GroceryUnit.entries,
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                setState(() {
                  isLoading = true;
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Uploading image...'), elevation: 10),
                );

                final imageUrl = await ImageUploadUtil().uploadImage(
                  _capturedImage!.path,
                );

                if (imageUrl == null || imageUrl.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error uploading image!'),
                      elevation: 500,
                    ),
                  );
                } else {
                  try {
                    final item = InventoryItem(
                      userId: userId,
                      name: nameController.text.trim(),
                      category: selectedType.type,
                      expiryDate: selectedExpiryDate,
                      quantity:
                          int.tryParse(quantityController.text.trim()) ?? 1,
                      unit: unitController.text.trim(),
                      imageUrl: imageUrl,
                    );

                    await _addToInventory(item);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Item added to inventory!',
                          style: TextStyle(color: FLColors.white),
                        ),
                        backgroundColor: FLColors.info,
                        elevation: 500,
                      ),
                    );

                    setState(() {
                      isLoading = false;
                    });
                    Navigator.of(context).pop();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error adding item: $e')),
                    );
                    setState(() {
                      isLoading = false;
                    });
                  }
                }
              },
              child:
                  isLoading
                      ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                            strokeWidth: 2.0,
                          ),
                          const SizedBox(width: 6),
                          const Text('Uploading...'),
                        ],
                      )
                      : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(FontAwesomeIcons.plus, color: FLColors.white),
                          const SizedBox(width: 6),
                          const Text('Add to Inventory'),
                        ],
                      ),
            ),
          ],
        );
      },
    );
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
                      child: Stack(
                        children: [
                          OverflowBox(
                            alignment: Alignment.center,
                            minWidth: 0,
                            maxWidth: 350,
                            minHeight: 0,
                            maxHeight: double.infinity,
                            child:
                                _cameraController != null &&
                                        _cameraController!.value.isInitialized
                                    ? CameraPreview(_cameraController!)
                                    : const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                          ),
                          if (_isCapturing)
                            Container(
                              color: Colors.black54,
                              child: const Center(
                                child: CircularProgressIndicator(
                                  color: FLColors.white,
                                ),
                              ),
                            ),
                        ],
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
                  onPressed: () async {
                    await _capturePhoto();
                    if (!mounted) return;
                    if (_predictionLabel != null &&
                        _predictionConfidence != null) {
                      _showPredictionModal(context);
                    }
                  },
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
                  onPressed: () async {
                    await _selectFromGallery();

                    if (!mounted) return;

                    if (_predictionLabel != null &&
                        _predictionConfidence != null) {
                      _showPredictionModal(context);
                    }
                  },
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
                    controller: nameController,
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
                      padding: EdgeInsets.only(left: 8.0),
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
                    controller: quantityController,
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
                      padding: EdgeInsets.only(left: 8.0),
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
                    onPressed: () async {
                      await _selectManualFromGallery();

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Uploading image...'),
                          elevation: 10,
                        ),
                      );

                      final imageUrl = await ImageUploadUtil().uploadImage(
                        _capturedImage!.path,
                      );

                      if (imageUrl == null || imageUrl.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error uploading image!'),
                            elevation: 500,
                          ),
                        );
                      } else {
                        try {
                          final item = InventoryItem(
                            userId: userId,
                            name: nameController.text.trim(),
                            category: groceryTypeController.text.trim(),
                            expiryDate: DateFormat(
                              'dd/MM/yyyy',
                            ).parse(_dateController.text),
                            quantity:
                                int.tryParse(quantityController.text.trim()) ??
                                1,
                            unit: groceryUnitController.text.trim(),
                            note: '',
                            imageUrl: imageUrl,
                          );

                          await _addToInventory(item);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Item added to inventory!',
                                style: TextStyle(color: FLColors.white),
                              ),
                              backgroundColor: FLColors.info,
                              elevation: 500,
                            ),
                          );

                          setState(() {
                            isLoading = false;
                          });
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error adding item: $e')),
                          );
                          setState(() {
                            isLoading = false;
                          });
                        }
                      }
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
