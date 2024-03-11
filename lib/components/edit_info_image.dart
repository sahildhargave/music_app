import 'dart:io';
import 'dart:typed_data';

import 'package:audiotagger/audiotagger.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:music/util/config.dart';

class EditInfoImage extends StatefulWidget {
  final String songPath;
  final Function setImage;

  EditInfoImage(this.songPath, this.setImage);
  @override
  _EditInfoImageState createState() => _EditInfoImageState();
}

class _EditInfoImageState extends State<EditInfoImage> {
  late File _pickedImage;
  late Uint8List _image;

  void _getImage() {
    Audiotagger().readArtwork(path: widget.songPath).then((value) {
      setState(() {
        _image = value!.length < 20000 ? value : Uint8List(0);
      });
    }).catchError((e) => _image = Uint8List(0));
  }

  void _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.getImage(source: ImageSource.gallery);
    if (image == null) {
      return;
    }
    print(image.path);
    setState(() {
      _pickedImage = File(image.path);
    });
    widget.setImage(image.path);
  }

  @override
  void initState() {
    super.initState();
    _getImage();
  }

  DecorationImage? _buildDecorationImage() {
    if (_pickedImage != null) {
      return DecorationImage(
        image: FileImage(_pickedImage),
        fit: BoxFit.cover,
      );
    } else if (_image.isNotEmpty) {
      return DecorationImage(
        image: MemoryImage(_image),
        fit: BoxFit.cover,
      );
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(15),
      onTap: _pickImage,
      child: Stack(
        children: [
          Container(
            height: Config.yMargin(context, 15),
            width: Config.yMargin(context, 15),
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).dividerColor),
              borderRadius: BorderRadius.circular(15),
              image: _buildDecorationImage(),
            ),
          ),
          Container(
            alignment: Alignment.bottomLeft,
            height: Config.yMargin(context, 15),
            width: Config.yMargin(context, 15),
            padding: EdgeInsets.only(left: 10, bottom: 10),
            decoration: BoxDecoration(
              color: Colors.black38,
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Icon(
                  Icons.image,
                  color: Colors.white,
                ),
                SizedBox(
                  width: 10,
                ),
                Text(
                  'Edit',
                  style: TextStyle(color: Colors.white),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
