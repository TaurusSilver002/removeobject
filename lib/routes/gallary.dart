import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:objectremove/routes/detect.dart';
import 'package:objectremove/services/app_translations.dart';
import 'package:photo_manager/photo_manager.dart';

class GalleryFromDevice extends StatefulWidget {
  const GalleryFromDevice({super.key});
  @override
  State<GalleryFromDevice> createState() => _GalleryFromDeviceState();
}

class _GalleryFromDeviceState extends State<GalleryFromDevice> {
  final picker = ImagePicker();
  bool isMenuOpen = false;
  String selectedCategory = 'Recents';
  bool isLoading = true;
  bool hasPermission = false;

  Map<String, AssetPathEntity> categoryMap = {};
  List<AssetEntity> currentAssets = [];

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final permission = await PhotoManager.requestPermissionExtend();
    if (permission.isAuth) {
      // Full permission
      await _loadAlbums();
      setState(() => hasPermission = true);
    } else if (permission.hasAccess) {
      // Limited permission
      await _loadAlbums();
      setState(() => hasPermission = true);
    } else {
      setState(() => hasPermission = false);
      // We're already in the case where permission is not granted
      PhotoManager.openSetting();
    }
    setState(() => isLoading = false);
  }

  Future<void> _loadAlbums() async {
    try {
      final albums = await PhotoManager.getAssetPathList(
        type: RequestType.image,
        hasAll: true,
      );

      for (var album in albums) {
        final name = album.name.toLowerCase();
        if (name.contains('screenshot')) {
          categoryMap['Screenshot'] = album;
        } else if (name.contains('whatsapp')) {
          categoryMap['Whatsapp'] = album;
        } else if (name.contains('snapchat')) {
          categoryMap['Snapchat'] = album;
        } else if (name.contains('instagram')) {
          categoryMap['Instagram'] = album;
        } else if (album.isAll) {
          categoryMap['Recents'] = album;
        }
      }

      if (!categoryMap.containsKey('Recents') && albums.isNotEmpty) {
        categoryMap['Recents'] = albums.first;
      }

      await _loadAssetsFor(selectedCategory);
    } catch (e) {
      print('Error loading albums: $e');
    }
  }

  Future<void> _loadAssetsFor(String category) async {
    final path = categoryMap[category];
    if (path == null) return;
    try {
      final assets = await path.getAssetListPaged(page: 0, size: 100);
      setState(() {
        selectedCategory = category;
        currentAssets = assets;
        isMenuOpen = false;
      });
    } catch (e) {
      print('Error loading assets: $e');
    }
  }

  Future<void> _getImageFrom(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      await _checkPermissions(); // Refresh permissions and assets
    }
  }

  void _showPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(children: [
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: 'Photo Library'.tr(),
            onTap: () {
              _getImageFrom(ImageSource.gallery);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_camera),
            title: 'Camera'.tr(),
            onTap: () {
              _getImageFrom(ImageSource.camera);
              Navigator.pop(context);
            },
          ),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : Stack(
              children: [
                Column(
                  children: [
                    _buildHeader(),
                    if (hasPermission) _buildCategoryTabs(),
                    Expanded(
                      child: hasPermission
                          ? _buildImageGrid()
                          : const Center(
                              child: Text(
                                'Please grant photo access in settings.',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                    ),
                    _buildEditButton(),
                  ],
                ),
                if (isMenuOpen && hasPermission) _buildCategoryMenu(),
              ],
            ),
    );
  }

  Widget _buildHeader() => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(width: 10),
              TranslatableText('Remove Object',
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const Spacer(),
              // IconButton(
              //   icon: const Icon(Icons.menu, color: Colors.white),
              //   onPressed: () => setState(() => isMenuOpen = !isMenuOpen),
              // ),
              IconButton(onPressed: (){
                Navigator.pushNamed(context, '/settings');
              }, icon: const Icon(Icons.settings, color: Colors.white)),
            ],
          ),
        ),
      );

  Widget _buildCategoryTabs() {
    return Container(
      height: 40,
      margin: const EdgeInsets.only(left: 16),
      child: Row(
        children: [
          IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () => setState(() => isMenuOpen = !isMenuOpen),
        ),
        const SizedBox(width: 8),
          Expanded(
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: categoryMap.keys.map((cat) {
                final isSelected = selectedCategory == cat;
                return GestureDetector(
                  onTap: () => _loadAssetsFor(cat),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.red : Colors.grey[800],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(cat,
                        style: const TextStyle(color: Colors.white, fontSize: 14)),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageGrid() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: GridView.builder(
        itemCount: currentAssets.length + 1,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
        ),
        itemBuilder: (context, index) {
          if (index == 0) {
            return GestureDetector(
              onTap: () => _showPicker(context),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Icon(Icons.camera_alt, color: Colors.white70, size: 30),
                ),
              ),
            );
          }
          final asset = currentAssets[index - 1];
          return FutureBuilder<Uint8List?>(
            future: asset.thumbnailDataWithSize(const ThumbnailSize(200, 200)),
            builder: (_, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Container(color: Colors.grey[800]);
              }
              final data = snapshot.data;
              if (data == null) return Container(color: Colors.grey[800]);
              return GestureDetector(
                // Add this GestureDetector to handle image taps
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetectPage(asset: asset),
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(image: MemoryImage(data), fit: BoxFit.cover),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEditButton() => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: const StadiumBorder(),
              ),
              child: TranslatableText('Edit', style: const TextStyle(fontSize: 16, color: Colors.white)),
            ),
          ),
        ),
      );

  Widget _buildCategoryMenu() => GestureDetector(
        onTap: () => setState(() => isMenuOpen = false),
        child: Container(
          color: Colors.black.withOpacity(0.6),
          child: Align(
            alignment: Alignment.topRight,
            child: Container(
              margin: const EdgeInsets.only(top: 80, right: 10),
              padding: const EdgeInsets.all(12),
              width: 220,
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: categoryMap.entries.map((entry) {
                  return ListTile(
                    leading: FutureBuilder<Uint8List?>(
                      future: entry.value.getAssetListRange(start: 0, end: 1).then((assets) => assets.isNotEmpty ? assets.first.thumbnailDataWithSize(const ThumbnailSize(40, 40)) : null),
                      builder: (_, snap) {
                        return snap.data != null
                            ? Image.memory(snap.data!, width: 40, height: 40, fit: BoxFit.cover)
                            : const SizedBox(width: 40, height: 40);
                      },
                    ),
                    title: Text(entry.key, style: const TextStyle(color: Colors.white)),
                    trailing: FutureBuilder<int>(
                      future: entry.value.assetCountAsync,
                      builder: (_, s) => Text(
                        s.hasData ? '${s.data}' : '...',
                        style: const TextStyle(color: Colors.white54),
                      ),
                    ),
                    onTap: () {
                      _loadAssetsFor(entry.key);
                      setState(() => isMenuOpen = false);
                    },
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      );
}