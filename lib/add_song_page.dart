import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddSongPage extends StatefulWidget {
  const AddSongPage({super.key});

  @override
  State<AddSongPage> createState() => _AddSongPageState();
}

class _AddSongPageState extends State<AddSongPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _artistController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
  final TextEditingController _audioUrlController = TextEditingController();
  final TextEditingController _yearController = TextEditingController(); // ✅ Added

  bool _isLoading = false;

  void _uploadSong() async {
    final title = _titleController.text.trim();
    final subtitle = _artistController.text.trim();
    final imageUrl = _imageUrlController.text.trim();
    final audioUrl = _audioUrlController.text.trim();
    final year = _yearController.text.trim(); // ✅ Corrected

    if (title.isEmpty || subtitle.isEmpty || imageUrl.isEmpty || audioUrl.isEmpty || year.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await FirebaseFirestore.instance.collection('songs').add({
        'title': title,
        'subtitle': subtitle,
        'imageUrl': imageUrl,
        'audioUrl': audioUrl,
        'year': year,
        'createdAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Song uploaded successfully!')),
      );

      _titleController.clear();
      _artistController.clear();
      _imageUrlController.clear();
      _audioUrlController.clear();
      _yearController.clear(); // ✅ Clear year too
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload failed: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _artistController.dispose();
    _imageUrlController.dispose();
    _audioUrlController.dispose();
    _yearController.dispose(); // ✅ Dispose added
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add New Song"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            _buildTextField(_titleController, 'Song Title'),
            const SizedBox(height: 15),
            _buildTextField(_artistController, 'Artist'),
            const SizedBox(height: 15),
            _buildTextField(_imageUrlController, 'Image URL'),
            const SizedBox(height: 15),
            _buildTextField(_audioUrlController, 'Audio URL'),
            const SizedBox(height: 15),
            _buildTextField(_yearController, 'Release Year'), // ✅ New field
            const SizedBox(height: 25),
            ElevatedButton.icon(
              icon: const Icon(Icons.cloud_upload),
              label: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Upload Song"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: _isLoading ? null : _uploadSong,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: hint,
        border: const OutlineInputBorder(),
      ),
    );
  }
}